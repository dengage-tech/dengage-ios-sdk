import UIKit
import Dengage

final class InboxChannelMessageTableViewCell: UITableViewCell {

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .boldSystemFont(ofSize: 14)
        view.textColor = .black
        return view
    }()

    private lazy var messageLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 12)
        view.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        view.numberOfLines = 2
        return view
    }()

    private lazy var metaLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 10)
        view.textColor = .darkGray
        return view
    }()

    private lazy var linksLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 10)
        view.textColor = #colorLiteral(red: 0.08235294118, green: 0.396078431, blue: 0.7529411765, alpha: 1)
        view.numberOfLines = 0
        return view
    }()

    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleLabel, messageLabel, metaLabel, linksLabel])
        view.axis = .vertical
        view.spacing = 4
        view.translatesAutoresizingMaskIntoConstraints = false
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

    func populateUI(with message: DengageInboxChannelMessage) {
        titleLabel.text = message.data.title
        messageLabel.text = message.data.message

        let ctaCount = message.data.ctaButtons?.count ?? 0
        let date = message.data.receiveDateValue?.description ?? (message.data.receiveDate ?? "-")
        metaLabel.text = "Priority: \(message.priority) | Pinned: \(message.data.isPinned) | Read: \(message.isRead) | CTA: \(ctaCount) | \(date)"

        let cta = message.data.ctaButtons?.first
        var links = [String]()
        if let deeplink = cta?.iosDeeplink, !deeplink.isEmpty { links.append("iosDeeplink: \(deeplink)") }
        if let webUrl = cta?.webUrl, !webUrl.isEmpty { links.append("webUrl: \(webUrl)") }
        linksLabel.text = links.joined(separator: "\n")
        linksLabel.isHidden = links.isEmpty

        contentView.backgroundColor = message.isRead
            ? #colorLiteral(red: 1, green: 0.983807385, blue: 0, alpha: 0.4312555018)
            : #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
}
