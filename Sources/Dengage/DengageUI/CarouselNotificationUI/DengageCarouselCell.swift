import UIKit
final class DengageCarouselCell: UICollectionViewCell{

    private lazy var imageView:UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18)
        label.textColor = textColor
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15)
        label.textColor = textColor
        return label
    }()
    
    var textColor: UIColor{
        if #available(iOS 13.0, *) {
            return .label
        } else {
            return .white
        }
    }
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [imageView,
                                                  titleLabel,
                                                  subtitleLabel])
        view.axis = .vertical
        view.spacing = 2
        view.alignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        contentView.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0).isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func populateUI(with message: CarouselMessage){
        imageView.downloaded(from: message.image)
        titleLabel.text = message.title
        subtitleLabel.text = message.description
    }
}
