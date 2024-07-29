import UIKit

struct Attributes {
    let borderWidth: CGFloat = 0.0 // 2.0
    let borderColor = UIColor.clear// UIColor.white
    let backgroundColor = UIColor.clear
    var size = CGSize(width: 68, height: 68)
    var borderRadius: Double = 0.0
}

public class CircleImageView: UIView {
    private var attributes: Attributes = Attributes()
    lazy var imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.layer.borderWidth = (attributes.borderWidth)
        imgView.layer.borderColor = attributes.borderColor.cgColor
        imgView.clipsToBounds = true
        imgView.contentMode = .scaleAspectFill
        return imgView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        backgroundColor = attributes.backgroundColor
        addSubview(imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        clipsToBounds = true
        backgroundColor = attributes.backgroundColor
        addSubview(imageView)
    }
    public override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height * CGFloat(attributes.borderRadius)
        imageView.frame = CGRect(x: 1, y: 1, width: (attributes.size.width)-2, height: attributes.size.height-2)
        imageView.layer.cornerRadius = imageView.frame.height * CGFloat(attributes.borderRadius)
    }
}

extension CircleImageView {
    
    func setSize(size: Int) {
        self.attributes.size = CGSize(width: size, height: size)
    }
    
    func setBorder(borderWidth: Int, borderRadius: Double, fillerUIColors: [UIColor]) {
        attributes.borderRadius = borderRadius
        let colors: [UIColor] = fillerUIColors
        if colors.count == 1 {
            layer.borderColor = colors.first?.cgColor
        } else {
            layer.borderColor =  UIColor.fromGradientWithDirection(.topLeftToBottomRight, frame: self.frame, colors: colors)?.cgColor
        }
        layer.borderWidth = borderWidth.toFloat
        layer.cornerRadius = frame.height * borderRadius
        imageView.layer.cornerRadius = imageView.frame.height * CGFloat(borderRadius)
    }
}
