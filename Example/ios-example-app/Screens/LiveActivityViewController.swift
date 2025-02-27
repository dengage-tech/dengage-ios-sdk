//
//  LiveActivityViewController.swift
//  ios-example-app
//
//  Created by Egemen Gülkılık on 24.02.2025.
//


import UIKit
import Dengage
import ActivityKit


var activityId: String?


@available(iOS 16.1, *)
final class LiveActivityViewController: UIViewController {
    
    var activity: Activity<DengageWidgetAttributes>?
    
    
    private lazy var activityIdTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "Activity Id"
        view.textAlignment = .center
        view.borderStyle = .roundedRect
        view.textColor = .black
        view.delegate = self
        view.autocapitalizationType = .none
        return view
    }()
    
    private lazy var pushTokenTextField: UITextField = {
        let view = UITextField()
        view.placeholder = "Push Token"
        view.textAlignment = .center
        view.borderStyle = .roundedRect
        view.textColor = .black
        view.delegate = self
        view.autocapitalizationType = .none
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
            view.addTarget(self, action: #selector(updateLiveActivityAsync), for: .touchUpInside)
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
            activityIdTextField, pushTokenTextField, storyBackgroundColorTextField
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
            let attributes = DengageWidgetAttributes(name: "Live Activity")
            
            let contentState = DengageWidgetAttributes.ContentState(emoji: "🎉")
            do {
                let activity = try Activity<DengageWidgetAttributes>.request(
                    attributes: attributes,
                    contentState: contentState,
                    pushType: .token // Opsiyonel: Push Notifications ile tetikleme
                )
                self.activity = activity
                activityIdTextField.text = activity.id
                pushTokenTextField.text = activity.pushToken?.description
                print("Live Activity başlatıldı: \(activity.id)")
                
            } catch {
                print("Live Activity başlatılamadı: \(error.localizedDescription)")
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    func updateLiveActivity(activityId: String) async {
        if #available(iOS 16.1, *) {
            
            for await pushToken in activity!.pushTokenUpdates {
                let token = pushToken.map {String(format: "%02x", $0)}.joined()
            }
            
            
            let updatedState = DengageWidgetAttributes.ContentState(emoji: "122")
            Task {
                if let targetActivity = Activity<DengageWidgetAttributes>.activities.first(where: { $0.id == activityId }) {
                    await targetActivity.update(using: updatedState)
                } else {
                    print("Activity bulunamadı: \(activityId)")
                }
            }
        }
    }
    
    @objc func updateLiveActivityAsync() {
        
        Task {
            if let activity = activity {
                for await pushToken in activity.pushTokenUpdates {
                    let token = pushToken.map {String(format: "%02x", $0)}.joined()
                    print("token \(token)")
                }
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

@available(iOS 16.1, *)
extension LiveActivityViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

