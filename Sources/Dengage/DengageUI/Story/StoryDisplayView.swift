import UIKit

public enum StoryLayoutType {
    case cubic
    var animator: LayoutAttributesAnimator {
        switch self {
        case .cubic:return CubeAttributesAnimator(perspective: -1/100, totalAngle: .pi/12)
        }
    }
}

class StoryDisplayView: UIView {
    
    var layoutType: StoryLayoutType?
    
    lazy var layoutAnimator: (LayoutAttributesAnimator, Bool, Int, Int) = (layoutType!.animator, true, 1, 1)
    
    lazy var snapsCollectionViewFlowLayout: AnimatedCollectionViewLayout = {
        let flowLayout = AnimatedCollectionViewLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.animator = layoutAnimator.0
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.sectionInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        return flowLayout
    }()
    
    lazy var snapsCollectionView: UICollectionView! = {
        let cv = UICollectionView.init(frame: CGRect(x: 0,y: 0,width: UIScreen.main.bounds.width,height:  UIScreen.main.bounds.height), collectionViewLayout: snapsCollectionViewFlowLayout)
        cv.backgroundColor = .black
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.register(StoryDisplayViewCell.self, forCellWithReuseIdentifier: StoryDisplayViewCell.reuseIdentifier)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.isPagingEnabled = true
        cv.isPrefetchingEnabled = false
        cv.collectionViewLayout = snapsCollectionViewFlowLayout
        return cv
    }()
    
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
    
    private func createUIElements(){
        //backgroundColor = .black
        addSubview(snapsCollectionView)
    }
    private func installLayoutConstraints(){
        NSLayoutConstraint.activate([
            leftAnchor.constraint(equalTo: snapsCollectionView.leftAnchor),
            topAnchor.constraint(equalTo: snapsCollectionView.topAnchor),
            snapsCollectionView.rightAnchor.constraint(equalTo: rightAnchor),
            snapsCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
}
