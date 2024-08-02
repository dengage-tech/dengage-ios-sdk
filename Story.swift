
import Foundation
import UIKit

class GradientBorderImageView: UIImageView {
    var gradientLayer: CAGradientLayer!
    var shapeLayer: CAShapeLayer!

    override func layoutSubviews() {
        super.layoutSubviews()

        // Create a gradient layer
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [UIColor.blue.cgColor, UIColor.green.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)

        // Create a shape layer
        shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = 10
        shapeLayer.path = UIBezierPath(ovalIn: bounds).cgPath
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = UIColor.black.cgColor
        gradientLayer.mask = shapeLayer

        layer.addSublayer(gradientLayer)
    }
}


class CircleImageView: UIView {
    var imageView: GradientBorderImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        imageView = GradientBorderImageView(frame: bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        addSubview(imageView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        imageView.layer.cornerRadius = bounds.width / 2
    }
}


public protocol LayoutAttributesAnimator {
    func animate(collectionView: UICollectionView, attributes: AnimatedCollectionViewLayoutAttributes)
}

open class AnimatedCollectionViewLayout: UICollectionViewFlowLayout {
    open var animator: LayoutAttributesAnimator?
    open override class var layoutAttributesClass: AnyClass {
        return AnimatedCollectionViewLayoutAttributes.self
    }
    open override func layoutAttributesForElements(in rect: CGRect)
    -> [UICollectionViewLayoutAttributes]?
    {
        return super.layoutAttributesForElements(in: rect)?.compactMap {
            $0.copy() as? AnimatedCollectionViewLayoutAttributes
        }.map { self.transformLayoutAttributes($0) }
    }
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    private var focusedIndexPath: IndexPath?
    override open func prepare(forAnimatedBoundsChange oldBounds: CGRect) {
        super.prepare(forAnimatedBoundsChange: oldBounds)
        focusedIndexPath = collectionView?.indexPathsForVisibleItems.first
    }
    override open func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint)
    -> CGPoint
    {
        guard let indexPath = focusedIndexPath, let attributes = layoutAttributesForItem(at: indexPath),
              let collectionView = collectionView
        else { return super.targetContentOffset(forProposedContentOffset: proposedContentOffset) }
        return CGPoint(
            x: attributes.frame.origin.x - collectionView.contentInset.left,
            y: attributes.frame.origin.y - collectionView.contentInset.top)
    }
    override open func finalizeAnimatedBoundsChange() {
        super.finalizeAnimatedBoundsChange()
        focusedIndexPath = nil
    }
    private func transformLayoutAttributes(_ attributes: AnimatedCollectionViewLayoutAttributes)
    -> UICollectionViewLayoutAttributes
    {
        guard let collectionView = self.collectionView else { return attributes }
        let a = attributes
        let distance: CGFloat
        let itemOffset: CGFloat
        if scrollDirection == .horizontal {
            distance = collectionView.frame.width
            itemOffset = a.center.x - collectionView.contentOffset.x
            a.startOffset = (a.frame.origin.x - collectionView.contentOffset.x) / a.frame.width
            a.endOffset =
            (a.frame.origin.x - collectionView.contentOffset.x - collectionView.frame.width)
            / a.frame.width
        } else {
            distance = collectionView.frame.height
            itemOffset = a.center.y - collectionView.contentOffset.y
            a.startOffset = (a.frame.origin.y - collectionView.contentOffset.y) / a.frame.height
            a.endOffset =
            (a.frame.origin.y - collectionView.contentOffset.y - collectionView.frame.height)
            / a.frame.height
        }
        a.scrollDirection = scrollDirection
        a.middleOffset = itemOffset / distance - 0.5
        if a.contentView == nil,
           let c = collectionView.cellForItem(at: attributes.indexPath)?.contentView
        {
            a.contentView = c
        }
        animator?.animate(collectionView: collectionView, attributes: a)
        return a
    }
}

open class AnimatedCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
    public var contentView: UIView?
    public var scrollDirection: UICollectionView.ScrollDirection = .vertical
    public var startOffset: CGFloat = 0
    public var middleOffset: CGFloat = 0
    public var endOffset: CGFloat = 0
    open override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! AnimatedCollectionViewLayoutAttributes
        copy.contentView = contentView
        copy.scrollDirection = scrollDirection
        copy.startOffset = startOffset
        copy.middleOffset = middleOffset
        copy.endOffset = endOffset
        return copy
    }
    open override func isEqual(_ object: Any?) -> Bool {
        guard let o = object as? AnimatedCollectionViewLayoutAttributes else { return false }
        return super.isEqual(o) && o.contentView == contentView && o.scrollDirection == scrollDirection
        && o.startOffset == startOffset && o.middleOffset == middleOffset && o.endOffset == endOffset
    }
}

public struct CubeAttributesAnimator: LayoutAttributesAnimator {
    public var perspective: CGFloat
    public var totalAngle: CGFloat
    public init(perspective: CGFloat = -1 / 500, totalAngle: CGFloat = .pi / 2) {
        self.perspective = perspective
        self.totalAngle = totalAngle
    }
    public func animate(
        collectionView: UICollectionView, attributes: AnimatedCollectionViewLayoutAttributes
    ) {
        let position = attributes.middleOffset
        if abs(position) >= 1 {
            attributes.contentView?.layer.transform = CATransform3DIdentity
        } else if attributes.scrollDirection == .horizontal {
            let rotateAngle = totalAngle * position
            var transform = CATransform3DIdentity
            transform.m34 = perspective
            transform = CATransform3DRotate(transform, rotateAngle, 0, 1, 0)
            UIView.animate(
                withDuration: 0.3,
                animations: {
                    attributes.contentView?.subviews.first?.isUserInteractionEnabled = false
                    attributes.contentView?.layer.transform = transform
                }
            ) { attributes.contentView?.subviews.first?.isUserInteractionEnabled = $0 }
            attributes.contentView?.keepCenterAndApplyAnchorPoint(
                CGPoint(x: position > 0 ? 0 : 1, y: 0.5))
        } else {
            let rotateAngle = totalAngle * position
            var transform = CATransform3DIdentity
            transform.m34 = perspective
            transform = CATransform3DRotate(transform, rotateAngle, -1, 0, 0)
            UIView.animate(
                withDuration: 0.3,
                animations: {
                    attributes.contentView?.subviews.first?.isUserInteractionEnabled = false
                    attributes.contentView?.layer.transform = transform
                }
            ) { attributes.contentView?.subviews.first?.isUserInteractionEnabled = $0 }
            attributes.contentView?.keepCenterAndApplyAnchorPoint(
                CGPoint(x: 0.5, y: position > 0 ? 0 : 1))
        }
    }
}


final class StoriesListCell: UICollectionViewCell {
    public var storyCover: StoryCover? {
        didSet {
            storyNameLabel.text = storyCover?.name
            if let imgUrl = storyCover?.imgUrl {
                circleImageView.imageView.setImage(url: imgUrl)
            }
        }
    }
    
    private let circleImageView: CircleImageView = {
        let roundedView = CircleImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        roundedView.translatesAutoresizingMaskIntoConstraints = false
        return roundedView
    }()
    
    private let storyNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(circleImageView)
        addSubview(storyNameLabel)
        installLayoutConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    private func installLayoutConstraints() {
        NSLayoutConstraint.activate([
            circleImageView.widthAnchor.constraint(equalToConstant: 68),
            circleImageView.heightAnchor.constraint(equalToConstant: 68),
            circleImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            circleImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            storyNameLabel.leftAnchor.constraint(equalTo: leftAnchor),
            storyNameLabel.rightAnchor.constraint(equalTo: rightAnchor),
            storyNameLabel.topAnchor.constraint(equalTo: circleImageView.bottomAnchor, constant: 2),
            storyNameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            bottomAnchor.constraint(equalTo: storyNameLabel.bottomAnchor, constant: 8),
        ])
        layoutIfNeeded()
    }
}


