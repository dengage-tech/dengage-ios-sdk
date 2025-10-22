

import UIKit

public protocol StoryPreviewHeaderProtocol: AnyObject {
    func didTapCloseButton()
}

private let maxStories = 20
public let progressIndicatorViewTag = 88
public let progressViewTag = 99

public final class StoryDisplayHeaderView: UIView {
    
    //MARK: - iVars
    public weak var delegate:StoryPreviewHeaderProtocol?
    fileprivate var snapsPerStory: Int = 0
    var storyCover: StoryCover? {
        didSet {
            snapsPerStory = (storyCover?.storiesCount ?? 0) < maxStories ? (storyCover?.storiesCount ?? 0) : maxStories
        }
    }
    fileprivate var progressView: UIView?
    
    internal let snaperImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
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
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
       // button.backgroundColor = .orange
        if let crossImage = UIImage.drawCrossImage(
            size: CGSize(width: 20, height: 20), lineColor: .white, lineWidth: 1.5)
        {
            button.setImage(crossImage, for: .normal)
            
        }
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
    private func loadUIElements(){
        backgroundColor = .clear
        addSubview(getProgressView)
        addSubview(snaperImageView)
        addSubview(detailView)
        detailView.addSubview(snaperNameLabel)
        addSubview(closeButton)
    }
    private func installLayoutConstraints(){
        let pv = getProgressView
        NSLayoutConstraint.activate([
            pv.sLeftAnchor.constraint(equalTo: self.sLeftAnchor),
            pv.topAnchor.constraint(equalTo: self.topAnchor),
            self.sRightAnchor.constraint(equalTo: pv.sRightAnchor),
            pv.heightAnchor.constraint(equalToConstant: 10)
            ])
        
        NSLayoutConstraint.activate([
            snaperImageView.widthAnchor.constraint(equalToConstant: 40),
            snaperImageView.heightAnchor.constraint(equalToConstant: 40),
            snaperImageView.sLeftAnchor.constraint(equalTo: self.sLeftAnchor, constant: 10),
            snaperImageView.topAnchor.constraint(equalTo: pv.bottomAnchor, constant: 12),
            detailView.sLeftAnchor.constraint(equalTo: snaperImageView.sRightAnchor, constant: 10)
            ])
        
        layoutIfNeeded() //To make snaperImageView round. Adding this to somewhere else will create constraint warnings.
        NSLayoutConstraint.activate([
            detailView.sLeftAnchor.constraint(equalTo: snaperImageView.sRightAnchor, constant: 10),
            detailView.sCenterYAnchor.constraint(equalTo: snaperImageView.sCenterYAnchor),
            detailView.heightAnchor.constraint(equalToConstant: 40),
            closeButton.sLeftAnchor.constraint(equalTo: detailView.sRightAnchor, constant: 10)
            ])
        NSLayoutConstraint.activate([
            closeButton.sLeftAnchor.constraint(equalTo: detailView.sRightAnchor, constant: 10),
            closeButton.sCenterYAnchor.constraint(equalTo: snaperImageView.sCenterYAnchor),
          //  closeButton.topAnchor.constraint(equalTo:pv.bottomAnchor, constant: 8),
            closeButton.sRightAnchor.constraint(equalTo: self.sRightAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 60),
            closeButton.heightAnchor.constraint(equalToConstant: 60)
            ])
        NSLayoutConstraint.activate([
            snaperNameLabel.sLeftAnchor.constraint(equalTo: detailView.sLeftAnchor),
            snaperNameLabel.sRightAnchor.constraint(equalTo: detailView.sRightAnchor),
            //snaperNameLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 100),
            snaperNameLabel.sCenterYAnchor.constraint(equalTo: detailView.sCenterYAnchor)
            ])
    }
    private func applyShadowOffset() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
    }
    private func applyProperties<T: UIView>(_ view: T, with tag: Int? = nil, alpha: CGFloat = 1.0) -> T {
        view.layer.cornerRadius = 1
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        if let tagValue = tag {
            view.tag = tagValue
        }
        return view
    }
    
    @objc func didTapClose(_ sender: UIButton) {
        delegate?.didTapCloseButton()
    }
    
    public func clearTheProgressorSubviews() {
        getProgressView.subviews.forEach { v in
            v.subviews.forEach{v in (v as! StoryProgressView).stop()}
            v.removeFromSuperview()
        }
    }
    
    public func clearAllProgressors() {
        clearTheProgressorSubviews()
        getProgressView.removeFromSuperview()
        self.progressView = nil
    }
    
    public func clearSnapProgressor(at index:Int) {
        getProgressView.subviews[index].removeFromSuperview()
    }
    
    public func createSnapProgressors(){
        let padding: CGFloat = 8 //GUI-Padding
        let height: CGFloat = 3
        var pvIndicatorArray: [StoryProgressIndicatorView] = []
        var pvArray: [StoryProgressView] = []
        
        // Adding all ProgressView Indicator and ProgressView to seperate arrays
        for i in 0..<snapsPerStory{
            let pvIndicator = StoryProgressIndicatorView()
            pvIndicator.translatesAutoresizingMaskIntoConstraints = false
            getProgressView.addSubview(applyProperties(pvIndicator, with: i+progressIndicatorViewTag, alpha:0.2))
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
                pvIndicator.leftConstraiant = pvIndicator.sLeftAnchor.constraint(equalTo: self.getProgressView.sLeftAnchor, constant: padding)
                NSLayoutConstraint.activate([
                    pvIndicator.leftConstraiant!,
                    pvIndicator.sCenterYAnchor.constraint(equalTo: self.getProgressView.sCenterYAnchor),
                    pvIndicator.heightAnchor.constraint(equalToConstant: height)
                    ])
                if pvIndicatorArray.count == 1 {
                    pvIndicator.rightConstraiant = self.getProgressView.sRightAnchor.constraint(equalTo: pvIndicator.sRightAnchor, constant: padding)
                    pvIndicator.rightConstraiant!.isActive = true
                }
            }else {
                let prePVIndicator = pvIndicatorArray[index-1]
                pvIndicator.widthConstraint = pvIndicator.widthAnchor.constraint(equalTo: prePVIndicator.widthAnchor, multiplier: 1.0)
                pvIndicator.leftConstraiant = pvIndicator.sLeftAnchor.constraint(equalTo: prePVIndicator.sRightAnchor, constant: padding)
                NSLayoutConstraint.activate([
                    pvIndicator.leftConstraiant!,
                    pvIndicator.sCenterYAnchor.constraint(equalTo: prePVIndicator.sCenterYAnchor),
                    pvIndicator.heightAnchor.constraint(equalToConstant: height),
                    pvIndicator.widthConstraint!
                    ])
                if index == pvIndicatorArray.count-1 {
                    pvIndicator.rightConstraiant = self.sRightAnchor.constraint(equalTo: pvIndicator.sRightAnchor, constant: padding)
                    pvIndicator.rightConstraiant!.isActive = true
                }
            }
        }
        for index in 0..<pvArray.count {
            let pv = pvArray[index]
            let pvIndicator = pvIndicatorArray[index]
            pv.widthConstraint = pv.widthAnchor.constraint(equalToConstant: 0)
            NSLayoutConstraint.activate([
                pv.sLeftAnchor.constraint(equalTo: pvIndicator.sLeftAnchor),
                pv.heightAnchor.constraint(equalTo: pvIndicator.heightAnchor),
                pv.topAnchor.constraint(equalTo: pvIndicator.topAnchor),
                pv.widthConstraint!
                ])
        }
        snaperNameLabel.text = storyCover?.name
    }
}
