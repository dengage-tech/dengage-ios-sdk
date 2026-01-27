import Foundation
import CoreFoundation

/// Represents a response from Native to JavaScript
struct BridgeResponse: Codable {
    let callId: String
    let success: Bool
    let data: AnyCodable?
    let errorCode: String?
    let errorMessage: String?

    static func success(callId: String, data: Any? = nil) -> BridgeResponse {
        return BridgeResponse(
            callId: callId,
            success: true,
            data: data.map { AnyCodable($0) },
            errorCode: nil,
            errorMessage: nil
        )
    }

    static func error(callId: String, errorCode: String, errorMessage: String) -> BridgeResponse {
        return BridgeResponse(
            callId: callId,
            success: false,
            data: nil,
            errorCode: errorCode,
            errorMessage: errorMessage
        )
    }
}

/// Type-erased Codable wrapper for Any values
struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self.value = NSNull()
        } else if let bool = try? container.decode(Bool.self) {
            self.value = bool
        } else if let int = try? container.decode(Int.self) {
            self.value = int
        } else if let double = try? container.decode(Double.self) {
            self.value = double
        } else if let string = try? container.decode(String.self) {
            self.value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            self.value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            self.value = dictionary.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyCodable cannot decode value")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case is NSNull:
            try container.encodeNil()
        case let number as NSNumber:
            // Check if it's actually a boolean using CFBoolean type
            // NSNumber from JSON can be both Bool and Int, so we need to distinguish
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                try container.encode(number.boolValue)
            } else if number.objCType.pointee == 0x64 { // 'd' for double
                try container.encode(number.doubleValue)
            } else {
                try container.encode(number.intValue)
            }
        case let bool as Bool where !(value is NSNumber):
            try container.encode(bool)
        case let int as Int where !(value is NSNumber):
            try container.encode(int)
        case let double as Double where !(value is NSNumber):
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        default:
            let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "AnyCodable cannot encode value")
            throw EncodingError.invalidValue(value, context)
        }
    }
}