private let isClearCacheEnabled = true

public final class StoriesListViewController: UIViewController {
    
    public var _view: StoriesListView { return view as! StoriesListView }
    private var viewModel: StoriesListViewModel = StoriesListViewModel()
    
    //MARK: - Overridden functions
    public override func loadView() {
        super.loadView()
        //view = StoriesListView(frame: UIScreen.main.bounds)
        view = StoriesListView(frame: UIScreen.main.bounds)
        _view.collectionView.delegate = self
        _view.collectionView.dataSource = self
    }
    public override func viewDidLoad() {
        super.viewDidLoad()
        // TODO:
        automaticallyAdjustsScrollViewInsets = false
    }
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    @objc private func clearImageCache() {
        StoryCache.shared.removeAllObjects()
        StorySet.removeAllVideoFilesFromCache()
        showAlert(withMsg: "Images & Videos are deleted from cache")
    }
    
    private func showAlert(withMsg: String) {
        let alertController = UIAlertController(title: withMsg, message: nil, preferredStyle: .alert)
        present(alertController, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                alertController.dismiss(animated: true, completion: nil)
            }
        }
    }
    
}

extension StoriesListViewController: UICollectionViewDelegate, UICollectionViewDataSource,
                                     UICollectionViewDelegateFlowLayout
{
    public func collectionView(
        _ collectionView: UICollectionView, numberOfItemsInSection section: Int
    )
    -> Int
    {
        return viewModel.numberOfItemsInSection(section)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
    -> UICollectionViewCell
    {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: StoriesListCell.reuseIdentifier, for: indexPath) as? StoriesListCell
        else { fatalError() }
        let story = viewModel.cellForItemAt(indexPath: indexPath)
        cell.storyCover = story
        return cell
    }
    
    public func collectionView(
        _ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath
    ) {
        
        DispatchQueue.main.async {
            if let storiesList = self.viewModel.getStories() {
                
                var stories_copy = storiesList.data.covers!
                
                for index in stories_copy.indices {
                    stories_copy[index].lastPlayedSnapIndex = 0
                    stories_copy[index].isCompletelyVisible = false
                    stories_copy[index].isCancelledAbruptly = false
                }
                
                let storyPreviewScene = StoryDisplayViewController.init(layout: StoryLayoutType(),
                    storyCovers: stories_copy, handPickedStoryIndex: indexPath.row, handPickedSnapIndex: 0)
                
                //TODO:
                //storyPreviewScene.view.backgroundColor = .cyan
                storyPreviewScene.modalPresentationStyle = .fullScreen
                
                //self.present(storyPreviewScene, animated: true, completion: nil)
                self.getRootViewController()?.present(storyPreviewScene, animated: true, completion: nil)
            }
        }
        
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: 80, height: 100)
    }
    
    
    func getRootViewController() -> UIViewController? {
        guard let sharedUIApplication =  UIApplication.perform(NSSelectorFromString("sharedApplication"))?.takeUnretainedValue() else {
            return nil
        }
        if let rootViewController = sharedUIApplication.keyWindow?.rootViewController {
            return getVisibleViewController(rootViewController)
        }
        return nil
    }

    private func getVisibleViewController(_ vc: UIViewController?) -> UIViewController? {
        if vc is UINavigationController {
            return getVisibleViewController((vc as? UINavigationController)?.visibleViewController)
        } else if vc is UITabBarController {
            return getVisibleViewController((vc as? UITabBarController)?.selectedViewController)
        } else {
            if let pvc = vc?.presentedViewController {
                return getVisibleViewController(pvc.presentedViewController)
            } else {
                return vc
            }
        }
    }
}


struct StoriesListViewModel {
    
    private let stories: StorySet? = {
        let storiesList = StorySet(
            id: UUID().uuidString,
            data: StoriesListData(
                title: "Stories",
                covers: [
                    StoryCover(
                        id: UUID().uuidString,
                        imgUrl:
                            "https://ccn.waag.org/drupal/sites/default/files/2018-03/campaign-blog-graphic-01-1080x675.jpg",
                        name: "Bruce",
                        stories: [
                            Story(
                                id: UUID().uuidString,
                                mediaUrl:
                                    "https://ccn.waag.org/drupal/sites/default/files/2018-03/campaign-blog-graphic-01-1080x675.jpg",
                                name: "Xavier", bgColors: nil,
                                storyDate: .pi),
                            Story(
                                id: UUID().uuidString,
                                mediaUrl:
                                    "https://ccn.waag.org/drupal/sites/default/files/2018-03/campaign-blog-graphic-01-1080x675.jpg",
                                name: "Xavier", bgColors: nil,
                                storyDate: .pi)
                        ]),
                    StoryCover(
                        id: UUID().uuidString,
                        imgUrl:
                            "https://dengage-cdn.azureedge.net/90db7e2a-5839-53cd-605f-9d3ffc328e21/amazing-animal-beautiful-beautifull.jpg",
                        name: "Steve",
                        stories: [
                            Story(
                                id: UUID().uuidString,
                                mediaUrl:
                                    "https://dengage-cdn.azureedge.net/90db7e2a-5839-53cd-605f-9d3ffc328e21/Untitled%20design.jpg",
                                name: "Leo", bgColors: nil,
                                storyDate: .pi),
                            Story(
                                id: UUID().uuidString,
                                mediaUrl:
                                    "https://db62cod6cnasq.cloudfront.net/user-media/11637/afce82ca8203e3f4410067a07da31e89.mp4",
                                name: "Kazım", bgColors: nil,
                                storyDate: .pi),
                            Story(
                                id: UUID().uuidString,
                                mediaUrl:
                                    "https://dengage-cdn.azureedge.net/90db7e2a-5839-53cd-605f-9d3ffc328e21/egemen-story/result.png",
                                name: "Mahsun", bgColors: nil,
                                storyDate: .pi),
                        ]),
                    StoryCover(
                        id: UUID().uuidString,
                        imgUrl:
                            "https://dengage-cdn.azureedge.net/90db7e2a-5839-53cd-605f-9d3ffc328e21/amazing-animal-beautiful-beautifull.jpg",
                        name: "Steve",
                        stories: [
                            Story(
                                id: UUID().uuidString,
                                mediaUrl:
                                    "https://dengage-cdn.azureedge.net/90db7e2a-5839-53cd-605f-9d3ffc328e21/Untitled%20design.jpg",
                                name: "Leo", bgColors: nil,
                                storyDate: .pi),
                        ]),
                    StoryCover(
                        id: UUID().uuidString,
                        imgUrl:
                            "https://dengage-cdn.azureedge.net/90db7e2a-5839-53cd-605f-9d3ffc328e21/amazing-animal-beautiful-beautifull.jpg",
                        name: "Steve",
                        stories: [
                            Story(
                                id: UUID().uuidString,
                                mediaUrl:
                                    "https://dengage-cdn.azureedge.net/90db7e2a-5839-53cd-605f-9d3ffc328e21/Untitled%20design.jpg",
                                name: "Leo", bgColors: nil,
                                storyDate: .pi),
                        ]),
                    StoryCover(
                        id: UUID().uuidString,
                        imgUrl:
                            "https://dengage-cdn.azureedge.net/90db7e2a-5839-53cd-605f-9d3ffc328e21/amazing-animal-beautiful-beautifull.jpg",
                        name: "Steve",
                        stories: [
                            Story(
                                id: UUID().uuidString,
                                mediaUrl:
                                    "https://dengage-cdn.azureedge.net/90db7e2a-5839-53cd-605f-9d3ffc328e21/Untitled%20design.jpg",
                                name: "Leo", bgColors: nil,
                                storyDate: .pi),
                        ]),
                    StoryCover(
                        id: UUID().uuidString,
                        imgUrl:
                            "https://dengage-cdn.azureedge.net/90db7e2a-5839-53cd-605f-9d3ffc328e21/amazing-animal-beautiful-beautifull.jpg",
                        name: "Steve",
                        stories: [
                            Story(
                                id: UUID().uuidString,
                                mediaUrl:
                                    "https://dengage-cdn.azureedge.net/90db7e2a-5839-53cd-605f-9d3ffc328e21/Untitled%20design.jpg",
                                name: "Leo", bgColors: nil,
                                storyDate: .pi),
                            Story(
                                id: UUID().uuidString,
                                mediaUrl:
                                    "https://v.ftcdn.net/04/99/78/24/700_F_499782443_HSjDqbTd8oQBQV8wr7cwhO4FoS6o8Vjv_ST.mp4",
                                name: "Video", bgColors: nil,
                                storyDate: .pi),
                        ]),
                ]))
        return storiesList
    }()
    
