
import UIKit
import Dengage

final class InboxMessageTableViewCell: UITableViewCell {

    private lazy var mediaView = MediaImageView()
    private lazy var messageView = MessageView()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [mediaView,messageView])
        view.axis = .horizontal
        view.alignment = .center
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle = .default,
                  reuseIdentifier: String?) {

        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(stackView)
        stackView.fillSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func populateUI(with message:DengageMessage){
        mediaView.imageView.downloaded(from: message.mediaURL)
        messageView.dateLabel.text = message.receiveDate?.description
        messageView.titleLabel.text = message.title
        messageView.messageTextLabel.text = message.message
        self.contentView.backgroundColor = message.isClicked ? #colorLiteral(red: 1, green: 0.983807385, blue: 0, alpha: 0.4312555018) : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
}


extension InboxMessageTableViewCell {
    final class MessageView: UIView {
        
        private(set) lazy var titleLabel: UILabel = {
            let view = UILabel()
            view.font = .systemFont(ofSize: 14)
            view.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            return view
        }()
        
        private(set) lazy var messageTextLabel: UILabel = {
            let view = UILabel()
            view.font = .systemFont(ofSize: 11)
            view.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            return view
        }()
        
        private(set) lazy var dateLabel: UILabel = {
            let view = UILabel()
            view.font = .systemFont(ofSize: 9)
            view.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            view.textAlignment = .right
            return view
        }()
        
        private lazy var topStackView: UIStackView = {
            let view = UIStackView.init(arrangedSubviews: [titleLabel,
                                                           dateLabel])
            view.axis = .horizontal
            view.spacing = 4
            return view
        }()
        
        private lazy var stackView: UIStackView = {
            let view = UIStackView.init(arrangedSubviews: [topStackView,
                                                           messageTextLabel])
            view.axis = .vertical
            view.spacing = 4
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        init(){
            super.init(frame: .zero)
            addSubview(stackView)
            stackView.fillSuperview()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    final class MediaImageView:UIView {
        private(set) lazy var imageView: UIImageView = {
            let view = UIImageView()
            view.contentMode = .scaleAspectFit
            view.sizeAnchor(width: 40, height: 40)
            view.backgroundColor = .gray
            return view
        }()
        
        init() {
            super.init(frame: .zero)
            addSubview(imageView)
            imageView.anchor(leading: leadingAnchor,
                             trailing: trailingAnchor,
                             leadingPadding: 4,
                             trailingPadding: 4)
            imageView.alignCenterYToSuperView()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
