import UIKit


public final class StoryDisplayViewController: UIViewController, UIGestureRecognizerDelegate {
    
    //MARK: - Private Vars
    private var _view: StoryDisplayView!
    private var viewModel: StoryDisplayViewModel?
    
    
    private(set) var inAppMessage: InAppMessage
    
    var storyCovers: [StoryCover] {
        return inAppMessage.data.content.props.storySet?.covers ?? StorySet().covers
    }
    
    
    private(set) var handPickedStoryCoverIndex: Int //starts with(i)
    private(set) var handPickedStoryIndex: Int //starts with(i)
    
    private var nStoryCoverIndex: Int = 0 //iteration(i+1)
    private var storyCoverCopy: StoryCover?
    private(set) var layoutType: StoryLayoutType
    private(set) var executeOnce = false
    
    private(set) var isTransitioning = false
    
    private let dismissGesture: UISwipeGestureRecognizer = {
        let gesture = UISwipeGestureRecognizer()
        gesture.direction = .down
        return gesture
    }()
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    var storyActionsDelegate: StoryActionsDelegate?
    
    public override func loadView() {
        super.loadView()
        _view = StoryDisplayView.init(layoutType: self.layoutType)
        viewModel = StoryDisplayViewModel.init(self.storyCovers)
        _view.snapsCollectionView.decelerationRate = .fast
        dismissGesture.delegate = self
        dismissGesture.addTarget(self, action: #selector(didSwipeDown(_:)))
        _view.snapsCollectionView.addGestureRecognizer(dismissGesture)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setup_viewConstraint()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // AppUtility.lockOrientation(.portrait)
        // Or to rotate and lock
        if !executeOnce {
            DispatchQueue.main.async {
                self._view.snapsCollectionView.delegate = self
                self._view.snapsCollectionView.dataSource = self
                let indexPath = IndexPath(item: self.handPickedStoryCoverIndex, section: 0)
                self._view.snapsCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
                self.handPickedStoryCoverIndex = 0
                self.executeOnce = true
            }
        }
    }
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        isTransitioning = true
        _view.snapsCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    init(layout:StoryLayoutType = .cubic, inAppMessage: InAppMessage, handPickedStoryCoverIndex: Int, handPickedStoryIndex: Int = 0) {
        self.layoutType = layout
        self.inAppMessage = inAppMessage
        self.handPickedStoryCoverIndex = handPickedStoryCoverIndex
        self.handPickedStoryIndex = handPickedStoryIndex
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public override var prefersStatusBarHidden: Bool { return true }
    
    //MARK: - Selectors
    @objc func didSwipeDown(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
 
   private func setup_viewConstraint() {
        view.addSubview(_view)
        _view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            _view.leftAnchor.constraint(equalTo: view.leftAnchor,constant: .zero),
            _view.topAnchor.constraint(equalTo: view.topAnchor,constant: .zero),
            _view.rightAnchor.constraint(equalTo: view.rightAnchor,constant: .zero),
            _view.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: .zero)
        ])
    }
}

//MARK:- Extension|UICollectionViewDataSource
extension StoryDisplayViewController:UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let model = viewModel else {return 0}
        return model.numberOfItemsInSection(section)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryDisplayViewCell.reuseIdentifier, for: indexPath) as? StoryDisplayViewCell else {
            fatalError()
        }
        let storyCover = viewModel?.cellForItemAtIndexPath(indexPath)
        cell.inAppMessage = inAppMessage
        cell.storyCover = storyCover
        cell.delegate = self
        cell.storyActionsDelegate = storyActionsDelegate
        nStoryCoverIndex = indexPath.item
        return cell
    }
}

//MARK:- Extension|UICollectionViewDelegatef
extension StoryDisplayViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? StoryDisplayViewCell else {
            return
        }
        
        //Taking Previous(Visible) cell to store previous story
        let visibleCells = collectionView.visibleCells.sortedArrayByPosition()
        let visibleCell = visibleCells.first as? StoryDisplayViewCell
        if let vCell = visibleCell {
            vCell.storyCover?.isCompletelyVisible = false
            vCell.pauseSnapProgressors(with: (vCell.storyCover?.lastPlayedSnapIndex)!)
            storyCoverCopy = vCell.storyCover
        }
        //Prepare the setup for first time story launch
        if storyCoverCopy == nil {
            if let storyCoverId = cell.storyCover?.id, let storySetId = inAppMessage.data.content.props.storySet?.id {
                storyActionsDelegate?.setStoryCoverShown(storyCoverId: storyCoverId, storySetId: storySetId)
            }
            cell.willDisplayCellForZerothIndex(with: cell.storyCover?.lastPlayedSnapIndex ?? 0, handpickedSnapIndex: handPickedStoryIndex)
            return
        }
        if indexPath.item == nStoryCoverIndex {
            let storyCover = storyCovers[nStoryCoverIndex+handPickedStoryCoverIndex]
            if let storySetId = inAppMessage.data.content.props.storySet?.id {
                storyActionsDelegate?.setStoryCoverShown(storyCoverId: storyCover.id, storySetId: storySetId)
            }
            cell.willDisplayCell(with: storyCover.lastPlayedSnapIndex)
        }
        /// Setting to 0, otherwise for next story snaps, it will consider the same previous story's handPickedSnapIndex. It will create issue in starting the snap progressors.
        handPickedStoryIndex = 0
    }
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let visibleCells = collectionView.visibleCells.sortedArrayByPosition()
        let visibleCell = visibleCells.first as? StoryDisplayViewCell
        guard let vCell = visibleCell else {return}
        guard let vCellIndexPath = _view.snapsCollectionView.indexPath(for: vCell) else {
            return
        }
        vCell.storyCover?.isCompletelyVisible = true
        
        if vCell.storyCover == storyCoverCopy {
            nStoryCoverIndex = vCellIndexPath.item
            if vCell.longPressGestureState == nil {
                vCell.resumePreviousSnapProgress(with: (vCell.storyCover?.lastPlayedSnapIndex)!)
            }
            if (vCell.storyCover?.coverStories[vCell.storyCover?.lastPlayedSnapIndex ?? 0])?.kind == .video {
                vCell.resumePlayer(with: vCell.storyCover?.lastPlayedSnapIndex ?? 0)
            }
            vCell.longPressGestureState = nil
        }else {
            if let cell = cell as? StoryDisplayViewCell {
                cell.stopPlayer()
            }
            vCell.startProgressors()
        }
        if vCellIndexPath.item == nStoryCoverIndex {
            vCell.didEndDisplayingCell()
        }
    }
}

