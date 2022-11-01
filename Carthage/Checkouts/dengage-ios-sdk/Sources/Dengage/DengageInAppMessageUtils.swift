import Foundation

final class DengageInAppMessageUtils{
    /**
     * Find not expired in app messages with controlling expire date and date now
     *
     * @param inAppMessages in app messages that will be filtered with expire date
     */
    class func findNotExpiredInAppMessages(untilDate: Date, _ inAppMessages: [InAppMessage]) -> [InAppMessage] {
        return inAppMessages.filter{ message -> Bool in
            guard let expireDate = Utilities.convertDate(to: message.data.expireDate) else {return false}
            return untilDate.compare(expireDate) != .orderedDescending
        }
    }
    
    /**
     * Find prior in app message to show with respect to priority and expireDate parameters
     */
    class func findPriorInAppMessage(inAppMessages: [InAppMessage], screenName: String? = nil) -> InAppMessage? {
        
        let inAppMessageWithoutScreenName = inAppMessages.sorted.first { message -> Bool in
            return (message.data.displayCondition.screenNameFilters ?? []).isEmpty && isDisplayTimeAvailable(for: message)
        }
        
        if let screenName = screenName, !screenName.isEmpty{
            let inAppMessageWithScreenName = inAppMessages.sorted.first { message -> Bool in
                return message.data.displayCondition.screenNameFilters?.first{ nameFilter -> Bool in
                    return operateScreenValues(value: nameFilter.value, for: screenName, operatorType: nameFilter.operatorType)
                } != nil && isDisplayTimeAvailable(for: message)
            }
            return inAppMessageWithScreenName ?? inAppMessageWithoutScreenName
        }else{
           return inAppMessageWithoutScreenName
        }
    }
    
    private class func operateScreenValues(value screenNameFilterValues: [String], for screenName: String, operatorType: OperatorType) -> Bool {
        let screenNameFilter = screenNameFilterValues.first ?? ""
        switch operatorType {
        case .EQUALS:
            return screenNameFilter == screenName
        case .NOT_EQUALS:
            return screenNameFilter != screenName
        case .LIKE:
            return screenName.contains(screenNameFilter)
        case .NOT_LIKE:
            return !screenName.contains(screenNameFilter)
        case .STARTS_WITH:
            return screenName.hasPrefix(screenNameFilter)
        case .NOT_STARTS_WITH:
            return !screenName.hasPrefix(screenNameFilter)
        case .ENDS_WITH:
            return screenName.hasSuffix(screenNameFilter)
        case .NOT_ENDS_WITH:
            return !screenName.hasSuffix(screenNameFilter)
        case .IN:
           return screenNameFilterValues.contains(screenName)
        case .NOT_IN:
           return !screenNameFilterValues.contains(screenName)
        }
    }
    
    private class func isDisplayTimeAvailable(for inAppMessage: InAppMessage)  -> Bool {
        return (inAppMessage.data.displayTiming.showEveryXMinutes == nil ||
                inAppMessage.data.displayTiming.showEveryXMinutes == 0 ||
                (inAppMessage.nextDisplayTime ?? Date().timeMiliseconds) <= Date().timeMiliseconds)
    }
}
