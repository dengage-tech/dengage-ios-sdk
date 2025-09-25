
import UIKit
import AVKit

protocol StoryPreviewProtocol: AnyObject {
    func didCompletePreview()
    func moveToPreviousStory()
    func didTapCloseButton()
}

enum SnapMovementDirectionState {
    case forward
    case backward
}

fileprivate let snapViewTagIndicator: Int = 8
private let snapTapPercentageForPrevious: Double = 0.2
private let storyDuration = TimeInterval(10) // 10 seconds

final class StoryDisplayViewCell: UICollectionViewCell, UIScrollViewDelegate {
    
    var storyActionsDelegate: StoryActionsDelegate?
    
    public weak var delegate: StoryPreviewProtocol? {
        didSet { storyHeaderView.delegate = self }
    }
    
    private lazy var storyHeaderView: StoryDisplayHeaderView = {
        let v = StoryDisplayHeaderView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private lazy var snapButton: UIButton = {
        let snapButton = UIButton()
        snapButton.isUserInteractionEnabled = true
        snapButton.layer.cornerRadius = 10
        snapButton.translatesAutoresizingMaskIntoConstraints = false
        snapButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        snapButton.addTarget(self, action: #selector(self.didTapLinkButton), for: .touchUpInside)
        return snapButton
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
    
    public var direction: SnapMovementDirectionState = .forward
    
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
            
            switch direction {
                case .forward:
                    if snapIndex < storyCover?.storiesCount ?? 0 {
                        if let snap = storyCover?.coverStories[snapIndex] {
                            if snap.kind != MimeType.video {
                                if let snapView = getSnapview() {
                                    startRequest(snapView: snapView, url: snap.mediaUrl!, bgColors: snap.gradColors)
                                } else {
                                    let snapView = createSnapView()
                                    startRequest(snapView: snapView, url: snap.mediaUrl!, bgColors: snap.gradColors)
                                }
                            }else {
                                if let videoView = getVideoView(with: snapIndex) {
                                    startPlayer(videoView: videoView, with: snap.mediaUrl!)
                                }else {
                                    let videoView = createVideoView()
                                    startPlayer(videoView: videoView, with: snap.mediaUrl!)
                                }
                            }
                        }
                }
                case .backward:
                    if snapIndex < storyCover?.storiesCount ?? 0 {
                        if let snap = storyCover?.coverStories[snapIndex] {
                            if snap.kind != MimeType.video {
                                if let snapView = getSnapview() {
                                    self.startRequest(snapView: snapView, url: snap.mediaUrl!, bgColors: snap.gradColors)
                                }
                            }else {
                                if let videoView = getVideoView(with: snapIndex) {
                                    startPlayer(videoView: videoView, with: snap.mediaUrl!)
                                }
                                else {
                                    let videoView = self.createVideoView()
                                    self.startPlayer(videoView: videoView, with: snap.mediaUrl!)
                                }
                            }
                        }
                }
            }
        }
    }
    
    public var inAppMessage: InAppMessage?
    
    public var storyCover: StoryCover? {
        didSet {
            storyHeaderView.storyCover = storyCover
            if let mediaUrl = storyCover?.mediaUrl {
                storyHeaderView.snaperImageView.setImage(url: mediaUrl)
            }
        }
    }
    
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
    
    private func loadUIElements() {
        scrollview.delegate = self
        scrollview.isPagingEnabled = true
        scrollview.backgroundColor = .black
        contentView.addSubview(scrollview)
        contentView.addSubview(storyHeaderView)
        contentView.addSubview(snapButton)
        scrollview.addGestureRecognizer(longPress_gesture)
        scrollview.addGestureRecognizer(tap_gesture)
    }
    private func installLayoutConstraints() {

        NSLayoutConstraint.activate([
            scrollview.sLeftAnchor.constraint(equalTo: contentView.sLeftAnchor),
            contentView.sRightAnchor.constraint(equalTo: scrollview.sRightAnchor),
            scrollview.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollview.bottomAnchor),
            scrollview.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1.0),
            scrollview.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 1.0)
        ])
        
        NSLayoutConstraint.activate([
            storyHeaderView.sLeftAnchor.constraint(equalTo: contentView.sLeftAnchor),
            contentView.sRightAnchor.constraint(equalTo: storyHeaderView.sRightAnchor),
            storyHeaderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            storyHeaderView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        NSLayoutConstraint.activate([
            snapButton.bottomAnchor.constraint(equalTo: scrollview.bottomAnchor, constant: -50),
            snapButton.centerXAnchor.constraint(equalTo: scrollview.centerXAnchor)
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
            snapView.topAnchor.constraint(equalTo: scrollview.topAnchor),
            snapView.widthAnchor.constraint(equalTo: scrollview.widthAnchor),
            snapView.heightAnchor.constraint(equalTo: scrollview.heightAnchor),
            scrollview.bottomAnchor.constraint(equalTo: snapView.bottomAnchor)
        ])
        if(snapIndex != 0) {
            NSLayoutConstraint.activate([
                snapView.leadingAnchor.constraint(equalTo: scrollview.leadingAnchor, constant: CGFloat(snapIndex)*scrollview.sWidth)
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
        // TODO: EGEMEN
        //videoView.backgroundColor = storyCover?.stories[snapIndex].gradColors
        
        //let colors = bgColors.count == 0 ? [UIColor.black]: bgColors
        //print("colors", colors)
        
        
        if let gradColors = storyCover?.stories[snapIndex].gradColors {
            if gradColors.count == 1 {
                videoView.backgroundColor = gradColors.first
            } else {
                videoView.backgroundColor = UIColor.fromGradientWithDirection(.topToBottom, frame: self.frame, colors: gradColors)
            }
        }
        

        
        videoView.translatesAutoresizingMaskIntoConstraints = false
        videoView.tag = snapIndex + snapViewTagIndicator
        videoView.playerObserverDelegate = self
        
        scrollview.subviews.filter({$0.tag == snapIndex + snapViewTagIndicator}).first?.removeFromSuperview()
        
        scrollview.addSubview(videoView)
        NSLayoutConstraint.activate([
            videoView.leadingAnchor.constraint(equalTo: (snapIndex == 0) ? scrollview.leadingAnchor : scrollview.subviews[previousSnapIndex].trailingAnchor),
            videoView.topAnchor.constraint(equalTo: scrollview.topAnchor),
            videoView.widthAnchor.constraint(equalTo: scrollview.widthAnchor),
            videoView.heightAnchor.constraint(equalTo: scrollview.heightAnchor),
            scrollview.bottomAnchor.constraint(equalTo: videoView.bottomAnchor)
        ])
        if(snapIndex != 0) {
            NSLayoutConstraint.activate([
                videoView.leadingAnchor.constraint(equalTo: scrollview.leadingAnchor, constant: CGFloat(snapIndex)*scrollview.sWidth),
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
    
    //TODO: EGEMEN: SORUN BURADA SANIRIM: 2 KEZ GİRİYOR BURAYA
    private func startRequest(snapView: UIImageView, url: String, bgColors: [UIColor] = []) {
        snapView.setImage(url: url, bgColors: bgColors, style: .squared) { result in
            
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return}
                switch result {
                    case .success(_):
                        if let storyCover = strongSelf.storyCover, (strongSelf.handpickedSnapIndex == strongSelf.snapIndex
                           && url == storyCover.coverStories[strongSelf.snapIndex].mediaUrl!) {
                            
                            if let inAppMessage = strongSelf.inAppMessage {
                                let story = storyCover.coverStories[strongSelf.snapIndex]
                                strongSelf.storyActionsDelegate?.storyEvent(eventType: .storyDisplay, message: inAppMessage, storyProfileId: storyCover.id
                                                                            , storyProfileName: storyCover.name, storyId: story.id, storyName: story.name, buttonUrl: "")
                            }
                            
                            strongSelf.startProgressors()
                    }
                    case .failure(_):
                        strongSelf.showRetryButton(with: url, for: snapView)
                }
            }
        }
        
        if let storyCover = storyCover, storyCover.storiesCount > snapIndex {
            //print("startRequest")
            //TODO: EGEMEN IMPRESSION EVENT gönder
            //storyActionsDelegate?.storyEvent(eventType: .storyDisplay, message: n, storyProfileId: storyCover.id
            //                                 , storyProfileName: storyCover.name, storyId: "", storyName: "", buttonUrl: "")
            if let cta = storyCover.stories[snapIndex].cta, cta.label.count > 0 {
                snapButton.isHidden = false
                snapButton.setTitle(cta.label, for: .normal)
                snapButton.backgroundColor = cta.bgUIColor
                snapButton.setTitleColor(cta.textUIColor, for: .normal)
            } else {
                snapButton.isHidden = true
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
            self.retryBtn.sCenterXAnchor.constraint(equalTo: snapView.sCenterXAnchor),
            self.retryBtn.sCenterYAnchor.constraint(equalTo: snapView.sCenterYAnchor)
        ])
    }
    private func startPlayer(videoView: StoryPlayerView, with url: String) {

        if scrollview.subviews.count > 0 {
            if storyCover?.isCompletelyVisible == true {
                videoView.startAnimating()
                StoryVideoCacheManager.shared.getFile(for: url) { [weak self] (result) in
                    guard let strongSelf = self else { return }
                    switch result {
                        case .success(let videoURL):
                            if(strongSelf.handpickedSnapIndex == strongSelf.snapIndex) {
                                
                                if let inAppMessage = strongSelf.inAppMessage, let storyCover = strongSelf.storyCover {
                                    let story = storyCover.coverStories[strongSelf.snapIndex]
                                    strongSelf.storyActionsDelegate?.storyEvent(eventType: .storyDisplay, message: inAppMessage, storyProfileId: storyCover.id
                                                                                , storyProfileName: storyCover.name, storyId: story.id, storyName: story.name, buttonUrl: "")
                                }
                                
                                let videoResource = VideoResource(filePath: videoURL.absoluteString)
                                videoView.play(with: videoResource)
                        }
                        case .failure(let error):
                            videoView.stopAnimating()
                            debugPrint("Video error: \(error)")
                    }
                }
            }
            
            if let storyCover = storyCover, storyCover.storiesCount > snapIndex {
                //TODO: EGEMEN IMPRESSION EVENT gönder
                if let cta = storyCover.stories[snapIndex].cta, cta.label.count > 0 {
                    snapButton.isHidden = false
                    snapButton.setTitle(cta.label, for: .normal)
                    snapButton.backgroundColor = cta.bgUIColor
                    snapButton.setTitleColor(cta.textUIColor, for: .normal)
                } else {
                    snapButton.isHidden = true
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
        
        if let snapCount = storyCover?.storiesCount {
            var snpIndex = snapIndex
            if let snap = storyCover?.coverStories[snpIndex], snap.kind == .image, getSnapview()?.image == nil {
                //Remove retry button if tap forward or backward if it exists
                if let snapView = getSnapview(), let btn = retryBtn, snapView.subviews.contains(btn) {
                    snapView.removeRetryButton()
                }
                fillupLastPlayedSnap(snpIndex)
            }else {
                //Remove retry button if tap forward or backward if it exists
                if let videoView = getVideoView(with: snpIndex), let btn = retryBtn, videoView.subviews.contains(btn) {
                    videoView.removeRetryButton()
                }
                if getVideoView(with: snpIndex)?.player?.timeControlStatus != .playing {
                    fillupLastPlayedSnap(snpIndex)
                }
            }
            if touchLocation.x < scrollview.contentOffset.x + (scrollview.frame.width * snapTapPercentageForPrevious ) {
                direction = .backward
                if snapIndex >= 1 && snapIndex <= snapCount {
                    clearLastPlayedSnaps(snpIndex)
                    stopSnapProgressors(with: snpIndex)
                    snpIndex -= 1
                    resetSnapProgressors(with: snpIndex)
                    willMoveToPreviousOrNextSnap(index: snpIndex)
                } else {
                    delegate?.moveToPreviousStory()
                }
            } else {
                if snapIndex >= 0 && snapIndex <= snapCount {
                    //Stopping the current running progressors
                    stopSnapProgressors(with: snpIndex)
                    direction = .forward
                    snpIndex += 1
                    willMoveToPreviousOrNextSnap(index: snpIndex)
                }
            }
        }
    }
    @objc private func didEnterForeground() {
        if let snap = storyCover?.coverStories[snapIndex] {
            if snap.kind == .video {
                let videoView = getVideoView(with: snapIndex)
                startPlayer(videoView: videoView!, with: snap.mediaUrl!)
            }else {
                startSnapProgress(with: snapIndex)
            }
        }
    }
    
    @objc private func didEnterBackground() {
        if let snap = storyCover?.coverStories[snapIndex] {
            if snap.kind == .video {
                stopPlayer()
            }
        }
        resetSnapProgressors(with: snapIndex)
    }
    
    @objc private func didTapLinkButton() {
        if let storyCover = storyCover, let inAppMessage = inAppMessage {
            let story = storyCover.stories[snapIndex]
            
            storyActionsDelegate?.storyEvent(eventType: .storyClick, message: inAppMessage, storyProfileId: storyCover.id, storyProfileName: storyCover.name
                                             , storyId: story.id, storyName: story.name, buttonUrl: story.cta?.iosLink ?? "")
            delegate?.didTapCloseButton()
        }
    }
    
    
    private func willMoveToPreviousOrNextSnap(index: Int) {
        if let count = storyCover?.coverStories.count {
            if index < count {
                //Move to next or previous snap based on index n
                let xPoint = index.toFloat * frame.width
                let offset = CGPoint(x: xPoint,y: 0)
                scrollview.setContentOffset(offset, animated: false)
                storyCover?.lastPlayedSnapIndex = index
                handpickedSnapIndex = index
                snapIndex = index
            } else {
                delegate?.didCompletePreview()
            }
        }
    }
    @objc private func didCompleteProgress() {
        let index = snapIndex + 1
        if let count = storyCover?.coverStories.count {
            if index < count {
                let x = index.toFloat * frame.width
                let offset = CGPoint(x: x,y: 0)
                scrollview.setContentOffset(offset, animated: false)
                storyCover?.lastPlayedSnapIndex = index
                direction = .forward
                handpickedSnapIndex = index
                snapIndex = index
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
        if let snap = storyCover?.coverStories[sIndex], snap.kind == .video {
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
    
    //TODO: EGEMEN: SORUN BURADA SANIRIM: 2 KEZ GİRİYOR BURAYA
    private func gearupTheProgressors(type: MimeType, playerView: StoryPlayerView? = nil) {
        if let holderView = getProgressIndicatorView(with: snapIndex),
            let progressView = getProgressView(with: snapIndex){
            progressView.storyCoverIdentifier = self.storyCover?.id
            progressView.snapIndex = snapIndex
            DispatchQueue.main.async {
                if type == .image {
                    progressView.start(with: storyDuration, holderView: holderView, completion: {(identifier, snapIndex, isCancelledAbruptly) in
                        print("Completed story index: \(snapIndex)")
                        
                        /*
                        if isCancelledAbruptly == false {
                            self.videoSnapIndex = snapIndex
                            self.stopPlayer()
                            self.didCompleteProgress()
                        } else {
                            self.videoSnapIndex = snapIndex
                            self.stopPlayer()
                        }
                         */
                        
                        
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
    
    // TODO: EGEMEN BURADA
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
                        let snap = self.storyCover?.coverStories[self.snapIndex]
                        if let vv = videoView, self.storyCover?.isCompletelyVisible == true {
                            self.startPlayer(videoView: vv, with: snap!.mediaUrl!)
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
            pv?.storyCover = currentStory
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
            pv.start(with: storyDuration, holderView: indicatorView, completion: { (identifier, snapIndex, isCancelledAbruptly) in
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
    public func retryRequest(view: UIView, with url: String) {
        if let v = view as? UIImageView {
            v.removeRetryButton()
            self.startRequest(snapView: v, url: url)
        }else if let v = view as? StoryPlayerView {
            v.removeRetryButton()
            self.startPlayer(videoView: v, with: url)
        }
    }
}

extension StoryDisplayViewCell: StoryPreviewHeaderProtocol {
    func didTapCloseButton() {
        delegate?.didTapCloseButton()
    }
}

extension StoryDisplayViewCell: RetryBtnDelegate {
    func retryButtonTapped() {
        self.retryRequest(view: retryBtn.superview!, with: retryBtn.contentURL!)
    }
}

extension StoryDisplayViewCell: StoryPlayerObserver {
    
    func didStartPlaying() {
        if let videoView = getVideoView(with: snapIndex), videoView.currentTime <= 0 {
            if videoView.error == nil && (storyCover?.isCompletelyVisible)! == true {
                if let holderView = getProgressIndicatorView(with: snapIndex),
                    let progressView = getProgressView(with: snapIndex) {
                    progressView.storyCoverIdentifier = self.storyCover?.id
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
                self.retryBtn.sCenterXAnchor.constraint(equalTo: videoView.sCenterXAnchor),
                self.retryBtn.sCenterYAnchor.constraint(equalTo: videoView.sCenterYAnchor)
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
