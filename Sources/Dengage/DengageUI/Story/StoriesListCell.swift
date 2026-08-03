

import UIKit

final class StoriesListCell: UICollectionViewCell {
    
    
    func setAsLoadingCell() {
        self.storyCoverNameLabel.text = "Loading"
        //self.circleImageView.imageView = Helper.getUIImage(named: "loading")
    }
    
    var storyCover: StoryCover? {
        didSet {
            self.storyCoverNameLabel.text = storyCover?.name
            // Apply per-cover image positioning (fit/fill) per the migration guide.
            switch storyCover?.imagePositioningEnum {
            case .fill:
                self.circleImageView.imageView.contentMode = .scaleAspectFill
            case .fit:
                self.circleImageView.imageView.contentMode = .scaleAspectFit
            case .none:
                break // keep CircleImageView's default
            }
            self.circleImageView.imageView.clipsToBounds = true
            if let mediaUrl = storyCover?.mediaUrl {
                self.circleImageView.imageView.setImage(url: mediaUrl, bgColors: [.clear])
            }
        }
    }
    
    public let circleImageView: CircleImageView = {
        let roundedView = CircleImageView()
        roundedView.translatesAutoresizingMaskIntoConstraints = false
        return roundedView
    }()
    
    private let storyCoverNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        return label
    }()
    
    private var circleImageViewWidthConstraint: NSLayoutConstraint?
    private var circleImageViewHeightConstraint: NSLayoutConstraint?
    
    
    func setProperties(styling: StorySetStyling, storySetId: String) {
        storyCoverNameLabel.textColor = styling.headerCover.textUIColor
        
        if styling.headerCover.fontWeight == .bold {
            storyCoverNameLabel.font = UIFont.boldSystemFont(ofSize: styling.headerCover.fontSize.toFloat)
        } else {
            storyCoverNameLabel.font = UIFont.systemFont(ofSize: styling.headerCover.fontSize.toFloat)
        }
        
        var fillerUIColors = styling.headerCover.fillerUIColors
        let shownStoryCovers = DengageLocalStorage.shared.getShownStoryCoverDic()
        let isShown = storyCover?.shown == true
            || (shownStoryCovers[storySetId]?.contains(storyCover?.id ?? "-") == true)
        if isShown {
            fillerUIColors = [styling.headerCover.passiveUIColor]
        }
        
        circleImageView.setSize(size: styling.headerCover.size)
        circleImageView.setBorder(borderWidth: styling.headerCover.borderWidth
                                  , borderRadius: styling.headerCover.borderRadiusDouble
                                  , fillerUIColors: fillerUIColors)
        
        
        
        if let widthConstraint = circleImageViewWidthConstraint {
            widthConstraint.constant = CGFloat(styling.headerCover.size)
        } else {
            circleImageViewWidthConstraint = circleImageView.widthAnchor.constraint(equalToConstant: CGFloat(styling.headerCover.size))
            circleImageViewWidthConstraint?.isActive = true
        }
        
        if let heightConstraint = circleImageViewHeightConstraint {
            heightConstraint.constant = CGFloat(styling.headerCover.size)
        } else {
            circleImageViewHeightConstraint = circleImageView.heightAnchor.constraint(equalToConstant: CGFloat(styling.headerCover.size))
            circleImageViewHeightConstraint?.isActive = true
        }
        
        self.updateConstraintsIfNeeded()
        
    }
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(circleImageView)
        addSubview(storyCoverNameLabel)
        installLayoutConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    private func installLayoutConstraints() {
        
        let circleSize = 68
        
        circleImageViewWidthConstraint = circleImageView.widthAnchor.constraint(equalToConstant: CGFloat(circleSize))
        circleImageViewHeightConstraint = circleImageView.heightAnchor.constraint(equalToConstant: CGFloat(circleSize))
        
        
        NSLayoutConstraint.activate([
            circleImageViewWidthConstraint!,
            circleImageViewHeightConstraint!,
            circleImageView.sTopAnchor.constraint(equalTo: self.sTopAnchor, constant: 8),
            circleImageView.sCenterXAnchor.constraint(equalTo: self.sCenterXAnchor)])
        
        NSLayoutConstraint.activate([
            storyCoverNameLabel.sLeftAnchor.constraint(equalTo: sLeftAnchor),
            storyCoverNameLabel.sRightAnchor.constraint(equalTo: sRightAnchor),
            storyCoverNameLabel.sTopAnchor.constraint(equalTo: circleImageView.sBottomAnchor, constant: 2),
            storyCoverNameLabel.sCenterXAnchor.constraint(equalTo: sCenterXAnchor),
            sBottomAnchor.constraint(equalTo: storyCoverNameLabel.sBottomAnchor, constant: 2)])
        
        layoutIfNeeded()
    }
}
