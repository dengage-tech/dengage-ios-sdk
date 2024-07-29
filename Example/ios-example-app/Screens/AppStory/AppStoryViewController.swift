
import Dengage
import Storyly
import UIKit

let STORY_VIEW_TAG = 1453

final class AppStoryViewController: UIViewController {
    
    private lazy var propertyIdTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "Property Id"
        view.textAlignment = .center
        view.borderStyle = .roundedRect
        view.textColor = .black
        view.delegate = self
        view.autocapitalizationType = .none
        view.text = "3"
        return view
    }()
    
    private lazy var screenNameTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "Screen Name"
        view.textAlignment = .center
        view.borderStyle = .roundedRect
        view.textColor = .black
        view.delegate = self
        view.autocapitalizationType = .none
        view.text = "ego"
        return view
    }()
    
    private lazy var storyBackgroundColorTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "Story Background Color"
        view.textAlignment = .center
        view.borderStyle = .roundedRect
        view.textColor = .black
        view.delegate = self
        view.autocapitalizationType = .none
        view.text = "#ffffff"
        return view
    }()
    
    private lazy var storyBackgroundColorButton: UIButton = {
        let view = UIButton()
        view.setTitle("Change Story Background Color", for: .normal)
        view.addTarget(self, action: #selector(didTapChangeStoryBackgroundColorButton), for: .touchUpInside)
        view.setTitleColor(.blue, for: .normal)
        return view
    }()
    
    private lazy var refreshStoryButton: UIButton = {
        let view = UIButton()
        view.setTitle("Refresh Story", for: .normal)
        view.addTarget(self, action: #selector(didTapRefreshStoryButton), for: .touchUpInside)
        view.setTitleColor(.blue, for: .normal)
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            propertyIdTextField, screenNameTextField, storyBackgroundColorTextField
            , storyBackgroundColorButton, refreshStoryButton
        ])
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 10
        return view
    }()
    
    var storiesListView: StoriesListView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        Dengage.removeInAppMessageDisplay()
    }
    
    private func setupUI() {
        title = "App Story"
        view.backgroundColor = .lightGray
        view.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: view.safeAreaTopAnchor, constant: 20).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
    }
    
    
    @objc private func didTapChangeStoryBackgroundColorButton() {
        if let storiesListView = storiesListView, let storyColorString = storyBackgroundColorTextField.text {
            storiesListView.backgroundColor = UIColor(hex: storyColorString) ?? .clear
        }
    }
    
    @objc private func didTapRefreshStoryButton() {
        
        
        if let viewWithTag = stackView.viewWithTag(STORY_VIEW_TAG) {
            viewWithTag.removeFromSuperview()
        }
        
        let storyPropertyID = propertyIdTextField.text
        let screenName = screenNameTextField.text
        let customParams = [String: String]()
        
        Dengage.showAppStory(storyPropertyID: storyPropertyID, screenName: screenName, customParams: customParams) { storyView in
            
            if let storyView = storyView {
                self.storiesListView = storyView
                self.storiesListView?.translatesAutoresizingMaskIntoConstraints = false
                if let storiesListView = self.storiesListView {
                    self .storiesListView?.tag = STORY_VIEW_TAG
                    self.stackView.insertArrangedSubview(storiesListView, at: self.stackView.subviews.count)
                }
            }
            
        }
    }
    
}

extension AppStoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
