import Foundation

struct InAppMessage: Codable {
    let id: String
    var data: InAppMessageData
    var nextDisplayTime: Double?
    var showCount: Int?
    var dismissCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "smsg_id"
        case data = "message_json"
        case nextDisplayTime = "nextDisplayTime"
        case showCount = "showCount"
        case dismissCount = "dismissCount"
    }
    
    static func mapRealTime(source: [InAppMessageData]) -> [InAppMessage] {
        source.compactMap{item in
            guard let id = item.publicId else { return nil }
            return InAppMessage(id: id, data: item)
        }
    }
    
    func isDisplayTimeAvailable() -> Bool {
        if data.displayTiming.showEveryXMinutes == -1 &&
           data.displayTiming.maxShowCount == -1 {
            return true
        } else {
            let timingCondition = (data.displayTiming.showEveryXMinutes == nil ||
                                   data.displayTiming.showEveryXMinutes == 0 ||
                                   (nextDisplayTime ?? Date().timeMiliseconds) <= Date().timeMiliseconds)
            
            let countCondition = (data.displayTiming.maxShowCount == nil ||
                                  data.displayTiming.maxShowCount == 0 ||
                                  (showCount ?? 0) < (data.displayTiming.maxShowCount ?? 0))
            
            return timingCondition && countCondition
        }
    }
    
    func isDisplayTimeAvailable(context: inout [String: String], criterionIndex: inout Int) -> Bool {
        let currentTime = Date().timeMiliseconds
        
        // Check show every X minutes constraint
        let isTimeConstraintMet: Bool
        if let showEveryXMinutes = data.displayTiming.showEveryXMinutes,
           showEveryXMinutes != 0 && showEveryXMinutes != -1 {
            let timeConstraintMet = (nextDisplayTime ?? currentTime) <= currentTime
            context["show_every_x_minutes_\(criterionIndex)"] = "\(showEveryXMinutes)|\(nextDisplayTime ?? 0)<=\(currentTime)|TIME_CONSTRAINT|\(timeConstraintMet)"
            criterionIndex += 1
            isTimeConstraintMet = timeConstraintMet
        } else {
            context["show_every_x_minutes_\(criterionIndex)"] = "noLimit|noLimit|TIME_CONSTRAINT|true"
            criterionIndex += 1
            isTimeConstraintMet = true
        }
        
        // Check max show count constraint
        let isShowCountConstraintMet: Bool
        if let maxShowCount = data.displayTiming.maxShowCount,
           maxShowCount != 0 && maxShowCount != -1 {
            let currentShowCount = showCount ?? 0
            let showCountConstraintMet = currentShowCount < maxShowCount
            context["max_show_count_\(criterionIndex)"] = "\(maxShowCount)|\(currentShowCount)<\(maxShowCount)|SHOW_COUNT_CONSTRAINT|\(showCountConstraintMet)"
            criterionIndex += 1
            isShowCountConstraintMet = showCountConstraintMet
        } else {
            context["max_show_count_\(criterionIndex)"] = "noLimit|noLimit|SHOW_COUNT_CONSTRAINT|true"
            criterionIndex += 1
            isShowCountConstraintMet = true
        }
        
        return isTimeConstraintMet && isShowCountConstraintMet
    }
}

struct InAppMessageData: Codable {
    var messageDetails: String? {
        return messageDetailId ?? publicId
    }
    let messageDetailId: String?
    let expireDate: String
    let priority: Priority
    /// Nullable because A/B test campaigns carry their renderable payload inside
    /// `abTest.variants[]` instead of `content`. After a variant is resolved (deterministic
    /// or via /ab/assign), the SDK constructs a `Content` from the chosen variant and assigns
    /// it here for the lifetime of that single impression.
    var content: Content?
    let displayCondition: DisplayCondition
    let displayTiming: DisplayTiming
    let publicId: String?
    let inlineTarget: InlineTarget?
    /// A/B test block. When non-nil, `content` is nil and the SDK must resolve a variant
    /// before rendering. Once the campaign reaches the winner phase, `abTest.variants[]`
    /// collapses to a single entry at 100%.
    let abTest: AbTest?

    var isRealTime: Bool {
        return publicId != nil
    }

    var isAbTest: Bool {
        return (abTest?.variants?.isEmpty == false)
    }

    enum CodingKeys: String, CodingKey {
        case messageDetailId = "messageDetails"
        case expireDate = "expireDate"
        case priority = "priority"
        case content = "content"
        case displayCondition = "displayCondition"
        case displayTiming = "displayTiming"
        case publicId = "publicId"
        case inlineTarget = "inlineTarget"
        case abTest = "abTest"
    }
}

struct Content: Codable {
    let type: String?
    let props: ContentParams
    let contentId: String?

    /// Build a `Content` from a resolved A/B variant. Returns nil when the variant lacks
    /// renderable props (defensive — shouldn't happen for non-control variants).
    static func fromVariant(_ variant: AbTestVariant) -> Content? {
        guard let props = variant.props, let type = variant.type else { return nil }
        return Content(type: type, props: props, contentId: variant.contentId)
    }
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


struct InAppRemovalId: Codable {
    let id: String
    
    enum CodingKeys: String, CodingKey {
        case id = "smsg_id"
    }
}

