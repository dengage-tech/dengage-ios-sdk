
import AVKit
import UIKit

protocol StoryDisplayProtocol: AnyObject {
    func didCompletePreview()
    func moveToPreviousStory()
    func didTapCloseButton()
}

enum StoryMovementDirectionState {
    case forward
    case backward
}

//Identifiers
private let snapViewTagIndicator: Int = 8
private let snapTapPercentageForPrevious: Double = 0.2


final class StoryDisplayViewCell: UICollectionViewCell, UIScrollViewDelegate {
    
    //MARK: - Delegate
    public weak var delegate: StoryDisplayProtocol? {
        didSet { storyHeaderView.delegate = self }
    }
    
    //MARK:- Private iVars
    private lazy var storyHeaderView: StoryDisplayHeaderView = {
        let v = StoryDisplayHeaderView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private lazy var longPress_gesture: UILongPressGestureRecognizer = {
        let lp = UILongPressGestureRecognizer.init(target: self, action: #selector(didLongPress(_:)))
        lp.minimumPressDuration = 0.2
        lp.delegate = self
        return lp
    }()
    
    private lazy var tap_gesture: UITapGestureRecognizer = {
        let tg = UITapGestureRecognizer(target: self, action: #selector(didTapSnap(_:)))
        tg.cancelsTouchesInView = false;
        tg.numberOfTapsRequired = 1
        tg.delegate = self
        return tg
    }()
    
    private var previousSnapIndex: Int {
        return snapIndex - 1
    }
    
    private var videoSnapIndex: Int = 0
    
    private var handpickedSnapIndex: Int = 0
    
    var retryBtn: StoryRetryLoaderButton!
    
    var longPressGestureState: UILongPressGestureRecognizer.State?
    
    //MARK:- Public iVars
    public var direction: StoryMovementDirectionState = .forward
    
    public let scrollview: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        sv.isScrollEnabled = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    public var getSnapIndex: Int {
        return snapIndex
    }
    
    public var snapIndex: Int = 0 {
        didSet {
            scrollview.isUserInteractionEnabled = true
            if snapIndex < storyCover?.stories?.count ?? 0, let snap = storyCover?.stories?[snapIndex] {
                if snap.kind == MimeType.image {
                    if let snapView = getSnapview() {
                        startRequest(snapView: snapView, with: snap.mediaUrl)
                    } else {
                        if direction == .forward {
                            let snapView = createSnapView()
                            startRequest(snapView: snapView, with: snap.mediaUrl)
                        }
                    }
                } else {
                    if let videoView = getVideoView(with: snapIndex) {
                        startPlayer(videoView: videoView, with: snap.mediaUrl)
                    } else {
                        let videoView = createVideoView()
                        startPlayer(videoView: videoView, with: snap.mediaUrl)
                    }
                }
                storyHeaderView.lastUpdatedLabel.text = snap.storyDate.description
                
            }
        }
    }
    
    public var storyCover: StoryCover? {
        didSet {
            storyHeaderView.storyCover = storyCover
            if let picture = storyCover?.imgUrl {
                storyHeaderView.snaperImageView.setImage(url: picture)
            }
        }
    }
    
    //MARK: - Overriden functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        scrollview.frame = bounds
        loadUIElements()
        installLayoutConstraints()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        direction = .forward
        clearScrollViewGarbages()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Private functions
    private func loadUIElements() {
        scrollview.delegate = self
        scrollview.isPagingEnabled = true
        scrollview.backgroundColor = .green
        contentView.addSubview(scrollview)
        contentView.addSubview(storyHeaderView)
        scrollview.addGestureRecognizer(longPress_gesture)
        scrollview.addGestureRecognizer(tap_gesture)
    }
    
    private func installLayoutConstraints() {
        //Setting constraints for scrollview
        NSLayoutConstraint.activate([
            scrollview.storyLeftAnchor.constraint(equalTo: contentView.storyLeftAnchor),
            contentView.storyRightAnchor.constraint(equalTo: scrollview.storyRightAnchor),
            scrollview.storyTopAnchor.constraint(equalTo: contentView.storyTopAnchor),
            contentView.storyBottomAnchor.constraint(equalTo: scrollview.storyBottomAnchor),
            scrollview.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1.0),
            scrollview.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 1.0)
        ])
        NSLayoutConstraint.activate([
            storyHeaderView.storyLeftAnchor.constraint(equalTo: contentView.storyLeftAnchor),
            contentView.storyRightAnchor.constraint(equalTo: storyHeaderView.storyRightAnchor),
            storyHeaderView.storyTopAnchor.constraint(equalTo: contentView.storyTopAnchor),
            storyHeaderView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func createSnapView() -> UIImageView {
        let snapView = UIImageView()
        snapView.translatesAutoresizingMaskIntoConstraints = false
        snapView.tag = snapIndex + snapViewTagIndicator
        snapView.contentMode = .scaleAspectFit
        scrollview.subviews.filter({$0.tag == snapIndex + snapViewTagIndicator}).first?.removeFromSuperview()
        scrollview.addSubview(snapView)
        NSLayoutConstraint.activate([
            snapView.leadingAnchor.constraint(equalTo: (snapIndex == 0) ? scrollview.leadingAnchor : scrollview.subviews[previousSnapIndex].trailingAnchor),
            snapView.storyTopAnchor.constraint(equalTo: scrollview.storyTopAnchor),
            snapView.widthAnchor.constraint(equalTo: scrollview.widthAnchor),
            snapView.heightAnchor.constraint(equalTo: scrollview.heightAnchor),
            scrollview.storyBottomAnchor.constraint(equalTo: snapView.storyBottomAnchor)
        ])
        snapView.backgroundColor = .blue
        if(snapIndex != 0) {
            NSLayoutConstraint.activate([
                snapView.leadingAnchor.constraint(equalTo: scrollview.leadingAnchor, constant: CGFloat(snapIndex)*scrollview.width)
            ])
        }
        return snapView
    }
    
    private func getSnapview() -> UIImageView? {
        if let imageView = scrollview.subviews.filter({$0.tag == snapIndex + snapViewTagIndicator}).first as? UIImageView {
            return imageView
        }
        return nil
    }
    
    private func createVideoView() -> StoryPlayerView {
        let videoView = StoryPlayerView()
        videoView.translatesAutoresizingMaskIntoConstraints = false
        videoView.tag = snapIndex + snapViewTagIndicator
        videoView.playerObserverDelegate = self
        scrollview.subviews.filter({$0.tag == snapIndex + snapViewTagIndicator}).first?.removeFromSuperview()
        scrollview.addSubview(videoView)
        NSLayoutConstraint.activate([
            videoView.leadingAnchor.constraint(equalTo: (snapIndex == 0) ? scrollview.leadingAnchor : scrollview.subviews[previousSnapIndex].trailingAnchor),
            videoView.storyTopAnchor.constraint(equalTo: scrollview.storyTopAnchor),
            videoView.widthAnchor.constraint(equalTo: scrollview.widthAnchor),
            videoView.heightAnchor.constraint(equalTo: scrollview.heightAnchor),
            scrollview.storyBottomAnchor.constraint(equalTo: videoView.storyBottomAnchor)
        ])
        if(snapIndex != 0) {
            NSLayoutConstraint.activate([
                videoView.leadingAnchor.constraint(equalTo: scrollview.leadingAnchor, constant: CGFloat(snapIndex)*scrollview.width),
            ])
        }
        return videoView
    }
    
    private func getVideoView(with index: Int) -> StoryPlayerView? {
        if let videoView = scrollview.subviews.filter({$0.tag == index + snapViewTagIndicator}).first as? StoryPlayerView {
            return videoView
        }
        return nil
    }
    
    private func startRequest(snapView: UIImageView, with url: String) {
        snapView.setImage(url: url, style: .squared) { result in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return}
                switch result {
                case .success(_):
                    if(strongSelf.handpickedSnapIndex == strongSelf.snapIndex && url == strongSelf.storyCover!.stories?[strongSelf.snapIndex].mediaUrl) {
                        snapView.backgroundColor = .blue
                        strongSelf.startProgressors()
                    }
                case .failure(_):
                    strongSelf.showRetryButton(with: url, for: snapView)
                }
            }
        }
    }
    
    private func showRetryButton(with url: String, for snapView: UIImageView) {
        self.retryBtn = StoryRetryLoaderButton.init(withURL: url)
        self.retryBtn.translatesAutoresizingMaskIntoConstraints = false
        self.retryBtn.delegate = self
        self.isUserInteractionEnabled = true
        snapView.addSubview(self.retryBtn)
        NSLayoutConstraint.activate([
            self.retryBtn.storyCenterXAnchor.constraint(equalTo: snapView.storyCenterXAnchor),
            self.retryBtn.storyCenterYAnchor.constraint(equalTo: snapView.storyCenterYAnchor)
        ])
    }
    
    private func startPlayer(videoView: StoryPlayerView, with url: String) {
        if scrollview.subviews.count > 0 {
            if storyCover?.isCompletelyVisible == true {
                videoView.startAnimating()
                StoryVideoCacheManager.shared.getCachedFile(for: url) { [weak self] (result) in
                    guard let strongSelf = self else { return }
                    switch result {
                    case .success(let videoURL):
                        if(strongSelf.handpickedSnapIndex == strongSelf.snapIndex) {
                            let videoResource = VideoResource(filePath: videoURL.absoluteString)
                            videoView.play(with: videoResource)
                        }
                    case .failure(let error):
                        videoView.stopAnimating()
                        debugPrint("Video error: \(error)")
                    }
                }
            }
        }
    }
    
    @objc private func didLongPress(_ sender: UILongPressGestureRecognizer) {
        longPressGestureState = sender.state
        if sender.state == .began ||  sender.state == .ended {
            if(sender.state == .began) {
                pauseEntireSnap()
            } else {
                resumeEntireSnap()
            }
        }
    }
    
    @objc private func didTapSnap(_ sender: UITapGestureRecognizer) {
        let touchLocation = sender.location(ofTouch: 0, in: self.scrollview)
        
        if let snapCount = storyCover?.stories?.count {
            var n = snapIndex
            if let snap = storyCover?.stories?[n], snap.kind == .image, getSnapview()?.image == nil {
                if let snapView = getSnapview(), let btn = retryBtn, snapView.subviews.contains(btn) {
                    snapView.removeRetryButton()
                }
                fillupLastPlayedSnap(n)
            }else {
                if let videoView = getVideoView(with: n), let btn = retryBtn, videoView.subviews.contains(btn) {
                    videoView.removeRetryButton()
                }
                if getVideoView(with: n)?.player?.timeControlStatus != .playing {
                    fillupLastPlayedSnap(n)
                }
            }
            if touchLocation.x < scrollview.contentOffset.x + (scrollview.frame.width * snapTapPercentageForPrevious ) {
                direction = .backward
                if snapIndex >= 1 && snapIndex <= snapCount {
                    clearLastPlayedSnaps(n)
                    stopSnapProgressors(with: n)
                    n -= 1
                    resetSnapProgressors(with: n)
                    willMoveToPreviousOrNextSnap(n: n)
                } else {
                    delegate?.moveToPreviousStory()
                }
            } else {
                if snapIndex >= 0 && snapIndex <= snapCount {
                    //Stopping the current running progressors
                    stopSnapProgressors(with: n)
                    direction = .forward
                    n += 1
                    willMoveToPreviousOrNextSnap(n: n)
                }
            }
        }
    }
    @objc private func didEnterForeground() {
        if let story = storyCover?.stories?[snapIndex] {
            if story.kind == .video {
                let videoView = getVideoView(with: snapIndex)
                startPlayer(videoView: videoView!, with: story.mediaUrl)
            }else {
                startSnapProgress(with: snapIndex)
            }
        }
    }
    @objc private func didEnterBackground() {
        if let story = storyCover?.stories?[snapIndex] {
            if story.kind == .video {
                stopPlayer()
            }
        }
        resetSnapProgressors(with: snapIndex)
    }
    private func willMoveToPreviousOrNextSnap(n: Int) {
        if let count = storyCover?.stories?.count {
            if n < count {
                //Move to next or previous snap based on index n
                let x = n.toFloat * frame.width
                let offset = CGPoint(x: x,y: 0)
                scrollview.setContentOffset(offset, animated: false)
                storyCover?.lastPlayedSnapIndex = n
                handpickedSnapIndex = n
                snapIndex = n
            } else {
                delegate?.didCompletePreview()
            }
        }
    }
    @objc private func didCompleteProgress() {
        let n = snapIndex + 1
        if let count = storyCover?.stories?.count {
            if n < count {
                //Move to next snap
                let x = n.toFloat * frame.width
                let offset = CGPoint(x: x,y: 0)
                scrollview.setContentOffset(offset, animated: false)
                storyCover?.lastPlayedSnapIndex = n
                direction = .forward
                handpickedSnapIndex = n
                snapIndex = n
            }else {
                stopPlayer()
                delegate?.didCompletePreview()
            }
        }
    }
    
    private func fillUpMissingImageViews(_ sIndex: Int) {
        if sIndex != 0 {
            for i in 0..<sIndex {
                snapIndex = i
            }
            let xValue = sIndex.toFloat * scrollview.frame.width
            scrollview.contentOffset = CGPoint(x: xValue, y: 0)
        }
    }
    
    //Before progress view starts we have to fill the progressView
    private func fillupLastPlayedSnap(_ sIndex: Int) {
        if let snap = storyCover?.stories?[sIndex], snap.kind == .video {
            videoSnapIndex = sIndex
            stopPlayer()
        }
        if let holderView = self.getProgressIndicatorView(with: sIndex),
           let progressView = self.getProgressView(with: sIndex){
            progressView.widthConstraint?.isActive = false
            progressView.widthConstraint = progressView.widthAnchor.constraint(equalTo: holderView.widthAnchor, multiplier: 1.0)
            progressView.widthConstraint?.isActive = true
        }
    }
    
    private func fillupLastPlayedSnaps(_ sIndex: Int) {
        //Coz, we are ignoring the first.snap
        if sIndex != 0 {
            for i in 0..<sIndex {
                if let holderView = self.getProgressIndicatorView(with: i),
                   let progressView = self.getProgressView(with: i){
                    progressView.widthConstraint?.isActive = false
                    progressView.widthConstraint = progressView.widthAnchor.constraint(equalTo: holderView.widthAnchor, multiplier: 1.0)
                    progressView.widthConstraint?.isActive = true
                }
            }
        }
    }
    
    private func clearLastPlayedSnaps(_ sIndex: Int) {
        if let _ = self.getProgressIndicatorView(with: sIndex),
           let progressView = self.getProgressView(with: sIndex) {
            progressView.widthConstraint?.isActive = false
            progressView.widthConstraint = progressView.widthAnchor.constraint(equalToConstant: 0)
            progressView.widthConstraint?.isActive = true
        }
    }
    
    private func clearScrollViewGarbages() {
        scrollview.contentOffset = CGPoint(x: 0, y: 0)
        if scrollview.subviews.count > 0 {
            var i = 0 + snapViewTagIndicator
            var snapViews = [UIView]()
            scrollview.subviews.forEach({ (imageView) in
                if imageView.tag == i {
                    snapViews.append(imageView)
                    i += 1
                }
            })
            if snapViews.count > 0 {
                snapViews.forEach({ (view) in
                    view.removeFromSuperview()
                })
            }
        }
    }
    private func gearupTheProgressors(type: MimeType, playerView: StoryPlayerView? = nil) {
        if let holderView = getProgressIndicatorView(with: snapIndex),
           let progressView = getProgressView(with: snapIndex){
            progressView.story_identifier = self.storyCover?.internalIdentifier
            progressView.snapIndex = snapIndex
            DispatchQueue.main.async {
                if type == .image {
                    progressView.start(with: 5.0, holderView: holderView, completion: {(identifier, snapIndex, isCancelledAbruptly) in
                        print("Completed snapindex: \(snapIndex)")
                        if isCancelledAbruptly == false {
                            self.didCompleteProgress()
                        }
                    })
                }else {
                    //Handled in delegate methods for videos
                }
            }
        }
    }
    
    //MARK:- Internal functions
    func startProgressors() {
        
        DispatchQueue.main.async {
            
            if self.scrollview.subviews.count > 0 {
                let imageView = self.scrollview.subviews.filter{v in v.tag == self.snapIndex + snapViewTagIndicator}.first as? UIImageView
                if imageView?.image != nil && self.storyCover?.isCompletelyVisible == true {
                    self.gearupTheProgressors(type: .image)
                } else {
                    // Didend displaying will call this startProgressors method. After that only isCompletelyVisible get true. Then we have to start the video if that snap contains video.
                    if self.storyCover?.isCompletelyVisible == true {
                        let videoView = self.scrollview.subviews.filter{v in v.tag == self.snapIndex + snapViewTagIndicator}.first as? StoryPlayerView
                        let snap = self.storyCover?.stories?[self.snapIndex]
                        if let vv = videoView, self.storyCover?.isCompletelyVisible == true {
                            self.startPlayer(videoView: vv, with: snap!.mediaUrl)
                        }
                    }
                }
            }
            
            
        }
    }
    
    func getProgressView(with index: Int) -> StoryProgressView? {
        let progressView = storyHeaderView.getProgressView
        if progressView.subviews.count > 0 {
            let pv = getProgressIndicatorView(with: index)?.subviews.first as? StoryProgressView
            guard let currentStory = self.storyCover else {
                fatalError("story not found")
            }
            pv?.story = currentStory
            return pv
        }
        return nil
    }
    func getProgressIndicatorView(with index: Int) -> StoryProgressIndicatorView? {
        let progressView = storyHeaderView.getProgressView
        return progressView.subviews.filter({v in v.tag == index+progressIndicatorViewTag}).first as? StoryProgressIndicatorView ?? nil
    }
    func adjustPreviousSnapProgressorsWidth(with index: Int) {
        fillupLastPlayedSnaps(index)
    }
    
    //MARK: - Public functions
    public func willDisplayCellForZerothIndex(with sIndex: Int, handpickedSnapIndex: Int) {
        self.handpickedSnapIndex = handpickedSnapIndex
        storyCover?.isCompletelyVisible = true
        willDisplayCell(with: handpickedSnapIndex)
    }
    public func willDisplayCell(with sIndex: Int) {
        //Todo:Make sure to move filling part and creating at one place
        //Clear the progressor subviews before the creating new set of progressors.
        storyHeaderView.clearTheProgressorSubviews()
        storyHeaderView.createSnapProgressors()
        fillUpMissingImageViews(sIndex)
        fillupLastPlayedSnaps(sIndex)
        snapIndex = sIndex
        
        //Remove the previous observors
        NotificationCenter.default.removeObserver(self)
        
        // Add the observer to handle application from background to foreground
        NotificationCenter.default.addObserver(self, selector: #selector(self.didEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    public func startSnapProgress(with sIndex: Int) {
        if let indicatorView = getProgressIndicatorView(with: sIndex),
           let pv = getProgressView(with: sIndex) {
            pv.start(with: 5.0, holderView: indicatorView, completion: { (identifier, snapIndex, isCancelledAbruptly) in
                if isCancelledAbruptly == false {
                    self.didCompleteProgress()
                }
            })
        }
    }
    public func pauseSnapProgressors(with sIndex: Int) {
        storyCover?.isCompletelyVisible = false
        getProgressView(with: sIndex)?.pause()
    }
    public func stopSnapProgressors(with sIndex: Int) {
        getProgressView(with: sIndex)?.stop()
    }
    public func resetSnapProgressors(with sIndex: Int) {
        self.getProgressView(with: sIndex)?.reset()
    }
    public func pausePlayer(with sIndex: Int) {
        getVideoView(with: sIndex)?.pause()
    }
    public func stopPlayer() {
        let videoView = getVideoView(with: videoSnapIndex)
        if videoView?.player?.timeControlStatus != .playing {
            getVideoView(with: videoSnapIndex)?.player?.replaceCurrentItem(with: nil)
        }
        videoView?.stop()
        //getVideoView(with: videoSnapIndex)?.player = nil
    }
    public func resumePlayer(with sIndex: Int) {
        getVideoView(with: sIndex)?.play()
    }
    public func didEndDisplayingCell() {
        
    }
    public func resumePreviousSnapProgress(with sIndex: Int) {
        getProgressView(with: sIndex)?.resume()
    }
    public func pauseEntireSnap() {
        let v = getProgressView(with: snapIndex)
        let videoView = scrollview.subviews.filter{v in v.tag == snapIndex + snapViewTagIndicator}.first as? StoryPlayerView
        if videoView != nil {
            v?.pause()
            videoView?.pause()
        }else {
            v?.pause()
        }
    }
    public func resumeEntireSnap() {
        let v = getProgressView(with: snapIndex)
        let videoView = scrollview.subviews.filter{v in v.tag == snapIndex + snapViewTagIndicator}.first as? StoryPlayerView
        if videoView != nil {
            v?.resume()
            videoView?.play()
        }else {
            v?.resume()
        }
    }
    //Used the below function for image retry option
    public func retryRequest(view: UIView, with url: String) {
        if let v = view as? UIImageView {
            v.removeRetryButton()
            self.startRequest(snapView: v, with: url)
        }else if let v = view as? StoryPlayerView {
            v.removeRetryButton()
            self.startPlayer(videoView: v, with: url)
        }
    }
}

//MARK: - Extension|StoryDisplayHeaderProtocol
extension StoryDisplayViewCell: StoryDisplayHeaderProtocol {
    func didTapCloseButton() {
        delegate?.didTapCloseButton()
    }
}

//MARK: - Extension|RetryBtnDelegate
extension StoryDisplayViewCell: RetryBtnDelegate {
    func retryButtonTapped() {
        self.retryRequest(view: retryBtn.superview!, with: retryBtn.contentURL!)
    }
}

//MARK: - Extension|IGPlayerObserverDelegate
extension StoryDisplayViewCell: StoryPlayerObserver {
    
    func didStartPlaying() {
        if let videoView = getVideoView(with: snapIndex), videoView.currentTime <= 0 {
            if videoView.error == nil && (storyCover?.isCompletelyVisible)! == true {
                if let holderView = getProgressIndicatorView(with: snapIndex),
                   let progressView = getProgressView(with: snapIndex) {
                    progressView.story_identifier = self.storyCover?.internalIdentifier
                    progressView.snapIndex = snapIndex
                    if let duration = videoView.currentItem?.asset.duration {
                        if Float(duration.value) > 0 {
                            progressView.start(with: duration.seconds, holderView: holderView, completion: {(identifier, snapIndex, isCancelledAbruptly) in
                                if isCancelledAbruptly == false {
                                    self.videoSnapIndex = snapIndex
                                    self.stopPlayer()
                                    self.didCompleteProgress()
                                } else {
                                    self.videoSnapIndex = snapIndex
                                    self.stopPlayer()
                                }
                            })
                        }else {
                            debugPrint("Player error: Unable to play the video")
                        }
                    }
                }
            }
        }
    }
    func didFailed(withError error: String, for url: URL?) {
        debugPrint("Failed with error: \(error)")
        if let videoView = getVideoView(with: snapIndex), let videoURL = url {
            self.retryBtn = StoryRetryLoaderButton(withURL: videoURL.absoluteString)
            self.retryBtn.translatesAutoresizingMaskIntoConstraints = false
            self.retryBtn.delegate = self
            self.isUserInteractionEnabled = true
            videoView.addSubview(self.retryBtn)
            NSLayoutConstraint.activate([
                self.retryBtn.storyCenterXAnchor.constraint(equalTo: videoView.storyCenterXAnchor),
                self.retryBtn.storyCenterYAnchor.constraint(equalTo: videoView.storyCenterYAnchor)
            ])
        }
    }
    func didCompletePlay() {
        //Video completed
    }
    
    func didTrack(progress: Float) {
        //Delegate already handled. If we just print progress, it will print the player current running time
    }
}

extension StoryDisplayViewCell: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if(gestureRecognizer is UISwipeGestureRecognizer) {
            return true
        }
        return false
    }
}