    public func getStories() -> StorySet? {
        return stories
    }
    public func numberOfItemsInSection(_ section: Int) -> Int {
        stories?.data.covers?.count ?? 0
    }
    public func cellForItemAt(indexPath: IndexPath) -> StoryCover? {
        if indexPath.item < stories?.data.covers?.count ?? 0 {
            return stories?.data.covers?[indexPath.item]
        } else {
            fatalError("Stories Index mis-matched :(")
        }
    }

}

struct StoryAppUtility {
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        /*
         if let delegate = UIApplication.shared.delegate as? AppDelegate {
         delegate.orientationLock = orientation
         }
         */
    }
    
    /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
    static func lockOrientation(
        _ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation: UIInterfaceOrientation
    ) {
        self.lockOrientation(orientation)
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        UINavigationController.attemptRotationToDeviceOrientation()
    }
    
}



class StoryCache: NSCache<AnyObject, AnyObject> {
    static let shared = StoryCache()
    private override init() {
        super.init()
        totalCostLimit = 1024 * 1024 * 100  // 100 Megabytes
    }
}

class StoryVideoCacheManager {
    
    static let shared = StoryVideoCacheManager()
    
    private let fileManager = FileManager.default
    private var mainDirectoryUrl: URL? {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
    }
    
    func getCachedFile(for stringUrl: String, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let url = URL(string: stringUrl),
              let file = mainDirectoryUrl?.appendingPathComponent(url.lastPathComponent)
        else {
            completion(.failure(VideoError.fileRetrieveError))
            return
        }
        
        if fileManager.fileExists(atPath: file.path) {
            completion(.success(file))
        } else {
            downloadVideo(from: url, to: file, completion: completion)
        }
    }
    
    func clearCache(for urlString: String? = nil) {
        guard let cacheURL = mainDirectoryUrl else { return }
        
        do {
            let directoryContents = try fileManager.contentsOfDirectory(
                at: cacheURL, includingPropertiesForKeys: nil)
            if let urlString = urlString, let url = URL(string: urlString) {
                try fileManager.removeItem(at: url)
            } else {
                for fileUrl in directoryContents {
                    try fileManager.removeItem(at: fileUrl)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func downloadVideo(
        from url: URL, to destination: URL, completion: @escaping (Result<URL, Error>) -> Void
    ) {
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: url)
                try data.write(to: destination, options: .atomic)
                DispatchQueue.main.async { completion(.success(destination)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(VideoError.downloadError)) }
            }
        }
    }
}

enum VideoError: Error {
    case downloadError, fileRetrieveError
}

extension VideoError: CustomStringConvertible {
    var description: String {
        switch self {
        case .downloadError: return "Can't download video"
        case .fileRetrieveError: return "File not found"
        }
    }
}


protocol StoryDisplayHeaderProtocol: AnyObject {
    func didTapCloseButton()
}

private let maxSnaps = 30

//Identifiers
public let progressIndicatorViewTag = 88
public let progressViewTag = 99

final class StoryDisplayHeaderView: UIView {
    
