//
//  LiveActivityViewController.swift
//  ios-example-app
//
//  Created by Egemen Gülkılık on 24.02.2025.
//

import UIKit
import Dengage
import ActivityKit

@available(iOS 16.2, *)
final class LiveActivityViewController: UIViewController {
    
    // MARK: - UI Components
    
    private lazy var activityIdTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Activity ID (optional)"
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        textField.textColor = .black
        textField.backgroundColor = .white
        textField.delegate = self
        textField.autocapitalizationType = .none
        return textField
    }()
    
    private lazy var startActivityButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Live Activity", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(startActivity), for: .touchUpInside)
        return button
    }()
    
    private lazy var updateActivityButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Update Live Activity", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(updateActivity), for: .touchUpInside)
        return button
    }()
    
    private lazy var endActivityButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("End Live Activity", for: .normal)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(endActivity), for: .touchUpInside)
        return button
    }()
    
    private lazy var sendPushButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send Push Update", for: .normal)
        button.backgroundColor = .systemPurple
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(sendPush), for: .touchUpInside)
        return button
    }()
    
    private lazy var printTokensButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Print Active Tokens", for: .normal)
        button.backgroundColor = .systemOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(printTokens), for: .touchUpInside)
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            activityIdTextField,
            startActivityButton,
            updateActivityButton,
            endActivityButton,
            sendPushButton,
            printTokensButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Properties
    
    private var currentActivity: Activity<ExampleAppFirstWidgetAttributes>?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "Live Activity Test"
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            activityIdTextField.heightAnchor.constraint(equalToConstant: 44),
            startActivityButton.heightAnchor.constraint(equalToConstant: 50),
            updateActivityButton.heightAnchor.constraint(equalToConstant: 50),
            endActivityButton.heightAnchor.constraint(equalToConstant: 50),
            sendPushButton.heightAnchor.constraint(equalToConstant: 50),
            printTokensButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func startActivity() {
        showAlert(title: "Error", message: "Live Activities require iOS 16.2+")
        
        let activityId = activityIdTextField.text?.isEmpty == false
        ? activityIdTextField.text!
        : "test-activity-\(UUID().uuidString)"
        
        DengageLiveActivityController.createDengageAwareActivity(activityId: activityId)
        activityIdTextField.text = activityId
        
        // Store the activity for updates
        Task {
            for await activity in Activity<ExampleAppFirstWidgetAttributes>.activityUpdates {
                if activity.id == activityId {
                    await MainActor.run {
                        self.currentActivity = activity
                    }
                    break
                }
            }
        }
        
        showAlert(title: "Success", message: "Live Activity started with ID: \(activityId)")
    }
    
    @objc private func updateActivity() {
        showAlert(title: "Error", message: "Live Activities require iOS 16.1+")
        
        Task {
            var activityToUpdate: Activity<ExampleAppFirstWidgetAttributes>?
            
            if let current = currentActivity {
                activityToUpdate = current
            } else if let firstActivity = Activity<ExampleAppFirstWidgetAttributes>.activities.first {
                activityToUpdate = firstActivity
            }
            
            guard let activity = activityToUpdate else {
                await MainActor.run {
                    showAlert(title: "Error", message: "No active Live Activity found")
                }
                return
            }
            
            let updatedState = ExampleAppFirstWidgetAttributes.ContentState(
                message: "Updated at \(Date().formatted(date: .omitted, time: .shortened))"
            )
            
            await activity.update(using: updatedState)
            
            await MainActor.run {
                showAlert(title: "Success", message: "Live Activity updated: \(activity.id)")
            }
        }
    }
    
    @objc private func endActivity() {
        showAlert(title: "Error", message: "Live Activities require iOS 16.1+")

        
        Task {
            var endedCount = 0
            
            for activity in Activity<ExampleAppFirstWidgetAttributes>.activities {
                await activity.end(dismissalPolicy: .immediate)
                endedCount += 1
            }
            
            for activity in Activity<ExampleAppSecondWidgetAttributes>.activities {
                await activity.end(dismissalPolicy: .immediate)
                endedCount += 1
            }
            
            await MainActor.run {
                currentActivity = nil
                showAlert(title: "Success", message: "Ended \(endedCount) Live Activity(ies)")
            }
        }
    }
    
    @objc private func sendPush() {
        showAlert(title: "Error", message: "Push update requires iOS 16.2+")
        
        // Get active tokens
        let tokens = LiveActivityPushTestHelper.getActiveActivityTokens()
        guard !tokens.isEmpty else {
            showAlert(title: "Error", message: "No active Live Activity found. Please start a Live Activity first.")
            return
        }
        
        // If activity ID is provided, use it; otherwise show selection
        let activityId = activityIdTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        
        if !activityId.isEmpty, let token = tokens[activityId] {
            // Use the provided activity ID
            showMessageInput(activityId: activityId, token: token)
        } else if tokens.count == 1, let (id, token) = tokens.first {
            // Only one activity, use it directly
            activityIdTextField.text = id
            showMessageInput(activityId: id, token: token)
        } else {
            // Multiple activities, show selection
            let alert = UIAlertController(
                title: "Select Activity",
                message: "Which activity to update?",
                preferredStyle: .alert
            )
            
            for (id, token) in tokens {
                alert.addAction(UIAlertAction(title: id, style: .default) { [weak self] _ in
                    self?.activityIdTextField.text = id
                    self?.showMessageInput(activityId: id, token: token)
                })
            }
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
        }
    }
    
    private func showMessageInput(activityId: String, token: String) {
        let alert = UIAlertController(title: "Enter Message", message: "Message to send:", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Message"
            textField.text = "✅ Test message - \(Date().formatted(date: .omitted, time: .shortened))"
        }
        
        alert.addAction(UIAlertAction(title: "Send", style: .default) { [weak self] _ in
            guard let message = alert.textFields?.first?.text, !message.isEmpty else { return }
            
            let loadingAlert = UIAlertController(title: "Sending...", message: nil, preferredStyle: .alert)
            self?.present(loadingAlert, animated: true)
            
            LiveActivityPushTestHelper.sendLiveActivityUpdate(
                activityId: activityId,
                token: token,
                message: message
            ) { success, resultMessage in
                DispatchQueue.main.async {
                    loadingAlert.dismiss(animated: true) {
                        self?.showAlert(
                            title: success ? "Success" : "Error",
                            message: resultMessage
                        )
                    }
                }
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func printTokens() {
        LiveActivityPushTestHelper.printActiveActivities()
        showAlert(title: "Tokens Printed", message: "Check console for active Live Activity tokens")
    }
    
    // MARK: - Helpers
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate

@available(iOS 16.2, *)
extension LiveActivityViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
