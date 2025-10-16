
import UIKit

public final class StoriesListViewController: UIViewController {
    
    
    var storyActionsDelegate: StoryActionsDelegate?
    
    weak var collectionView: UICollectionView! {
        didSet {
         
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }

    var inAppMessage: InAppMessage!
    var storySet: StorySet! {
        return inAppMessage.data.content.props.storySet ?? StorySet()
    }
    var publicId: String?
    var contentId: String?
    var storySetLoaded = false
    
    
    func loadInAppMessage(_ inAppMessage: InAppMessage, _ publicId: String?, _ contentId: String?) {
        self.inAppMessage = inAppMessage
        self.publicId = publicId
        self.contentId = contentId
        self.storySetLoaded = true
    }
    
}

extension StoriesListViewController: UICollectionViewDelegate,UICollectionViewDataSource,
                                     UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let covers = storyActionsDelegate?.sortStoryCovers(storyCovers: storySet.covers, storySetId: storySet.id) {
            storySet.covers = covers
        }
        return storySetLoaded ? storySet.covers.count : 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if !storySetLoaded {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:
                                                                    StoriesListCell.reuseIdentifier, for: indexPath)
                    as? StoriesListCell else {
                return UICollectionViewCell()
            }
            cell.setAsLoadingCell()
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:
                                                                    StoriesListCell.reuseIdentifier, for: indexPath)
                    as? StoriesListCell else {
                return UICollectionViewCell()
            }
            
            
            cell.storyCover = storySet.covers[indexPath.row]
            cell.setProperties(styling: storySet.styling, storySetId: storySet.id)
            cell.layoutIfNeeded()
            return cell
        }
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let _ = self.storySet else {return}
        if self.storySet.covers.count == 0 {
            return
        }
        
        let storyCoverId = storySet.covers[indexPath.row].id
        let storySetId = storySet.id
        
        storySet.covers[indexPath.row].shown = true
        storyActionsDelegate?.setStoryCoverShown(storyCoverId: storyCoverId, storySetId: storySetId)

        
        DispatchQueue.main.async {
            
            for index in self.storySet.covers.indices {
                self.storySet.covers[index].lastPlayedSnapIndex = 0
                self.storySet.covers[index].isCompletelyVisible = false
                self.storySet.covers[index].isCancelledAbruptly = false
            }
            
            let storyPreviewScene = StoryDisplayViewController.init(inAppMessage: self.inAppMessage, handPickedStoryCoverIndex:  indexPath.row, handPickedStoryIndex: 0)
            storyPreviewScene.storyActionsDelegate = self.storyActionsDelegate
            storyPreviewScene.modalPresentationStyle = .fullScreen
            Utilities.getRootViewController()?.present(storyPreviewScene, animated: true, completion: collectionView.reloadData)
            
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        let size = storySet.styling.headerCover.size
        
        return CGSize(width: size + 12, height: size + 50)
        
    }
}