    public weak var delegate: StoryDisplayHeaderProtocol?
    fileprivate var snapsPerStory: Int = 0
    public var storyCover: StoryCover? {
        didSet {
            snapsPerStory =
            (storyCover?.stories?.count)! < maxSnaps ? (storyCover?.stories?.count)! : maxSnaps
        }
    }
    fileprivate var progressView: UIView?
    internal let snaperImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = imageView.frame.height / 2
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private let detailView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let snaperNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }()
    internal let lastUpdatedLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }()
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        if let crossImage = UIImage.drawCrossImage(
            size: CGSize(width: 20, height: 20), lineColor: .white, lineWidth: 2)
        {
            button.setImage(crossImage, for: .normal)
            
        }
        
        //button.setImage(#imageLiteral(resourceName: "ic_close"), for: .normal)
        button.addTarget(self, action: #selector(didTapClose(_:)), for: .touchUpInside)
        return button
    }()
    public var getProgressView: UIView {
        if let progressView = self.progressView {
            return progressView
        }
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        self.progressView = v
        self.addSubview(self.getProgressView)
        return v
    }
    
    //MARK: - Overriden functions
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        applyShadowOffset()
        loadUIElements()
        installLayoutConstraints()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - Private functions
    private func loadUIElements() {
        backgroundColor = .clear
        addSubview(getProgressView)
        addSubview(snaperImageView)
        addSubview(detailView)
        detailView.addSubview(snaperNameLabel)
        detailView.addSubview(lastUpdatedLabel)
        addSubview(closeButton)
    }
    private func installLayoutConstraints() {
        //Setting constraints for progressView
        let pv = getProgressView
        NSLayoutConstraint.activate([
            pv.storyLeftAnchor.constraint(equalTo: self.storyLeftAnchor),
            pv.storyTopAnchor.constraint(equalTo: self.storyTopAnchor, constant: 8),
            self.storyRightAnchor.constraint(equalTo: pv.storyRightAnchor),
            pv.heightAnchor.constraint(equalToConstant: 10),
        ])
        
        //Setting constraints for snapperImageView
        NSLayoutConstraint.activate([
            snaperImageView.widthAnchor.constraint(equalToConstant: 40),
            snaperImageView.heightAnchor.constraint(equalToConstant: 40),
            snaperImageView.storyLeftAnchor.constraint(equalTo: self.storyLeftAnchor, constant: 10),
            snaperImageView.storyCenterYAnchor.constraint(equalTo: self.storyCenterYAnchor),
            detailView.storyLeftAnchor.constraint(
                equalTo: snaperImageView.storyRightAnchor, constant: 10),
        ])
        layoutIfNeeded()  //To make snaperImageView round. Adding this to somewhere else will create constraint warnings.
        
        //Setting constraints for detailView
        NSLayoutConstraint.activate([
            detailView.storyLeftAnchor.constraint(
                equalTo: snaperImageView.storyRightAnchor, constant: 10),
            detailView.storyCenterYAnchor.constraint(equalTo: snaperImageView.storyCenterYAnchor),
            detailView.heightAnchor.constraint(equalToConstant: 40),
            closeButton.storyLeftAnchor.constraint(equalTo: detailView.storyRightAnchor, constant: 10),
        ])
        
        //Setting constraints for closeButton
        NSLayoutConstraint.activate([
            closeButton.storyLeftAnchor.constraint(equalTo: detailView.storyRightAnchor, constant: 10),
            closeButton.storyCenterYAnchor.constraint(equalTo: self.storyCenterYAnchor),
            closeButton.storyRightAnchor.constraint(equalTo: self.storyRightAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 60),
            closeButton.heightAnchor.constraint(equalToConstant: 80),
        ])
        
        //Setting constraints for snapperNameLabel
        NSLayoutConstraint.activate([
            snaperNameLabel.storyLeftAnchor.constraint(equalTo: detailView.storyLeftAnchor),
            lastUpdatedLabel.storyLeftAnchor.constraint(
                equalTo: snaperNameLabel.storyRightAnchor, constant: 10.0),
            snaperNameLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 100),
            snaperNameLabel.storyCenterYAnchor.constraint(equalTo: detailView.storyCenterYAnchor),
        ])
        
        //Setting constraints for lastUpdatedLabel
        NSLayoutConstraint.activate([
            lastUpdatedLabel.storyCenterYAnchor.constraint(equalTo: detailView.storyCenterYAnchor),
            lastUpdatedLabel.storyLeftAnchor.constraint(
                equalTo: snaperNameLabel.storyRightAnchor, constant: 10.0),
        ])
    }
    private func applyShadowOffset() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
    }
    private func applyProperties<T: UIView>(_ view: T, with tag: Int? = nil, alpha: CGFloat = 1.0)
    -> T
    {
        view.layer.cornerRadius = 1
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        if let tagValue = tag {
            view.tag = tagValue
        }
        return view
    }
    
    //MARK: - Selectors
    @objc func didTapClose(_ sender: UIButton) {
        delegate?.didTapCloseButton()
    }
    
    //MARK: - Public functions
    public func clearTheProgressorSubviews() {
        getProgressView.subviews.forEach { v in
            v.subviews.forEach { v in (v as! StoryProgressView).stop() }
            v.removeFromSuperview()
        }
    }
    public func clearAllProgressors() {
        clearTheProgressorSubviews()
        getProgressView.removeFromSuperview()
        self.progressView = nil
    }
    public func clearSnapProgressor(at index: Int) {
        getProgressView.subviews[index].removeFromSuperview()
    }
    public func createSnapProgressors() {
        print("Progressor count: \(getProgressView.subviews.count)")
        let padding: CGFloat = 8  //GUI-Padding
        let height: CGFloat = 3
        var pvIndicatorArray: [StoryProgressIndicatorView] = []
        var pvArray: [StoryProgressView] = []
        
        // Adding all ProgressView Indicator and ProgressView to seperate arrays
        for i in 0..<snapsPerStory {
            let pvIndicator = StoryProgressIndicatorView()
            pvIndicator.translatesAutoresizingMaskIntoConstraints = false
            getProgressView.addSubview(
                applyProperties(pvIndicator, with: i + progressIndicatorViewTag, alpha: 0.2))
            pvIndicatorArray.append(pvIndicator)
            
            let pv = StoryProgressView()
            pv.translatesAutoresizingMaskIntoConstraints = false
            pvIndicator.addSubview(applyProperties(pv))
            pvArray.append(pv)
        }
        // Setting Constraints for all progressView indicators
        for index in 0..<pvIndicatorArray.count {
            let pvIndicator = pvIndicatorArray[index]
            if index == 0 {
                pvIndicator.leftConstraiant = pvIndicator.storyLeftAnchor.constraint(
                    equalTo: self.getProgressView.storyLeftAnchor, constant: padding)
                NSLayoutConstraint.activate([
                    pvIndicator.leftConstraiant!,
                    pvIndicator.storyCenterYAnchor.constraint(
                        equalTo: self.getProgressView.storyCenterYAnchor),
                    pvIndicator.heightAnchor.constraint(equalToConstant: height),
                ])
                if pvIndicatorArray.count == 1 {
                    pvIndicator.rightConstraiant = self.getProgressView.storyRightAnchor.constraint(
                        equalTo: pvIndicator.storyRightAnchor, constant: padding)
                    pvIndicator.rightConstraiant!.isActive = true
                }
            } else {
                let prePVIndicator = pvIndicatorArray[index - 1]
                pvIndicator.widthConstraint = pvIndicator.widthAnchor.constraint(
                    equalTo: prePVIndicator.widthAnchor, multiplier: 1.0)
                pvIndicator.leftConstraiant = pvIndicator.storyLeftAnchor.constraint(
                    equalTo: prePVIndicator.storyRightAnchor, constant: padding)
                NSLayoutConstraint.activate([
                    pvIndicator.leftConstraiant!,
                    pvIndicator.storyCenterYAnchor.constraint(equalTo: prePVIndicator.storyCenterYAnchor),
                    pvIndicator.heightAnchor.constraint(equalToConstant: height),
                    pvIndicator.widthConstraint!,
                ])
                if index == pvIndicatorArray.count - 1 {
                    pvIndicator.rightConstraiant = self.storyRightAnchor.constraint(
                        equalTo: pvIndicator.storyRightAnchor, constant: padding)
                    pvIndicator.rightConstraiant!.isActive = true
                }
            }
        }
        // Setting Constraints for all progressViews
        for index in 0..<pvArray.count {
            let pv = pvArray[index]
            let pvIndicator = pvIndicatorArray[index]
            pv.widthConstraint = pv.widthAnchor.constraint(equalToConstant: 0)
            NSLayoutConstraint.activate([
                pv.storyLeftAnchor.constraint(equalTo: pvIndicator.storyLeftAnchor),
                pv.heightAnchor.constraint(equalTo: pvIndicator.heightAnchor),
                pv.storyTopAnchor.constraint(equalTo: pvIndicator.storyTopAnchor),
                pv.widthConstraint!,
            ])
        }
        snaperNameLabel.text = storyCover?.name
    }
}


public struct StoryLayoutType {
    var animator: LayoutAttributesAnimator {
        return CubeAttributesAnimator(perspective: -1 / 100, totalAngle: .pi / 12)
    }
}
 

class StoryDisplayView: UIView {
    
    var layoutType: StoryLayoutType?
    /**Layout Animate options(ie.choose which kinda animation you want!)*/
    
    lazy var layoutAnimator: (LayoutAttributesAnimator, Bool, Int, Int) = (
        CubeAttributesAnimator(perspective: -1 / 100, totalAngle: .pi / 12), true, 1, 1
    )
    lazy var storiesCollectionViewFlowLayout: AnimatedCollectionViewLayout = {
        let flowLayout = AnimatedCollectionViewLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.animator = layoutAnimator.0
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.sectionInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        return flowLayout
    }()
    lazy var storiesCollectionView: UICollectionView! = {
        let cv = UICollectionView.init(
            frame: CGRect(
                x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height),
            collectionViewLayout: storiesCollectionViewFlowLayout)
        cv.backgroundColor = .black
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.register(
            StoryDisplayViewCell.self, forCellWithReuseIdentifier: StoryDisplayViewCell.reuseIdentifier)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.isPagingEnabled = true
        cv.isPrefetchingEnabled = false
        cv.collectionViewLayout = storiesCollectionViewFlowLayout
        return cv
    }()
    
