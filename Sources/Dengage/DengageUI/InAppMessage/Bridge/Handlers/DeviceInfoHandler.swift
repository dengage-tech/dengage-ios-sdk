import Foundation
import UIKit

/// Handler for device information requests from WebView
final class DeviceInfoHandler: SyncBridgeHandler {

    struct DeviceInfo: Codable {
        let deviceId: String
        let sdkVersion: String
        let osVersion: String
        let manufacturer: String
        let model: String
        let appVersion: String?
        let token: String?
        let contactKey: String?
        let language: String
    }

    func supportedActions() -> [String] {
        return [
            "getDeviceId",
            "getDeviceInfo",
            "getSdkVersion",
            "getToken",
            "getContactKey"
        ]
    }

    func handleSync(message: BridgeMessage) -> BridgeResponse {
        switch message.action {
        case "getDeviceId":
            return BridgeResponse.success(callId: message.callId, data: Dengage.getDeviceId())

        case "getSdkVersion":
            return BridgeResponse.success(callId: message.callId, data: Dengage.getSdkVersion())

        case "getToken":
            return BridgeResponse.success(callId: message.callId, data: Dengage.getDeviceToken())

        case "getContactKey":
            return BridgeResponse.success(callId: message.callId, data: Dengage.getContactKey())

        case "getDeviceInfo":
            let deviceInfo: [String: Any?] = [
                "deviceId": Dengage.getDeviceId(),
                "sdkVersion": Dengage.getSdkVersion(),
                "osVersion": UIDevice.current.systemVersion,
                "manufacturer": "Apple",
                "model": UIDevice.modelName,
                "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                "token": Dengage.getDeviceToken(),
                "contactKey": Dengage.getContactKey(),
                "language": Locale.current.languageCode ?? "en"
            ]
            return BridgeResponse.success(callId: message.callId, data: deviceInfo)

        default:
            return BridgeResponse.error(
                callId: message.callId,
                errorCode: BridgeErrorCodes.unknownAction,
                errorMessage: "Unknown action: \(message.action)"
            )
        }
    }
}
