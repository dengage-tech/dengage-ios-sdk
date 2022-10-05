import Foundation

struct InAppMessage: Codable {
    let id: String
    let data: InAppMessageData
    var nextDisplayTime: Double?
    
    enum CodingKeys: String, CodingKey {
        case id = "smsg_id"
        case data = "message_json"
        case nextDisplayTime = "nextDisplayTime"
    }
    
    static func mapRealTime(source: [InAppMessageData]) -> [InAppMessage] {
        source.compactMap{item in
            guard let id = item.publicId else { return nil }
            return InAppMessage(id: id, data: item)
        }
    }
}

struct InAppMessageData: Codable {
    let messageDetails: String?
    let expireDate: String
    let priority: Priority
    let content: Content
    let displayCondition: DisplayCondition
    let displayTiming: DisplayTiming
    let publicId: String?

    var isRealTime: Bool {
        return publicId != nil
    }
}

struct Content: Codable {
    let type: ContentType
    let props: ContentParams
}

extension InAppMessage: Equatable {
    static func == (lhs: InAppMessage, rhs: InAppMessage) -> Bool {
        return lhs.data.messageDetails == rhs.data.messageDetails
    }
}

extension Array where Element == InAppMessage {
    var sorted:[InAppMessage]{
        return (self as NSArray).sortedArray(comparator: { first, second -> ComparisonResult in
            guard
                let first = first as? InAppMessage,
                let second = second as? InAppMessage
            else {
                return .orderedSame
            }
            
            if first.data.isRealTime != second.data.isRealTime {
                return first.data.isRealTime && !second.data.isRealTime ? .orderedDescending : .orderedAscending
            } else {
                guard first.data.priority == second.data.priority else {
                    return first.data.priority.rawValue < second.data.priority.rawValue ? .orderedAscending : .orderedDescending
                }
                    
                let firstHasRules = first.data.displayCondition.hasRules
                let secondHasRules = second.data.displayCondition.hasRules
                
                if first.data.isRealTime && second.data.isRealTime && firstHasRules != secondHasRules {
                    return firstHasRules && !secondHasRules ? .orderedDescending : .orderedAscending
                } else {
                    guard
                        let firstExpireDate = Utilities.convertDate(to: first.data.expireDate),
                        let secondExpireDate = Utilities.convertDate(to: first.data.expireDate)
                    else {
                        return .orderedSame
                    }
                    
                    return firstExpireDate.compare(secondExpireDate)
                }
            }
        }) as? [InAppMessage] ?? []
    }
}

// -1 .orderedAscending