    //MARK:- Overridden functions
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    convenience init(layoutType: StoryLayoutType) {
        self.init()
        self.layoutType = layoutType
        createUIElements()
        installLayoutConstraints()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - Private functions
    private func createUIElements() {
        backgroundColor = .black
        storiesCollectionView.backgroundColor = .yellow
        addSubview(storiesCollectionView)
    }
    private func installLayoutConstraints() {
        //Setting constraints for snapsCollectionview
        NSLayoutConstraint.activate([
            storyLeftAnchor.constraint(equalTo: storiesCollectionView.storyLeftAnchor),
            storyTopAnchor.constraint(equalTo: storiesCollectionView.storyTopAnchor),
            storiesCollectionView.storyRightAnchor.constraint(equalTo: storyRightAnchor),
            storiesCollectionView.storyBottomAnchor.constraint(equalTo: storyBottomAnchor),
        ])
    }
}





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
        contentView.backgroundColor = .magenta
        scrollview.backgroundColor = .systemOrange
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
        
        //TODO:
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
        
        /**
         Delete if there is any snapview/videoview already present in that frame location. Because of snap delete functionality, snapview/videoview can occupy different frames(created in 2nd position(frame), when 1st postion snap gets deleted, it will move to first position) which leads to weird issues.
         - If only snapViews are there, it will not create any issues.
         - But if story contains both image and video snaps, there will be a chance in same position both snapView and videoView gets created.
         - That's why we need to remove if any snap exists on the same position.
         */
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
                    /// Start progressor only if handpickedSnapIndex matches with snapIndex and the requested image url should be matched with current snapIndex imageurl
                    if(strongSelf.handpickedSnapIndex == strongSelf.snapIndex && url == strongSelf.storyCover!.stories?[strongSelf.snapIndex].mediaUrl) {
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
                        /// Start progressor only if handpickedSnapIndex matches with snapIndex
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
            /*!
             * Based on the tap gesture(X) setting the direction to either forward or backward
             */
            if let snap = storyCover?.stories?[n], snap.kind == .image, getSnapview()?.image == nil {
                //Remove retry button if tap forward or backward if it exists
                if let snapView = getSnapview(), let btn = retryBtn, snapView.subviews.contains(btn) {
                    snapView.removeRetryButton()
                }
                fillupLastPlayedSnap(n)
            }else {
                //Remove retry button if tap forward or backward if it exists
                if let videoView = getVideoView(with: n), let btn = retryBtn, videoView.subviews.contains(btn) {
                    videoView.removeRetryButton()
                }
                if getVideoView(with: n)?.player?.timeControlStatus != .playing {
                    fillupLastPlayedSnap(n)
                }
            }
            if touchLocation.x < scrollview.contentOffset.x + (scrollview.frame.width/2) {
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




import UIKit


final class StoryDisplayViewController: UIViewController, UIGestureRecognizerDelegate {
    
    private var _view: StoryDisplayView!
    
    private(set) var storyCovers: [StoryCover]
    private(set) var handPickedStoryCoverIndex: Int //starts with(i)
    private(set) var handPickedStoryIndex: Int //starts with(i)
    
    private var nStoryIndex: Int = 0 //iteration(i+1)
    private var story_copy: StoryCover?
    private(set) var layoutType: StoryLayoutType
    private(set) var executeOnce = false
    
    private(set) var isTransitioning = false
    private(set) var currentIndexPath: IndexPath?
    
    private let dismissGesture: UISwipeGestureRecognizer = {
        let gesture = UISwipeGestureRecognizer()
        gesture.direction = .down
        return gesture
    }()
    
    
    //MARK: - Overriden functions
    override func loadView() {
        super.loadView()
        _view = StoryDisplayView.init(layoutType: self.layoutType)
        _view.storiesCollectionView.decelerationRate = .fast
        dismissGesture.delegate = self
        dismissGesture.addTarget(self, action: #selector(didSwipeDown(_:)))
        _view.storiesCollectionView.addGestureRecognizer(dismissGesture)
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setup_viewConstraint()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // StoryAppUtility.lockOrientation(.portrait)
        // Or to rotate and lock
        if UIDevice.current.userInterfaceIdiom == .phone {
            //StoryAppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        }
        if !executeOnce {
            DispatchQueue.main.async {
                self._view.storiesCollectionView.delegate = self
                self._view.storiesCollectionView.dataSource = self
                let indexPath = IndexPath(item: self.handPickedStoryCoverIndex, section: 0)
                self._view.storiesCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
                self.handPickedStoryCoverIndex = 0
                self.executeOnce = true
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if UIDevice.current.userInterfaceIdiom == .phone {
            // Don't forget to reset when view is being removed
            //StoryAppUtility.lockOrientation(.all)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        isTransitioning = true
        _view.storiesCollectionView.collectionViewLayout.invalidateLayout()
    }
    init(layout: StoryLayoutType, storyCovers: [StoryCover],handPickedStoryIndex: Int, handPickedSnapIndex: Int = 0) {
        self.layoutType = layout
        self.storyCovers = storyCovers
        self.handPickedStoryCoverIndex = handPickedStoryIndex
        self.handPickedStoryIndex = handPickedSnapIndex
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override var prefersStatusBarHidden: Bool { return true }
    
    
    //MARK: - Selectors
    @objc func didSwipeDown(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func setup_viewConstraint() {
        view.addSubview(_view)
        _view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            _view.leftAnchor.constraint(equalTo: view.storyLeftAnchor,constant: .zero),
            _view.topAnchor.constraint(equalTo: view.storyTopAnchor,constant: .zero),
            _view.rightAnchor.constraint(equalTo: view.storyRightAnchor,constant: .zero),
            _view.bottomAnchor.constraint(equalTo: view.storyBottomAnchor,constant: .zero)
        ])
    }
}

//MARK:- Extension|UICollectionViewDataSource
extension StoryDisplayViewController:UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storyCovers.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryDisplayViewCell.reuseIdentifier, for: indexPath) as? StoryDisplayViewCell else {
            fatalError()
        }
        
        if indexPath.item < storyCovers.count {
            cell.storyCover = storyCovers[indexPath.item]
            cell.delegate = self
            currentIndexPath = indexPath
            nStoryIndex = indexPath.item
            return cell
        }else {
            fatalError("Stories Index mis-matched :(")
        }
        
        
    }
}

//MARK:- Extension|UICollectionViewDelegate
extension StoryDisplayViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? StoryDisplayViewCell else {
            return
        }
        
        //Taking Previous(Visible) cell to store previous story
        let visibleCells = collectionView.visibleCells.sortedArrayByPosition()
        let visibleCell = visibleCells.first as? StoryDisplayViewCell
        if let vCell = visibleCell {
            vCell.storyCover?.isCompletelyVisible = false
            vCell.pauseSnapProgressors(with: (vCell.storyCover?.lastPlayedSnapIndex)!)
            story_copy = vCell.storyCover
        }
        //Prepare the setup for first time story launch
        if story_copy == nil {
            cell.willDisplayCellForZerothIndex(with: cell.storyCover?.lastPlayedSnapIndex ?? 0, handpickedSnapIndex: handPickedStoryIndex)
            return
        }
        if indexPath.item == nStoryIndex {
            let s = storyCovers[nStoryIndex+handPickedStoryCoverIndex]
            cell.willDisplayCell(with: s.lastPlayedSnapIndex)
        }
        /// Setting to 0, otherwise for next story snaps, it will consider the same previous story's handPickedSnapIndex. It will create issue in starting the snap progressors.
        handPickedStoryIndex = 0
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let visibleCells = collectionView.visibleCells.sortedArrayByPosition()
        let visibleCell = visibleCells.first as? StoryDisplayViewCell
        guard let vCell = visibleCell else {return}
        guard let vCellIndexPath = _view.storiesCollectionView.indexPath(for: vCell) else {
            return
        }
        vCell.storyCover?.isCompletelyVisible = true
        
        if vCell.storyCover == story_copy {
            nStoryIndex = vCellIndexPath.item
            if vCell.longPressGestureState == nil {
                vCell.resumePreviousSnapProgress(with: (vCell.storyCover?.lastPlayedSnapIndex)!)
            }
            if (vCell.storyCover?.stories?[vCell.storyCover?.lastPlayedSnapIndex ?? 0])?.kind == .video {
                vCell.resumePlayer(with: vCell.storyCover?.lastPlayedSnapIndex ?? 0)
            }
            vCell.longPressGestureState = nil
        }else {
            if let cell = cell as? StoryDisplayViewCell {
                cell.stopPlayer()
            }
            vCell.startProgressors()
        }
        if vCellIndexPath.item == nStoryIndex {
            vCell.didEndDisplayingCell()
        }
    }
}

//MARK:- Extension|UICollectionViewDelegateFlowLayout
extension StoryDisplayViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
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
        if #available(iOS 11.0, *) {
            return CGSize(width: _view.storiesCollectionView.safeAreaLayoutGuide.layoutFrame.width, height: _view.storiesCollectionView.safeAreaLayoutGuide.layoutFrame.height)
        } else {
            return CGSize(width: _view.storiesCollectionView.frame.width, height: _view.storiesCollectionView.frame.height)
        }
    }
}

