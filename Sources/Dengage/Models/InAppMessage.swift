import Foundation

struct InAppMessage: Codable {
    let id: String
    let data: InAppMessageData
    var nextDisplayTime: Double?
    var showCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "smsg_id"
        case data = "message_json"
        case nextDisplayTime = "nextDisplayTime"
        case showCount = "showCount"
    }
    
    static func mapRealTime(source: [InAppMessageData]) -> [InAppMessage] {
        source.compactMap{item in
            guard let id = item.publicId else { return nil }
            return InAppMessage(id: id, data: item)
        }
    }
    
    func isDisplayTimeAvailable() -> Bool{
        return (data.displayTiming.showEveryXMinutes == nil ||
                data.displayTiming.showEveryXMinutes == 0 ||
                (nextDisplayTime ?? Date().timeMiliseconds) <= Date().timeMiliseconds) &&
        (data.displayTiming.maxShowCount == nil ||
         data.displayTiming.maxShowCount == 0 ||
         (showCount ?? 0) < (data.displayTiming.maxShowCount ?? 0))
    }
    
//    private class func isDisplayTimeAvailable(for inAppMessage: InAppMessage)  -> Bool {
//        return true
//        return (inAppMessage.data.displayTiming.showEveryXMinutes == nil ||
//                inAppMessage.data.displayTiming.showEveryXMinutes == 0 ||
//                (inAppMessage.nextDisplayTime ?? Date().timeMiliseconds) <= Date().timeMiliseconds)
//    }
}

struct InAppMessageData: Codable {
    var messageDetails: String? {
        return messageDetailId ?? publicId
    }
    let messageDetailId: String?
    let expireDate: String
    let priority: Priority
    let content: Content
    let displayCondition: DisplayCondition
    let displayTiming: DisplayTiming
    let publicId: String?

    var isRealTime: Bool {
        return publicId != nil
    }
    
    enum CodingKeys: String, CodingKey {
        case messageDetailId = "messageDetails"
        case expireDate = "expireDate"
        case priority = "priority"
        case content = "content"
        case displayCondition = "displayCondition"
        case displayTiming = "displayTiming"
        case publicId = "publicId"
    }
}

struct Content: Codable {
    let type: ContentType
    let props: ContentParams
    let contentId: String?
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
