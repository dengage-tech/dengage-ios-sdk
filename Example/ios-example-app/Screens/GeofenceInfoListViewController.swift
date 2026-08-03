import UIKit

/// Geofence teşhis çıktılarını (izlenen fence'ler / tetiklenen event'ler) gösteren
/// basit, kaydırılabilir metin ekranı.
final class GeofenceInfoListViewController: UIViewController {

    private let listTitle: String
    private let text: String

    private lazy var textView: UITextView = {
        let view = UITextView()
        view.isEditable = false
        view.alwaysBounceVertical = true
        view.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        view.textContainerInset = UIEdgeInsets(top: 16, left: 12, bottom: 16, right: 12)
        view.backgroundColor = .white
        return view
    }()

    init(listTitle: String, text: String) {
        self.listTitle = listTitle
        self.text = text
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = listTitle
        view.backgroundColor = .white
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        textView.text = text
    }
}