//MARK:- Extension|UIScrollViewDelegate<CollectionView>
extension StoryDisplayViewController {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard let vCell = _view.storiesCollectionView.visibleCells.first as? StoryDisplayViewCell else {return}
        vCell.pauseSnapProgressors(with: (vCell.storyCover?.lastPlayedSnapIndex)!)
        vCell.pausePlayer(with: (vCell.storyCover?.lastPlayedSnapIndex)!)
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let sortedVCells = _view.storiesCollectionView.visibleCells.sortedArrayByPosition()
        guard let f_Cell = sortedVCells.first as? StoryDisplayViewCell else {return}
        guard let l_Cell = sortedVCells.last as? StoryDisplayViewCell else {return}
        let f_IndexPath = _view.storiesCollectionView.indexPath(for: f_Cell)
        let l_IndexPath = _view.storiesCollectionView.indexPath(for: l_Cell)
        let numberOfItems = collectionView(_view.storiesCollectionView, numberOfItemsInSection: 0)-1
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
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension StoryDisplayViewController: StoryDisplayProtocol {
    func didCompletePreview() {
        let n = handPickedStoryCoverIndex+nStoryIndex+1
        if n < storyCovers.count {
            story_copy = storyCovers[nStoryIndex+handPickedStoryCoverIndex]
            nStoryIndex = nStoryIndex + 1
            let nIndexPath = IndexPath.init(row: nStoryIndex, section: 0)
            _view.storiesCollectionView.scrollToItem(at: nIndexPath, at: .right, animated: true)
        }else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    func moveToPreviousStory() {
        let n = nStoryIndex+1
        if n <= storyCovers.count && n > 1 {
            story_copy = storyCovers[nStoryIndex+handPickedStoryCoverIndex]
            nStoryIndex = nStoryIndex - 1
            let nIndexPath = IndexPath.init(row: nStoryIndex, section: 0)
            _view.storiesCollectionView.scrollToItem(at: nIndexPath, at: .left, animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    func didTapCloseButton() {
        self.dismiss(animated: true, completion:nil)
    }
}



import Foundation
import UIKit

public enum StoryImageError: Error, CustomStringConvertible {
    
    case invalidImageURL
    case downloadError
    
    public var description: String {
        switch self {
        case .invalidImageURL: return "Invalid Image URL"
        case .downloadError: return "Unable to download image"
        }
    }
}

class StoryImageURLSession {
    
    static let `default` = StoryImageURLSession()
    private var dataTasks = [URLSessionDataTask]()
    
    func downloadImage(from urlString: String, completion: @escaping ImageResponse) {
        guard let url = URL(string: urlString) else {
            completion(.failure(StoryImageError.invalidImageURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                completion(.failure(error ?? StoryImageError.downloadError))
                return
            }
            StoryCache.shared.setObject(image, forKey: urlString as AnyObject)
            completion(.success(image))
        }
        task.resume()
        dataTasks.append(task)
    }
}

public enum StoryImageResult<Value, ErrorType> {
    case success(Value)
    case failure(ErrorType)
}

public typealias ImageResponse = (StoryImageResult<UIImage, Error>) -> Void

protocol StoryImageRequestable {
    func setImage(urlString: String, placeholder: UIImage?, completion: ImageResponse?)
}

extension UIImageView {
    
    func setImage(urlString: String, placeholder: UIImage? = nil, completion: ImageResponse? = nil) {
        image = placeholder
        showActivityIndicator()
        
        if let cachedImage = StoryCache.shared.object(forKey: urlString as AnyObject) as? UIImage {
            hideActivityIndicator()
            image = cachedImage
            completion?(.success(cachedImage))
        } else {
            StoryImageURLSession.default.downloadImage(from: urlString) { [weak self] result in
                self?.handleImageResult(result, completion: completion)
            }
        }
    }
    
    private func handleImageResult(
        _ result: StoryImageResult<UIImage, Error>, completion: ImageResponse?
    ) {
        hideActivityIndicator()
        DispatchQueue.main.async {
            if case .success(let image) = result {
                self.image = image
            }
            completion?(result)
        }
    }
}



import AVFoundation
import AVKit
import UIKit

struct VideoResource {
    let filePath: String
}

enum PlayerStatus {
    case unknown
    case playing
    case failed
    case paused
    case readyToPlay
}

protocol StoryPlayerObserver: AnyObject {
    func didStartPlaying()
    func didCompletePlay()
    func didTrack(progress: Float)
    func didFailed(withError error: String, for url: URL?)
}

protocol PlayerControls: AnyObject {
    func play(with resource: VideoResource)
    func play()
    func pause()
    func stop()
    var playerStatus: PlayerStatus { get }
}

class StoryPlayerView: UIView {
    
    private var timeObserverToken: AnyObject?
    private var playerItemStatusObserver: NSKeyValueObservation?
    private var playerTimeControlStatusObserver: NSKeyValueObservation?
    private var playerLayer: AVPlayerLayer?
    private var playerItem: AVPlayerItem? = nil {
        willSet {
            guard let playerItemStatusObserver = playerItemStatusObserver else { return }
            playerItemStatusObserver.invalidate()
        }
        didSet {
            player?.replaceCurrentItem(with: playerItem)
            playerItemStatusObserver = playerItem?.observe(
                \AVPlayerItem.status, options: [.new, .initial],
                 changeHandler: { [weak self] (item, _) in
                     guard let strongSelf = self else { return }
                     if item.status == .failed {
                         strongSelf.activityIndicator.stopAnimating()
                         if let item = strongSelf.player?.currentItem, let error = item.error,
                            let url = item.asset as? AVURLAsset
                         {
                             strongSelf.playerObserverDelegate?.didFailed(
                                withError: error.localizedDescription, for: url.url)
                         } else {
                             strongSelf.playerObserverDelegate?.didFailed(withError: "Unknown error", for: nil)
                         }
                     }
                 })
        }
    }
    
    var player: AVPlayer? {
        willSet {
            guard let playerTimeControlStatusObserver = playerTimeControlStatusObserver else { return }
            playerTimeControlStatusObserver.invalidate()
        }
        didSet {
            playerTimeControlStatusObserver = player?.observe(
                \AVPlayer.timeControlStatus, options: [.new, .initial],
                 changeHandler: { [weak self] (player, _) in
                     guard let strongSelf = self else { return }
                     if player.timeControlStatus == .playing {
                         strongSelf.activityIndicator.stopAnimating()
                         strongSelf.playerObserverDelegate?.didStartPlaying()
                     } else if player.timeControlStatus == .paused {
                     } else {
                     }
                 })
        }
    }
    var error: Error? {
        return player?.currentItem?.error
    }
    var activityIndicator: UIActivityIndicatorView!
    
    var currentItem: AVPlayerItem? {
        return player?.currentItem
    }
    var currentTime: Float {
        return Float(self.player?.currentTime().value ?? 0)
    }
    
    public weak var playerObserverDelegate: StoryPlayerObserver?
    
    override init(frame: CGRect) {
        activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        super.init(frame: frame)
        setupActivityIndicator()
    }
    required init?(coder aDecoder: NSCoder) {
        activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        super.init(coder: aDecoder)
        setupActivityIndicator()
    }
    override func layoutSubviews() {
        playerLayer?.frame = self.bounds
    }
    deinit {
        if let existingPlayer = player, existingPlayer.observationInfo != nil {
            removeObservers()
        }
    }
    
    func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        backgroundColor = .black
        self.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.storyCenterXAnchor.constraint(equalTo: self.storyCenterXAnchor),
            activityIndicator.storyCenterYAnchor.constraint(equalTo: self.storyCenterYAnchor),
        ])
    }
    func startAnimating() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    func stopAnimating() {
        activityIndicator.startAnimating()
    }
    func removeObservers() {
        cleanUpPlayerPeriodicTimeObserver()
    }
    func cleanUpPlayerPeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    func setupPlayerPeriodicTimeObserver() {
        guard timeObserverToken == nil else { return }
        timeObserverToken =
        player?.addPeriodicTimeObserver(
            forInterval: CMTimeMake(value: 1, timescale: 100), queue: DispatchQueue.main
        ) {
            [weak self] time in
            let timeString = String(format: "%02.2f", CMTimeGetSeconds(time))
            if let currentItem = self?.player?.currentItem {
                let totalTimeString = String(
                    format: "%02.2f", CMTimeGetSeconds(currentItem.asset.duration))
                if timeString == totalTimeString {
                    self?.playerObserverDelegate?.didCompletePlay()
                }
            }
            if let time = Float(timeString) {
                self?.playerObserverDelegate?.didTrack(progress: time)
            }
        } as AnyObject
    }
}

extension StoryPlayerView: PlayerControls {
    
    func play(with resource: VideoResource) {
        
        guard let url = URL(string: resource.filePath) else {
            fatalError("Unable to form URL from resource")
        }
        if let existingPlayer = player {
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.player = existingPlayer
            }
        } else {
            let asset = AVAsset(url: url)
            playerItem = AVPlayerItem(asset: asset)
            player = AVPlayer(playerItem: playerItem)
            playerLayer = AVPlayerLayer(player: player)
            setupPlayerPeriodicTimeObserver()
            if let pLayer = playerLayer {
                pLayer.videoGravity = .resizeAspect
                pLayer.frame = self.bounds
                self.layer.addSublayer(pLayer)
            }
        }
        startAnimating()
        player?.play()
    }
    func play() {
        if let existingPlayer = player {
            existingPlayer.play()
        }
    }
    func pause() {
        if let existingPlayer = player {
            existingPlayer.pause()
        }
    }
    func stop() {
        if let existingPlayer = player {
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                existingPlayer.pause()
                
                if existingPlayer.observationInfo != nil {
                    strongSelf.removeObservers()
                }
                strongSelf.playerItem = nil
                strongSelf.player = nil
                strongSelf.playerLayer?.removeFromSuperlayer()
            }
        } else {
        }
    }
    
    var playerStatus: PlayerStatus {
        if let p = player {
            switch p.status {
            case .unknown: return .unknown
            case .readyToPlay: return .readyToPlay
            case .failed: return .failed
            @unknown default:
                return .unknown
            }
        }
        return .unknown
    }
}


import UIKit

enum ProgressorState {
    case notStarted, paused, running, finished
}

protocol ViewAnimator {
    func start(
        with duration: TimeInterval, holderView: UIView,
        completion: @escaping (_ storyIdentifier: String, _ snapIndex: Int, _ isCancelledAbruptly: Bool)
        -> Void)
    func resume()
    func pause()
    func stop()
    func reset()
}

extension ViewAnimator where Self: StoryProgressView {
    func start(
        with duration: TimeInterval, holderView: UIView,
        completion: @escaping (_ storyIdentifier: String, _ snapIndex: Int, _ isCancelledAbruptly: Bool)
        -> Void
    ) {
        self.state = .running
        self.widthConstraint?.isActive = false
        self.widthConstraint = self.widthAnchor.constraint(equalToConstant: 0)
        self.widthConstraint?.isActive = true
        self.widthConstraint?.constant = holderView.width
        UIView.animate(
            withDuration: duration, delay: 0.0, options: [.curveLinear],
            animations: { self.superview?.layoutIfNeeded() }
        ) { (finished) in
            self.story.isCancelledAbruptly = !finished
            self.state = .finished
            completion(
                self.story_identifier ?? "Unknown", self.snapIndex ?? 0, self.story.isCancelledAbruptly)
        }
    }
    
