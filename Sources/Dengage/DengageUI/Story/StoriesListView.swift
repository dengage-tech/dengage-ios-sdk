import Foundation
import UIKit

public class StoriesListView: UIView {
    
    func setDelegates() {
        collectionView.delegate = controller
        collectionView.dataSource = controller
    }
    
    func setProperties(title: String, styling: StorySetStyling) {
        titleLabel.isHidden = title.isEmpty
        titleLabel.text = title
        titleLabel.textColor = styling.headerTitle.textUIColor
        titleLabel.textAlignment = styling.headerTitle.textAlignment
        if styling.headerTitle.fontWeight == .bold {
            titleLabel.font = UIFont.boldSystemFont(ofSize: styling.headerTitle.fontSize.toFloat)
        } else {
            titleLabel.font = UIFont.systemFont(ofSize: styling.headerTitle.fontSize.toFloat)
        }
        backgroundColor = styling.mobileOverlayUIColor
        collectionView.backgroundColor = styling.mobileOverlayUIColor
        
        let size = styling.headerCover.size
        layout.itemSize = CGSize(width: size + 12, height: size + 32)
        
        installLayoutConstraints(title: title, styling: styling)
    }
    
    public var controller: StoriesListViewController?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    lazy var layout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 80, height: 100)
        return flowLayout
    }()
    
    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.register(StoriesListCell.self, forCellWithReuseIdentifier: StoriesListCell.reuseIdentifier)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        addSubview(collectionView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    private func installLayoutConstraints(title: String, styling: StorySetStyling) {
        
        let titleLabelHeight = title.isEmpty ? 0.0 : (styling.headerTitle.fontSize.toFloat * 1.5)
        let titleBottomAnchor = title.isEmpty ? 0 : 8
        var titleLabelLeftAnchor = 0.0
        var titleLabelRightAnchor = 0.0
        if styling.headerTitle.textAlignment == .left {
            titleLabelLeftAnchor = 8
        } else if styling.headerTitle.textAlignment == .right {
            titleLabelRightAnchor = 8
        }
        
        NSLayoutConstraint.activate([
            titleLabel.sTopAnchor.constraint(equalTo: sTopAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: titleLabelHeight),
            titleLabel.sLeftAnchor.constraint(equalTo: sLeftAnchor, constant: titleLabelLeftAnchor),
            titleLabel.sRightAnchor.constraint(equalTo: sRightAnchor, constant: titleLabelRightAnchor),
            collectionView.sTopAnchor.constraint(equalTo: titleLabel.sBottomAnchor, constant: titleBottomAnchor.toFloat),
            sLeftAnchor.constraint(equalTo: collectionView.sLeftAnchor),
            sTopAnchor.constraint(equalTo: titleLabel.sTopAnchor),
            collectionView.sRightAnchor.constraint(equalTo: sRightAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: styling.headerCover.size.toFloat + 50),
            collectionView.sBottomAnchor.constraint(equalTo: sBottomAnchor),
            
        ])
    }
}
