import Foundation
import UserNotifications
#if targetEnvironment(macCatalyst)
#else
import ActivityKit
import Dengage

/**
 Helper class to test Live Activity push notifications locally
 */
@available(iOS 16.2, *)
class LiveActivityPushTestHelper {
    
    /**
     Simulates a push notification to start a Live Activity
     - Parameters:
        - activityId: The activity identifier
        - activityType: The activity type (e.g., "ExampleAppFirstWidgetAttributes")
        - contentState: The content state dictionary
     */
    static func simulateStartPush(activityId: String, 
                                  activityType: String,
                                  contentState: [String: Any]) {
        let userInfo: [String: Any] = [
            "aps": [
                "content-state": contentState,
                "alert": [
                    "title": "Live Activity Başlatıldı",
                    "body": "Yeni bir Live Activity başlatıldı"
                ],
                "sound": "default"
            ],
            "activity-type": activityType,
            "event": "start",
            "activity-id": activityId
        ]
        
        print("📱 Simulated Start Push:")
        print("Activity ID: \(activityId)")
        print("Activity Type: \(activityType)")
        print("Content State: \(contentState)")
        print("Full Payload: \(userInfo)")
    }
    
    /**
     Simulates a push notification to update a Live Activity
     - Parameters:
        - activityId: The activity identifier
        - activityType: The activity type
        - contentState: The updated content state dictionary
     */
    static func simulateUpdatePush(activityId: String,
                                   activityType: String,
                                   contentState: [String: Any]) {
        let userInfo: [String: Any] = [
            "aps": [
                "content-state": contentState,
                "alert": [
                    "title": "Live Activity Güncellendi",
                    "body": "Live Activity içeriği güncellendi"
                ],
                "sound": "default"
            ],
            "activity-type": activityType,
            "event": "update",
            "activity-id": activityId
        ]
        
        print("📱 Simulated Update Push:")
        print("Activity ID: \(activityId)")
        print("Activity Type: \(activityType)")
        print("Content State: \(contentState)")
        print("Full Payload: \(userInfo)")
    }
    
    /**
     Simulates a push notification to end a Live Activity
     - Parameters:
        - activityId: The activity identifier
        - activityType: The activity type
        - dismissalPolicy: The dismissal policy (immediate or default)
     */
    static func simulateEndPush(activityId: String,
                                 activityType: String,
                                 dismissalPolicy: String = "immediate") {
        let userInfo: [String: Any] = [
            "aps": [
                "content-state": [
                    "name": "Dengage Live Activity",
                    "emoji": "🏁"
                ],
                "alert": [
                    "title": "Live Activity Sonlandı",
                    "body": "Live Activity tamamlandı"
                ],
                "sound": "default"
            ],
            "activity-type": activityType,
            "event": "end",
            "activity-id": activityId,
            "dismissal-policy": dismissalPolicy
        ]
        
        print("📱 Simulated End Push:")
        print("Activity ID: \(activityId)")
        print("Activity Type: \(activityType)")
        print("Dismissal Policy: \(dismissalPolicy)")
        print("Full Payload: \(userInfo)")
    }
    
    /**
     Example: ExampleAppFirstWidgetAttributes için start push
     */
    static func exampleDengageWidgetStart(activityId: String) {
        simulateStartPush(
            activityId: activityId,
            activityType: "ExampleAppFirstWidgetAttributes",
            contentState: [
                "message": "🚀 Dengage Live Activity Started"
            ]
        )
    }
    
    /**
     Example: ExampleAppFirstWidgetAttributes için update push
     */
    static func exampleDengageWidgetUpdate(activityId: String, emoji: String) {
        simulateUpdatePush(
            activityId: activityId,
            activityType: "ExampleAppFirstWidgetAttributes",
            contentState: [
                "message": "\(emoji) Dengage Live Activity Updated"
            ]
        )
    }
    
    /**
     Example: DefaultLiveActivityAttributes için start push
     */
    static func exampleDefaultActivityStart(activityId: String) {
        simulateStartPush(
            activityId: activityId,
            activityType: "DefaultLiveActivityAttributes",
            contentState: [
                "data": [
                    "message": [
                        "en": "Hello",
                        "es": "Hola"
                    ],
                    "progress": 0.75,
                    "status": "3/4",
                    "bugs": 1
                ]
            ]
        )
    }
    
