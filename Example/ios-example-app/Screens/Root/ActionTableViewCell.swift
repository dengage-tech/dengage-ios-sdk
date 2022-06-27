
import UIKit

final class ActionTableViewCell: UITableViewCell {

    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        label.font = .boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.addSubview(label)
        label.alignCenterToSuperView()
        view.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle = .default,
                  reuseIdentifier: String?) {

        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(containerView)
        containerView.fillSuperview(horizontalPadding: 16, verticalPadding: 8)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func populateUI(with title: String){
        label.text = title
    }
    
    func setLabelFontSize(size: Int){
        label.font = .boldSystemFont(ofSize: CGFloat(size))
    }
}
