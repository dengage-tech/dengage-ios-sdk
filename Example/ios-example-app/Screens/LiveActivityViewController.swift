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

    private lazy var showTokensButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Show Active Tokens", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(showTokens), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Setup

    private func setupUI() {
        title = "Live Activity Tokens"
        view.backgroundColor = .systemGroupedBackground

        view.addSubview(showTokensButton)

        NSLayoutConstraint.activate([
            showTokensButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            showTokensButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            showTokensButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            showTokensButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            showTokensButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    // MARK: - Actions

    @objc private func showTokens() {
        let tokenInfo = buildTokenInfo()

        let alert = UIAlertController(title: "Live Activity Tokens", message: tokenInfo, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Copy All", style: .default) { _ in
            UIPasteboard.general.string = tokenInfo
        })

        alert.addAction(UIAlertAction(title: "Close", style: .cancel))

        present(alert, animated: true)
    }

    // MARK: - Token Collection

    private func buildTokenInfo() -> String {
        var sections: [String] = []

        // Push-to-start tokens (iOS 17.2+)
        if #available(iOS 17.2, *) {
            var startEntry = "--- Push-to-Start Tokens ---"

            if let token = Activity<ExampleAppFirstWidgetAttributes>.pushToStartToken {
                let tokenString = token.map { String(format: "%02x", $0) }.joined()
                startEntry += "\n\n[ExampleAppFirstWidgetAttributes]\nStart Token: \(tokenString)"
            } else {
                startEntry += "\n\n[ExampleAppFirstWidgetAttributes]\nStart Token: (none)"
            }

            if let token = Activity<ExampleAppSecondWidgetAttributes>.pushToStartToken {
                let tokenString = token.map { String(format: "%02x", $0) }.joined()
                startEntry += "\n\n[ExampleAppSecondWidgetAttributes]\nStart Token: \(tokenString)"
            } else {
                startEntry += "\n\n[ExampleAppSecondWidgetAttributes]\nStart Token: (none)"
            }

            sections.append(startEntry)
        }

        // Active activities - update tokens
        var updateEntries: [String] = []

        for activity in Activity<ExampleAppFirstWidgetAttributes>.activities {
            var entry = "[ExampleAppFirstWidgetAttributes]\n"
            entry += "Activity ID: \(activity.attributes.dengage.activityId)\n"
            entry += "State: \(activity.activityState)\n"

            if let token = activity.pushToken {
                let tokenString = token.map { String(format: "%02x", $0) }.joined()
                entry += "Update Token: \(tokenString)"
            } else {
                entry += "Update Token: (none)"
            }

            updateEntries.append(entry)
        }

        for activity in Activity<ExampleAppSecondWidgetAttributes>.activities {
            var entry = "[ExampleAppSecondWidgetAttributes]\n"
            entry += "Activity ID: \(activity.attributes.dengage.activityId)\n"
            entry += "State: \(activity.activityState)\n"

            if let token = activity.pushToken {
                let tokenString = token.map { String(format: "%02x", $0) }.joined()
                entry += "Update Token: \(tokenString)"
            } else {
                entry += "Update Token: (none)"
            }

            updateEntries.append(entry)
        }

        if !updateEntries.isEmpty {
            sections.append("--- Update Tokens ---\n\n" + updateEntries.joined(separator: "\n\n"))
        }

        return sections.joined(separator: "\n\n")
    }
}