    func resume() {
        let pausedTime = layer.timeOffset
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
        state = .running
    }
    func pause() {
        let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0.0
        layer.timeOffset = pausedTime
        state = .paused
    }
    func stop() {
        resume()
        layer.removeAllAnimations()
        state = .finished
    }
    func reset() {
        state = .notStarted
        self.story.isCancelledAbruptly = true
        self.widthConstraint?.isActive = false
        self.widthConstraint = self.widthAnchor.constraint(equalToConstant: 0)
        self.widthConstraint?.isActive = true
    }
}

final class StoryProgressView: UIView, ViewAnimator {
    public var story_identifier: String?
    public var snapIndex: Int?
    public var story: StoryCover!
    public var widthConstraint: NSLayoutConstraint?
    public var state: ProgressorState = .notStarted
}

final class StoryProgressIndicatorView: UIView {
    public var widthConstraint: NSLayoutConstraint?
    public var leftConstraiant: NSLayoutConstraint?
    public var rightConstraiant: NSLayoutConstraint?
}





import Foundation
import UIKit

protocol RetryBtnDelegate: AnyObject {
    func retryButtonTapped()
}

public class StoryRetryLoaderButton: UIButton {
    var contentURL: String?
    weak var delegate: RetryBtnDelegate?
    convenience init(withURL url: String) {
        self.init()
        self.backgroundColor = .white
        self.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        //TODO
        //self.setImage(#imageLiteral(resourceName: "ic_retry"), for: .normal)
        if let crossImage = UIImage.drawCircularCrossImage(size: CGSize(width: 60, height: 60), lineColor: .red, lineWidth: 2) {
            self.setImage(crossImage, for: .normal)
        }
        
        self.addTarget(self, action: #selector(didTapRetryBtn), for: .touchUpInside)
        self.contentURL = url
        self.tag = 100
    }
    @objc func didTapRetryBtn() {
        delegate?.retryButtonTapped()
    }
}

extension UIView {
    func removeRetryButton() {
        self.subviews.forEach({v in
            if(v.tag == 100){v.removeFromSuperview()}
        })
    }
    
}





import Foundation
import UIKit

extension UIImageView {
    
    struct ActivityIndicator {
        static var isEnabled = false
        static var style = _style
        static var view = _view
        
