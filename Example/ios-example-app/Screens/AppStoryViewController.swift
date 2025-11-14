import Dengage
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
    
    private lazy var storiesContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var storiesListView: StoriesListView?
    var storiesListViewArray: [StoriesListView] = []
    
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
        view.addSubview(storiesContainerView)
        
        stackView.topAnchor.constraint(equalTo: view.safeAreaTopAnchor, constant: 20).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
        
        storiesContainerView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20).isActive = true
        storiesContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
        storiesContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
        storiesContainerView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
    }
    
    
    @objc private func didTapChangeStoryBackgroundColorButton() {
        if let storiesListView = storiesListView, let storyColorString = storyBackgroundColorTextField.text {
            storiesListView.backgroundColor = UIColor(hex: storyColorString) ?? .clear
        }
    }
    
    @objc private func didTapRefreshStoryButton() {
        
        // Remove existing story views
        storiesContainerView.subviews
            .filter { $0.tag == STORY_VIEW_TAG }
            .forEach { $0.removeFromSuperview() }
        
        storiesListViewArray.removeAll()
        
        let storyPropertyID = propertyIdTextField.text
        let screenName = screenNameTextField.text
        let customParams = [String: String]()
        
        // First story (bottom layer)
        Dengage.showAppStory(storyPropertyID: storyPropertyID, screenName: screenName, customParams: customParams) { storyView in
            
            if let storyView = storyView {
                storyView.translatesAutoresizingMaskIntoConstraints = false
                storyView.tag = STORY_VIEW_TAG
                self.storiesListViewArray.append(storyView)
                self.storiesContainerView.addSubview(storyView)
                
                // Position first story to fill container
                NSLayoutConstraint.activate([
                    storyView.topAnchor.constraint(equalTo: self.storiesContainerView.topAnchor),
                    storyView.leadingAnchor.constraint(equalTo: self.storiesContainerView.leadingAnchor),
                    storyView.trailingAnchor.constraint(equalTo: self.storiesContainerView.trailingAnchor),
                    storyView.bottomAnchor.constraint(equalTo: self.storiesContainerView.bottomAnchor)
                ])
                
                // Store first story view for background color change
                if self.storiesListViewArray.count == 1 {
                    self.storiesListView = storyView
                }
            }
        }
        
        // Second story (top layer - will overlay the first)
        Dengage.showAppStory(storyPropertyID: storyPropertyID, screenName: screenName, customParams: customParams) { secondStoryView in
            
            if let secondStoryView = secondStoryView {
                secondStoryView.translatesAutoresizingMaskIntoConstraints = false
                secondStoryView.tag = STORY_VIEW_TAG
                self.storiesListViewArray.append(secondStoryView)
                self.storiesContainerView.addSubview(secondStoryView)
                
                // Position second story to overlay the first (same constraints)
                NSLayoutConstraint.activate([
                    secondStoryView.topAnchor.constraint(equalTo: self.storiesContainerView.topAnchor),
                    secondStoryView.leadingAnchor.constraint(equalTo: self.storiesContainerView.leadingAnchor),
                    secondStoryView.trailingAnchor.constraint(equalTo: self.storiesContainerView.trailingAnchor),
                    secondStoryView.bottomAnchor.constraint(equalTo: self.storiesContainerView.bottomAnchor)
                ])
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