    /**
     Prints the current active Live Activities and their tokens
     */
    static func printActiveActivities() {
        if #available(iOS 16.1, *) {
            print("📱 Active Live Activities:")
            
            // ExampleAppFirstWidgetAttributes
            for activity in Activity<ExampleAppFirstWidgetAttributes>.activities {
                print("  - Activity ID: \(activity.id)")
                print("    Title: \(activity.attributes.title)")
                print("    Message: \(activity.content.state.message)")
                if let token = activity.pushToken {
                    let tokenString = token.map { String(format: "%02x", $0) }.joined()
                    print("    Token: \(tokenString)")
                }
            }
            
            // ExampleAppSecondWidgetAttributes
            for activity in Activity<ExampleAppSecondWidgetAttributes>.activities {
                print("  - Activity ID: \(activity.id)")
                print("    Title: \(activity.attributes.title)")
                print("    Message: \(activity.content.state.message)")
                print("    Progress: \(activity.content.state.progress)")
                if let token = activity.pushToken {
                    let tokenString = token.map { String(format: "%02x", $0) }.joined()
                    print("    Token: \(tokenString)")
                }
            }
        }
    }
    
    /**
     Gets all active Live Activity tokens for ExampleAppFirstWidgetAttributes
     - Returns: Dictionary of activity IDs and their tokens
     */
    @available(iOS 16.2, *)
    static func getActiveActivityTokens() -> [String: String] {
        var tokens: [String: String] = [:]
        
        for activity in Activity<ExampleAppFirstWidgetAttributes>.activities {
            if let token = activity.pushToken {
                let tokenString = token.map { String(format: "%02x", $0) }.joined()
                tokens[activity.id] = tokenString
            }
        }
        
        return tokens
    }
    
    /**
     Sends a Live Activity update push directly using activity token (similar to OneSignal)
     - Parameters:
        - activityId: The activity ID to update
        - token: The activity token
        - message: The new message content
        - completion: Completion handler with success/failure result
     */
    @available(iOS 16.2, *)
    static func sendLiveActivityUpdate(activityId: String,
                                      token: String,
                                      message: String,
                                      completion: @escaping (Bool, String) -> Void) {
        // Create the push payload (iOS Live Activity format)
        let payload: [String: Any] = [
            "aps": [
                "content-state": [
                    "message": message
                ],
                "alert": [
                    "title": "Live Activity Updated",
                    "body": message
                ],
                "sound": "default"
            ],
            "activity-type": "ExampleAppFirstWidgetAttributes",
            "event": "update",
            "activity-id": activityId
        ]
        
        // Create the API request body
        let requestBody: [String: Any] = [
            "activity_token": token,
            "payload": payload
        ]
        
        print("📤 Sending Live Activity Update:")
        print("   Activity ID: \(activityId)")
        print("   Token: \(token)")
        print("   Message: \(message)")
        print("   Payload: \(payload)")
        
        // Send the request to local test server
        sendPushRequest(body: requestBody) { success, message in
            completion(success, message)
        }
    }
    
    /**
     Sends a push request to local test server
     - Parameters:
        - body: The request body
        - completion: Completion handler
     */
    private static func sendPushRequest(body: [String: Any],
                                       completion: @escaping (Bool, String) -> Void) {
        // Using local test server for Live Activities
        // In production, this would go to Dengage's actual API
        let baseURL = "http://localhost:3000"
        let endpoint = "/live_activities/push" // Simple endpoint without channel
        guard let url = URL(string: baseURL + endpoint) else {
            completion(false, "Invalid URL")
            return
        }
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Encode the body
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            completion(false, "Failed to encode request body")
            return
        }
        request.httpBody = jsonData
        
        // Send the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(false, "Request failed: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(false, "Invalid response")
                return
            }
            
            if (200...299).contains(httpResponse.statusCode) {
                let responseMessage = String(data: data ?? Data(), encoding: .utf8) ?? "Success"
                completion(true, "Push sent successfully: \(responseMessage)")
            } else {
                let errorMessage = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown error"
                completion(false, "Push failed (Status: \(httpResponse.statusCode)): \(errorMessage)")
            }
        }
        
        task.resume()
    }
}
#endif

