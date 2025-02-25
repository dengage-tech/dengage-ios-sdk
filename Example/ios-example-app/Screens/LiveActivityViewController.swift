//
//  LiveActivityViewController.swift
//  ios-example-app
//
//  Created by Egemen Gülkılık on 24.02.2025.
//


import UIKit
import Dengage
import ActivityKit




final class LiveActivityViewController: UIViewController {
    
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
    
    private lazy var startLiveActivityButton: UIButton = {
        let view = UIButton()
        view.setTitle("Start Live Activity", for: .normal)
        view.addTarget(self, action: #selector(startLiveActivity), for: .touchUpInside)
        view.setTitleColor(.blue, for: .normal)
        return view
    }()
    
    private lazy var updateLiveActivityButton: UIButton = {
        let view = UIButton()
        view.setTitle("Update Live Activity", for: .normal)
        if #available(iOS 16.1, *) {
            view.addTarget(self, action: #selector(updateLiveActivity), for: .touchUpInside)
        } else {
            // Fallback on earlier versions
        }
        view.setTitleColor(.blue, for: .normal)
        return view
    }()
    
    
    private lazy var endLiveActivityButton: UIButton = {
        let view = UIButton()
        view.setTitle("End Live Activity", for: .normal)
        if #available(iOS 16.1, *) {
            view.addTarget(self, action: #selector(endLiveActivity), for: .touchUpInside)
        } else {
            // Fallback on earlier versions
        }
        view.setTitleColor(.blue, for: .normal)
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            propertyIdTextField, screenNameTextField, storyBackgroundColorTextField
            , startLiveActivityButton, updateLiveActivityButton, endLiveActivityButton
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
        startLiveActivity()
        
   
    }
    
    @objc func startLiveActivity() {
        if #available(iOS 16.1, *) {
            let attributes = DengageWidgetAttributes(name: "Dengage Live Activity")
            let contentState = DengageWidgetAttributes.ContentState(emoji: "🚀")
            do {
                let activity = try Activity<DengageWidgetAttributes>.request(
                    attributes: attributes,
                    contentState: contentState,
                    pushType: nil // Opsiyonel: Push Notifications ile tetikleme
                )
                print("Live Activity başlatıldı: \(activity.id)")
            } catch {
                print("Live Activity başlatılamadı: \(error.localizedDescription)")
            }
        } else {
            // Fallback on earlier versions
        }
        


    }
    
    
    
    @available(iOS 16.1, *)
    @objc func updateLiveActivity() {
        Task {
            let updatedState = DengageWidgetAttributes.ContentState(emoji: "superstar")
            for activity in Activity<DengageWidgetAttributes>.activities {
                await activity.update(using: updatedState)
            }
        }
    }

    @available(iOS 16.1, *)
    @objc func endLiveActivity() {
        Task {
            for activity in Activity<DengageWidgetAttributes>.activities {
                await activity.end(dismissalPolicy: .immediate)
            }
        }
    }

    
    
}



@available(iOS 16.1, *) // Live Activities sadece iOS 16.1+ destekler
struct DengageWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var emoji: String
    }

    var name: String
}

extension LiveActivityViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