        static var _style: UIActivityIndicatorView.Style {
            if #available(iOS 13.0, *) {
                return .large
            } else {
                return .whiteLarge
            }
        }
        
        static var _view: UIActivityIndicatorView {
            if #available(iOS 13.0, *) {
                return UIActivityIndicatorView(style: .large)
            } else {
                return UIActivityIndicatorView(style: .whiteLarge)
            }
        }
    }
    
    public var isActivityEnabled: Bool {
        get {
            guard let value = objc_getAssociatedObject(self, &ActivityIndicator.isEnabled) as? Bool else {
                return false
            }
            return value
        }
        set(newValue) {
            objc_setAssociatedObject(
                self, &ActivityIndicator.isEnabled, newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    public var activityStyle: UIActivityIndicatorView.Style {
        get {
            guard
                let value = objc_getAssociatedObject(self, &ActivityIndicator.style)
                    as? UIActivityIndicatorView.Style
            else {
                if #available(iOS 13.0, *) {
                    return .large
                } else {
                    return .whiteLarge
                }
            }
            return value
        }
        set(newValue) {
            objc_setAssociatedObject(
                self, &ActivityIndicator.style, newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    public var activityIndicator: UIActivityIndicatorView {
        get {
            guard
                let value = objc_getAssociatedObject(self, &ActivityIndicator.view)
                    as? UIActivityIndicatorView
            else {
                if #available(iOS 13.0, *) {
                    return UIActivityIndicatorView(style: .large)
                } else {
                    return UIActivityIndicatorView(style: .whiteLarge)
                }
            }
            return value
        }
        set(newValue) {
            let activityView = newValue
            activityView.hidesWhenStopped = true
            objc_setAssociatedObject(
                self, &ActivityIndicator.view, activityView,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func showActivityIndicator() {
        if isActivityEnabled {
            var isActivityIndicatorFound = false
            DispatchQueue.main.async {
                self.backgroundColor = .black
                self.activityIndicator = UIActivityIndicatorView(style: self.activityStyle)
                self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
                if self.subviews.isEmpty {
                    isActivityIndicatorFound = false
                    self.addSubview(self.activityIndicator)
                    
                } else {
                    for view in self.subviews {
                        if !view.isKind(of: UIActivityIndicatorView.self) {
                            isActivityIndicatorFound = false
                            self.addSubview(self.activityIndicator)
                            break
                        } else {
                            isActivityIndicatorFound = true
                        }
                    }
                }
                if !isActivityIndicatorFound {
                    NSLayoutConstraint.activate([
                        self.activityIndicator.storyCenterXAnchor.constraint(equalTo: self.storyCenterXAnchor),
                        self.activityIndicator.storyCenterYAnchor.constraint(equalTo: self.storyCenterYAnchor),
                    ])
                }
                self.activityIndicator.startAnimating()
            }
        }
    }
    
    func hideActivityIndicator() {
        if isActivityEnabled {
            DispatchQueue.main.async {
                self.backgroundColor = UIColor.white
                self.subviews.forEach({ (view) in
                    if let av = view as? UIActivityIndicatorView {
                        av.stopAnimating()
                    }
                })
            }
        }
    }
}

public enum StoryResult<V, E> {
    case success(V)
    case failure(E)
}

enum ImageStyle: Int {
    case squared, rounded
}

typealias SetImageRequester = (StoryResult<Bool, Error>) -> Void

extension UIImageView: StoryImageRequestable {
    func setImage(url: String, style: ImageStyle = .rounded, completion: SetImageRequester? = nil) {
        image = nil
        isActivityEnabled = true
        layer.masksToBounds = false
        layer.cornerRadius = style == .rounded ? frame.height / 2 : 0
        activityStyle = style == .rounded ? .white : .whiteLarge
        clipsToBounds = true
        setImage(urlString: url) { response in
            if let completion = completion {
                switch response {
                case .success(_):
                    completion(.success(true))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}

extension UIImage {
    static func drawCrossImage(size: CGSize, lineColor: UIColor, lineWidth: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.beginPath()
        context.move(to: .zero)
        context.addLine(to: CGPoint(x: size.width, y: size.height))
        context.move(to: CGPoint(x: size.width, y: 0))
        context.addLine(to: CGPoint(x: 0, y: size.height))
        context.setStrokeColor(lineColor.cgColor)
        context.setLineWidth(lineWidth)
        context.strokePath()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    static func drawCircularCrossImage(size: CGSize, lineColor: UIColor, lineWidth: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        let radius = min(size.width, size.height) / 2 - lineWidth / 2
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        context.beginPath()
        context.setStrokeColor(lineColor.cgColor)
        context.setLineWidth(lineWidth)
        context.addArc(
            center: center, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        context.strokePath()
        let crossInset: CGFloat = size.width / 4
        context.beginPath()
        context.move(to: CGPoint(x: center.x - crossInset, y: center.y - crossInset))
        context.addLine(to: CGPoint(x: center.x + crossInset, y: center.y + crossInset))
        context.move(to: CGPoint(x: center.x + crossInset, y: center.y - crossInset))
        context.addLine(to: CGPoint(x: center.x - crossInset, y: center.y + crossInset))
        context.strokePath()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}



import Foundation
import UIKit

extension UIView {
    
    var storyLeftAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.leftAnchor
        }
        return self.leftAnchor
    }
    var storyRightAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.rightAnchor
        }
        return self.rightAnchor
    }
    var storyTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.topAnchor
        }
        return self.topAnchor
    }
    var storyBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.bottomAnchor
        }
        return self.bottomAnchor
    }
    var storyCenterXAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.centerXAnchor
        }
        return self.centerXAnchor
    }
    var storyCenterYAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.centerYAnchor
        }
        return self.centerYAnchor
    }
    var width: CGFloat {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.layoutFrame.width
        }
        return frame.width
    }
    var height: CGFloat {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.layoutFrame.height
        }
        return frame.height
    }
}

extension UIView {
    func keepCenterAndApplyAnchorPoint(_ point: CGPoint) {
        
        guard layer.anchorPoint != point else { return }
        
        var newPoint = CGPoint(x: bounds.size.width * point.x, y: bounds.size.height * point.y)
        var oldPoint = CGPoint(
            x: bounds.size.width * layer.anchorPoint.x, y: bounds.size.height * layer.anchorPoint.y)
        
        newPoint = newPoint.applying(transform)
        oldPoint = oldPoint.applying(transform)
        
        var c = layer.position
        c.x -= oldPoint.x
        c.x += newPoint.x
        
        c.y -= oldPoint.y
        c.y += newPoint.y
        
        layer.position = c
        layer.anchorPoint = point
    }
}

protocol CellConfigurer: AnyObject {
    static var nib: UINib { get }
    static var reuseIdentifier: String { get }
}

extension CellConfigurer {
    static var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UICollectionViewCell: CellConfigurer {}
extension UITableViewCell: CellConfigurer {}

extension UINib {
    class func nib(with name: String) -> UINib {
        return UINib(nibName: name, bundle: nil)
    }
}

extension Int {
    var toFloat: CGFloat {
        return CGFloat(self)
    }
}

extension Array {
    func sortedArrayByPosition() -> [Element] {
        return sorted(by: { (obj1: Element, obj2: Element) -> Bool in
            
            let view1 = obj1 as! UIView
            let view2 = obj2 as! UIView
            
            let x1 = view1.frame.minX
            let y1 = view1.frame.minY
            let x2 = view2.frame.minX
            let y2 = view2.frame.minY
            
            if y1 != y2 {
                return y1 < y2
            } else {
                return x1 < x2
            }
        })
    }
}

