//MARK:- Extension|UICollectionViewDelegateFlowLayout
extension StoryDisplayViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isTransitioning {
            let visibleCells = collectionView.visibleCells.sortedArrayByPosition()
            let visibleCell = visibleCells.first as? StoryDisplayViewCell
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) { [weak self] in
                guard let strongSelf = self,
                    let vCell = visibleCell,
                    let progressIndicatorView = vCell.getProgressIndicatorView(with: vCell.snapIndex),
                    let pv = vCell.getProgressView(with: vCell.snapIndex) else {
                        fatalError("Visible cell or progressIndicatorView or progressView is nil")
                }
                vCell.scrollview.setContentOffset(CGPoint(x: CGFloat(vCell.snapIndex) * collectionView.frame.width, y: 0), animated: false)
                vCell.adjustPreviousSnapProgressorsWidth(with: vCell.snapIndex)
                
                if pv.state == .running {
                    pv.widthConstraint?.constant = progressIndicatorView.frame.width
                }
                strongSelf.isTransitioning = false
            }
        }
        if #available(iOS 13.0, *) {
            return CGSize(width: _view.snapsCollectionView.window?.windowScene?.windows.first?.frame.width ?? 0, height: _view.snapsCollectionView.window?.windowScene?.windows.first?.frame.height ?? 0)
        } else {
            return CGSize(width: _view.snapsCollectionView.frame.width, height: _view.snapsCollectionView.frame.height)
        }
    }
}

//MARK:- Extension|UIScrollViewDelegate<CollectionView>
extension StoryDisplayViewController {
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard let vCell = _view.snapsCollectionView.visibleCells.first as? StoryDisplayViewCell else {return}
        vCell.pauseSnapProgressors(with: (vCell.storyCover?.lastPlayedSnapIndex)!)
        vCell.pausePlayer(with: (vCell.storyCover?.lastPlayedSnapIndex)!)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let sortedVCells = _view.snapsCollectionView.visibleCells.sortedArrayByPosition()
        guard let f_Cell = sortedVCells.first as? StoryDisplayViewCell else {return}
        guard let l_Cell = sortedVCells.last as? StoryDisplayViewCell else {return}
        let f_IndexPath = _view.snapsCollectionView.indexPath(for: f_Cell)
        let l_IndexPath = _view.snapsCollectionView.indexPath(for: l_Cell)
        let numberOfItems = collectionView(_view.snapsCollectionView, numberOfItemsInSection: 0)-1
        if l_IndexPath?.item == 0 {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2) {
                self.dismiss(animated: true, completion: nil)
            }
        }else if f_IndexPath?.item == numberOfItems {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension StoryDisplayViewController: StoryPreviewProtocol {
    
    func didCompletePreview() {
        let n = handPickedStoryCoverIndex + nStoryCoverIndex + 1
        if n < storyCovers.count {
            //Move to next story
            storyCoverCopy = storyCovers[nStoryCoverIndex + handPickedStoryCoverIndex]
            nStoryCoverIndex = nStoryCoverIndex + 1
            let nIndexPath = IndexPath.init(row: nStoryCoverIndex, section: 0)
            //_view.snapsCollectionView.layer.speed = 0;
            _view.snapsCollectionView.scrollToItem(at: nIndexPath, at: .right, animated: true)
            /**@Note:
             Here we are navigating to next snap explictly, So we need to handle the isCompletelyVisible. With help of this Bool variable we are requesting snap. Otherwise cell wont get Image as well as the Progress move :P
             */
        }else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func moveToPreviousStory() {
        //let n = handPickedStoryIndex+nStoryIndex+1
        let n = nStoryCoverIndex + 1
        if n <= storyCovers.count && n > 1 {
            storyCoverCopy = storyCovers[nStoryCoverIndex+handPickedStoryCoverIndex]
            nStoryCoverIndex = nStoryCoverIndex - 1
            let nIndexPath = IndexPath.init(row: nStoryCoverIndex, section: 0)
            _view.snapsCollectionView.scrollToItem(at: nIndexPath, at: .left, animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func didTapCloseButton() {
        self.dismiss(animated: true, completion:nil)
    }
    
}
