import UIKit
import UserNotificationsUI

public final class DengageNotificationCarouselView: UIView{
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 128, height: 128)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = .zero
        layout.invalidateLayout()
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        view.register(DengageCarouselCell.self, forCellWithReuseIdentifier: "DengageCarouselCell")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isScrollEnabled = false
        view.isPagingEnabled = false
        return view
    }()
    
    var payloads = [CarouselMessage]()
    var currentIndex : Int = 0
    var bestAttemptContent: UNMutableNotificationContent?
    var userInfo: [AnyHashable: Any]?
    var targetURL: URL?
    
    init() {
        super.init(frame: .zero)
        addSubview(collectionView)
        self.isUserInteractionEnabled = true
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        collectionView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
        let swipeRight:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.scrollPreviousItem))
        swipeRight.direction = .right

        let swipeLeft:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.scrollNextItem))
        swipeLeft.direction = .left
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(swipeRight)
        self.addGestureRecognizer(swipeLeft)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func scrollNextItem() {
        self.currentIndex == (self.payloads.count - 1) ? (self.currentIndex = 0) : ( self.currentIndex += 1 )
        arrangeContentInset(for: .right)
    }

    @objc private func scrollPreviousItem() {
        self.currentIndex == 0 ? (self.currentIndex = self.payloads.count - 1) : ( self.currentIndex -= 1 )
        arrangeContentInset(for: .left)
    }
    
    private func arrangeContentInset(for position: UICollectionView.ScrollPosition){
        let indexPath = IndexPath(row: self.currentIndex, section: 0)
        let isLastElement = (indexPath.row == 0 || indexPath.row == self.payloads.count - 1)
        self.collectionView.contentInset.right = isLastElement ? 10.0 : 20.0
        self.collectionView.contentInset.left = isLastElement ? 10.0 : 20.0
        self.collectionView.scrollToItem(at: indexPath, at: position, animated: true)
    }
    
    public static func create() -> DengageNotificationCarouselView {
      let view = DengageNotificationCarouselView()
      return view
    }
}

extension DengageNotificationCarouselView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.payloads.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DengageCarouselCell", for: indexPath) as! DengageCarouselCell
        cell.populateUI(with: payloads[indexPath.item])
        cell.layer.cornerRadius = 8.0
        return cell
    }
}

extension DengageNotificationCarouselView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.collectionView.frame.width
        let cond = (indexPath.row == 0 || indexPath.row == self.payloads.count - 1)
        let cellWidth = cond ? (width - 30) : (width - 40)
        return CGSize(width: cellWidth, height: width - 20.0)
    }
}

extension DengageNotificationCarouselView: UICollectionViewDelegate{
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let url = URL(string: payloads[indexPath.item].targetURL ?? "") ?? targetURL else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

extension DengageNotificationCarouselView{
    public func didReceive(_ notification: UNNotification) {
        self.bestAttemptContent = (notification.request.content.mutableCopy() as? UNMutableNotificationContent)
        guard let userInfo = bestAttemptContent?.userInfo,
              let contents = userInfo["carouselContent"] as? [AnyObject] else { return }
        self.userInfo = userInfo
        self.targetURL = URL(string: (userInfo["targetUrl"] as? String) ?? "")
        let carouselContents = contents.compactMap{$0 as? NSDictionary}.compactMap(CarouselMessage.init(with:))
        self.payloads = carouselContents
        DispatchQueue.main.async {
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
            self.collectionView.contentInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
            self.collectionView.reloadData()
        }
    }

    public func didReceive(_ response: UNNotificationResponse,
                           completionHandler completion:
        @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        if response.actionIdentifier == "NEXT_ACTION" {
            self.scrollNextItem()
            completion(UNNotificationContentExtensionResponseOption.doNotDismiss)
        } else if response.actionIdentifier == "PREVIOUS_ACTION" {
            self.scrollPreviousItem()
            completion(UNNotificationContentExtensionResponseOption.doNotDismiss)
        } else {
            completion(UNNotificationContentExtensionResponseOption.dismissAndForwardAction)
        }
    }
}
