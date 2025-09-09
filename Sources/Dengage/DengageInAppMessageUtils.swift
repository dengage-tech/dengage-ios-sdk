import Foundation
import UIKit

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
    class func findPriorInAppMessage(
        inAppMessages: [InAppMessage],
        screenName: String? = nil,
        params: [String:String]? = nil,
        config: DengageConfiguration,
        propertyId: String?,
        storyPropertyId: String?
    ) -> InAppMessage? {
        
        let sortedMessages = inAppMessages.sorted
        
        if let screenName = screenName, !screenName.isEmpty {
            if let matchedMessage = sortedMessages.first(where: { message in
                guard let screenFilters = message.data.displayCondition.screenNameFilters else {
                    return false
                }
                
                return message.isDisplayTimeAvailable()
                && operateRealTimeValues(message: message, with: params, config: config)
                && isInLineInApp(inAppMessage: message, propertyID: propertyId, storyPropertyId: storyPropertyId)
                && isScreenNameMatching(screenFilters: screenFilters,
                                        screenName: screenName,
                                        logicOperator: message.data.displayCondition.screenNameFilterLogicOperator)
            }) {
                return matchedMessage
            }
            
            return sortedMessages.first { message in
                (message.data.displayCondition.screenNameFilters ?? []).isEmpty
                && message.isDisplayTimeAvailable()
                && operateRealTimeValues(message: message, with: params, config: config)
                && isInLineInApp(inAppMessage: message, propertyID: propertyId, storyPropertyId: storyPropertyId)
            }
        } else {
            return sortedMessages.first { message in
                (message.data.displayCondition.screenNameFilters ?? []).isEmpty
                && message.isDisplayTimeAvailable()
                && operateRealTimeValues(message: message, with: params, config: config)
                && isInLineInApp(inAppMessage: message, propertyID: propertyId, storyPropertyId: storyPropertyId)
            }
        }
    }
    
    private class func isScreenNameMatching(
        screenFilters: [ScreenNameFilter],
        screenName: String,
        logicOperator: RulesOperatorType?
    ) -> Bool {
        let results = screenFilters.map { filter in
            operateScreenValues(value: filter.value,
                                for: screenName,
                                operatorType: filter.operatorType)
        }
        
        switch logicOperator {
        case .AND:
            return !results.contains(false)
        case .OR:
            return results.contains(true)
        case .none:
            return results.contains(true)
        }
    }



    
    private class func isInLineInApp(inAppMessage:InAppMessage, propertyID : String?, storyPropertyId : String? = nil) -> Bool
    {
        if("STORY".caseInsensitiveCompare(inAppMessage.data.content.type ?? "")) == .orderedSame {
            let isPropertyEmpty = storyPropertyId == nil || storyPropertyId == ""
            let isSelectorEmpty = inAppMessage.data.inlineTarget?.iosSelector == "" || inAppMessage.data.inlineTarget?.iosSelector == nil
            if isPropertyEmpty || isSelectorEmpty {
                return false
            } else {
                return inAppMessage.data.inlineTarget?.iosSelector == storyPropertyId
            }
        } else if("INLINE".caseInsensitiveCompare(inAppMessage.data.content.type ?? "")) == .orderedSame {
            let isPropertyEmpty = propertyID == nil || propertyID == ""
            let isSelectorEmpty = inAppMessage.data.inlineTarget?.iosSelector == "" || inAppMessage.data.inlineTarget?.iosSelector == nil
            if isPropertyEmpty || isSelectorEmpty {
                return false
            } else {
                return inAppMessage.data.inlineTarget?.iosSelector == propertyID
            }
        } else if (storyPropertyId == nil || storyPropertyId == "") {
            //TODO: EGEMEN: what is the purpose of this if?
            if (propertyID == nil || propertyID == "" ) && (inAppMessage.data.inlineTarget?.iosSelector == "" || inAppMessage.data.inlineTarget?.iosSelector == nil)
            {
                return true
            }
            if (propertyID != nil || propertyID != "" ) && (inAppMessage.data.inlineTarget?.iosSelector == "" || inAppMessage.data.inlineTarget?.iosSelector == nil )
            {
                return false
            }
            else if (propertyID != nil || propertyID != "" ) && (inAppMessage.data.inlineTarget?.iosSelector != "" || inAppMessage.data.inlineTarget?.iosSelector != nil )
            {
                return inAppMessage.data.inlineTarget?.iosSelector == propertyID
            }
            //TODO: EGEMEN: what is the purpose of this else? Shouldn't this else return false in the following case
            else
            {
                return (propertyID == nil || propertyID == "" )
            }
        }
        return false
    }
    
    private class func operateScreenValues(value screenNameFilterValues: [String],
                                           for screenName: String,
                                           operatorType: ComparisonType) -> Bool {
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
        default:
            return true
        }
    }
    
    // Real Time
    
    private class func operateRealTimeValues(message: InAppMessage,with params: [String:String]? = nil,
                                             config: DengageConfiguration) -> Bool {
        
        guard let ruleSet = message.data.displayCondition.ruleSet,
              message.data.isRealTime
                
        else {
            
            return true
            
            
        }
        
        switch ruleSet.logicOperator {
            
        case .AND:
            return ruleSet.rules.allSatisfy{ rule in
                operateDisplay(for: rule, with: params,config: config, message: message)
            }
        case .OR:
            return ruleSet.rules.contains{ rule in
                operateDisplay(for: rule, with: params, config: config, message: message)
            }
        }
    }
    
    
    private class func operateDisplay(for rule: Rule,
                                      with params: [String:String]? = nil,
                                      config: DengageConfiguration, message:InAppMessage) -> Bool{
        
        switch rule.logicOperatorBetweenCriterions {
        case .AND:
            return rule.criterions.allSatisfy{ criterion in
                operate(criterion, with: params, config: config, message: message)
            }
        case .OR:
            return rule.criterions.contains{ criterion in
                operate(criterion, with: params, config: config, message: message)
            }
        }
    }
    
    private class func operate(_ criterion: Criterion,
                               with params: [String:String]? = nil,
                               config: DengageConfiguration, message:InAppMessage) -> Bool {
        guard let specialRule = SpecialRuleParameter(rawValue: criterion.parameter) else {
            
            if checkVisitorInfoAttr(parameter: criterion.parameter) != ""
            {
                let userParam = checkVisitorInfoAttr(parameter: criterion.parameter)
                
                if criterion.parameter == "dn.master_contact.birth_date" {
                    let daysValue = Int(criterion.values.first ?? "") ?? 0
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    guard let birthDate = dateFormatter.date(from: userParam) else { return false }
                    
                    let today = Date()
                    let calendar = Calendar.current
                    
                    let birthComponents = calendar.dateComponents([.month, .day], from: birthDate)
                    guard let thisYearBirthday = calendar.date(from: DateComponents(
                        year: calendar.component(.year, from: today),
                        month: birthComponents.month,
                        day: birthComponents.day
                    )) else { return false }
                    
                    switch daysValue {
                    case let x where x < 0:
                        let window = -x
                        let lastBirthday = thisYearBirthday > today
                        ? calendar.date(byAdding: .year, value: -1, to: thisYearBirthday)!
                        : thisYearBirthday
                        let daysSince = calendar.dateComponents([.day], from: lastBirthday, to: today).day ?? Int.max
                        return (0...window).contains(daysSince)
                    case 0:
                        return calendar.isDate(today, inSameDayAs: thisYearBirthday)
                    default:
                        let window = daysValue
                        let nextBirthday = thisYearBirthday < today
                        ? calendar.date(byAdding: .year, value: 1, to: thisYearBirthday)!
                        : thisYearBirthday
                        let daysUntil = calendar.dateComponents([.day], from: today, to: nextBirthday).day ?? Int.max
                        return (0...window).contains(daysUntil)
                    }
                } else if criterion.dataType == .DATETIME {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    guard let visitorInfoDate = dateFormatter.date(from: userParam) else { return false }
                    
                    guard let serverDate = dateFormatter.date(from: criterion.values.first ?? "") else { return false }
                    
                    let result = self.compareDate(visitorInfoDate: visitorInfoDate, serverDate: serverDate)
                    
                    
                    switch criterion.comparison {
                    case .EQUALS:
                        if result == .orderedSame
                        {
                            return true
                        }
                        else
                        {
                            return false
                        }
                    case .NOT_EQUALS:
                        
                        if result != .orderedSame
                        {
                            return true
                        }
                        else
                        {
                            return false
                        }
                        
                    case .LATER_THAN:
                        if result == .orderedDescending
                        {
                            return true
                        }
                        else
                        {
                            return false
                        }
                    case .LATER_EQUAL:
                        if result == .orderedDescending || result == .orderedSame
                        {
                            return true
                        }
                        else
                        {
                            return false
                        }
                    case .LESS_THAN:
                        
                        if result == .orderedAscending
                        {
                            return true
                        }
                        else
                        {
                            return false
                        }
                    case .LESS_EQUAL:
                        if result == .orderedDescending || result == .orderedSame
                        {
                            return true
                        }
                        else
                        {
                            return false
                        }
                    default:
                        return true
                    }
                    
                    
                    
                }
                else
                {
                    if userParam == "null" && params != nil
                    {
                        return operate(with: criterion.comparison,
                                       for: criterion.dataType,
                                       ruleParam: criterion.values,
                                       userParam: params?[criterion.parameter], message: message, valueSource: criterion.valueSource)
                    }
                    else
                    {
                        return operate(with: criterion.comparison,
                                       for: criterion.dataType,
                                       ruleParam: criterion.values,
                                       userParam: userParam, message: message, valueSource: criterion.valueSource)
                    }
                   
                }
                
                
            }
            else
            {
                return operate(with: criterion.comparison,
                               for: criterion.dataType,
                               ruleParam: criterion.values,
                               userParam: params?[criterion.parameter], message: message, valueSource: criterion.valueSource)
            }
            
            
        }
        
        
        switch specialRule {
        case .CATEGORY_PATH:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: config.realTimeCategoryPath ?? "", message: message, valueSource: criterion.valueSource)
        case .CART_ITEM_COUNT:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: config.realTimeCartItemCount ?? "0", message: message, valueSource: criterion.valueSource)
        case .CART_AMOUNT:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: config.realTimeCartAmount ?? "0", message: message, valueSource: criterion.valueSource)
        case .STATE:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: config.state ?? "", message: message, valueSource: criterion.valueSource)
        case .CITY:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: config.city ?? "", message: message, valueSource: criterion.valueSource)
        case .TIMEZONE:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: config.deviceTimeZone, message: message, valueSource: criterion.valueSource)
        case .LANGUAGE:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: config.getLanguage(), message: message, valueSource: criterion.valueSource)
        case .SCREEN_WIDTH:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: UIScreen.main.nativeBounds.width.description, message: message, valueSource: criterion.valueSource)
        case .SCREEN_HEIGHT:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: UIScreen.main.nativeBounds.height.description, message: message, valueSource: criterion.valueSource)
        case .OS_VERSION:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: UserAgentUtils.deviceVersion, message: message, valueSource: criterion.valueSource)
        case .OS:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: "ios", message: message, valueSource: criterion.valueSource)
        case .DEVICE_NAME:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: UserAgentUtils.deviceName, message: message, valueSource: criterion.valueSource)
        case .COUNTRY:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: config.deviceCountryCode, message: message, valueSource: criterion.valueSource)
        case .MONTH:
            
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: Date().threeLetterMonth, message: message, valueSource: criterion.valueSource)
        case .WEEK_DAY:
            
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: Date().threeLetterWeekDay , message: message, valueSource: criterion.valueSource)
        case .HOUR:

            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: Date().hour, message: message, valueSource: criterion.valueSource)
        case .PAGE_VIEW_IN_VISIT:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: String(config.pageViewCount), message: message, valueSource: criterion.valueSource)
        case .ANONYMOUS:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: (config.contactKey.type == "c").description, message: message, valueSource: criterion.valueSource)
        case .VISIT_DURATION:
            guard let lastSessionStartTime = DengageLocalStorage.shared.value(for: .lastSessionStartTime) as? Double else {
                return true
            }

            let lastSessionDurationInMinutes = Int((Date().timeIntervalSince1970 - lastSessionStartTime) / 60)
            
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: String(lastSessionDurationInMinutes), message: message, valueSource: criterion.valueSource)
        case .FIRST_VISIT:
            guard
                let firstVisitTime = DengageLocalStorage.shared.value(for: .firstLaunchTime) as? Double else {return true}
            
            var firstVisit = "false"
            if (Date().timeIntervalSince1970 - firstVisitTime) < 3600 {
                firstVisit = "true"
            }
            
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: firstVisit, message: message, valueSource: criterion.valueSource)
        case .LAST_VISIT:
            guard
                let lastVisitTime = DengageLocalStorage.shared.value(for: .lastVisitTime) as? Double else {return true}
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: String(lastVisitTime), message: message, valueSource: criterion.valueSource)
        case .BRAND_NAME:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: "apple", message: message, valueSource: criterion.valueSource)
        case .MODEL_NAME:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: "iphone", message: message, valueSource: criterion.valueSource)
        case .PUSH_PERMISSION:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: config.permission.description, message: message, valueSource: criterion.valueSource)
            
    
            
        case .VISIT_COUNT:
            guard (criterion.dataType == .VISITCOUNTPASTXDAYS && !criterion.values.isEmpty) else { return true }
            guard let visitCountData = criterion.values.first else { return true }
            let data = Data(visitCountData.utf8)
            let decoder = JSONDecoder()
            do {
                let visitCount = try decoder.decode(VisitCountData.self,
                                                    from: data)
                return operate(with: criterion.comparison,
                               for: CriterionDataType.INT,
                               ruleParam: [visitCount.count.description],
                               userParam: DengageVisitCountManager.findVisitCount(pastDayCount: visitCount.timeAmount).description, message: message, valueSource: criterion.valueSource)
            } catch {
                return true
            }
        case .SEGMENT:
            guard
                let visitorInfo = DengageLocalStorage.shared.getVisitorInfo(),
                let segments = visitorInfo.segments,
                !segments.isEmpty
            else {return false}
            return operateVisitorRule(with: criterion.comparison,
                                      for: criterion.dataType,
                                      ruleParam: criterion.values,
                                      userParam: segments.map{String($0)})
        case .TAG:
            guard
                let visitorInfo = DengageLocalStorage.shared.getVisitorInfo(),
                let tags = visitorInfo.tags,
                !tags.isEmpty
            else {return false}
            return operateVisitorRule(with: criterion.comparison,
                                      for: criterion.dataType,
                                      ruleParam: criterion.values,
                                      userParam: tags.map{String($0)})
        case .EVENT_HISTORY:
            return operateEventHistoryFilter(criterion: criterion)
        case .CART:
            return true

        }
    }
    
    private class func operateVisitorRule(
        with operatorType: ComparisonType,
        for dataType: CriterionDataType,
        ruleParam: [String]? = nil,
        userParam: [String]? = nil
    ) -> Bool {
        guard
            let ruleParam = ruleParam, let userParam = userParam, dataType == .TEXTLIST
        else {
            return true
        }
        let isRuleContainsUserParam = userParam.first(where: {ruleParam.contains($0)}) != nil
        // visitor rules only work with IN and NOT_IN operator
        switch operatorType {
        case .IN:
            return isRuleContainsUserParam
        case .NOT_IN:
            return !isRuleContainsUserParam
        default:
            return true
        }
    }
    
    private class func operate(
        with operatorType: ComparisonType,
        for dataType: CriterionDataType,
        ruleParam: [String]? = nil,
        userParam: String? = nil, message: InAppMessage, valueSource : String
    ) -> Bool {
        
        
        guard
            let ruleParam = ruleParam,
            let userParam = userParam,
            ruleParam.isEmpty == false
        else {
            
            if message.data.isRealTime && valueSource == "CUSTOM"
            {
                return false
            }
            else
            {
                return true
            }
            
            
        }
        
        switch operatorType {
        case .EQUALS:
            return ruleParam.first{$0.lowercased() == userParam.lowercased()} != nil
        case .NOT_EQUALS:
            return ruleParam.first{$0.lowercased() == userParam.lowercased()} == nil
        case .LIKE:
            return ruleParam.first { userParam.lowercased().contains($0.lowercased()) } != nil
        case .NOT_LIKE:
            return ruleParam.first { userParam.lowercased().contains($0.lowercased()) } == nil
        case .STARTS_WITH:
            return ruleParam.first { userParam.lowercased().hasPrefix($0.lowercased()) } != nil
        case .NOT_STARTS_WITH:
            return ruleParam.first { userParam.lowercased().hasPrefix($0.lowercased()) } == nil
        case .ENDS_WITH:
            return ruleParam.first { userParam.lowercased().hasSuffix($0.lowercased()) } != nil
        case .NOT_ENDS_WITH:
            return ruleParam.first { userParam.lowercased().hasSuffix($0.lowercased()) } == nil
        case .IN:
            return ruleParam.first{$0.lowercased() == userParam.lowercased()} != nil
        case .NOT_IN:
            return ruleParam.first{$0.lowercased() == userParam.lowercased()} == nil
        case .GREATER_THAN:
            guard
                dataType == .DATETIME || dataType == .INT,
                let userParamDouble = Double(userParam)
            else {
                return true
            }
            
            let ruleParams = ruleParam.compactMap{Double($0)}
            return ruleParams.first{userParamDouble <= $0 } == nil
        case .GREATER_EQUAL:
            guard
                dataType == .DATETIME || dataType == .INT,
                let userParamDouble = Double(userParam)
            else {
                return true
            }
            
            let ruleParams = ruleParam.compactMap{Double($0)}
            return ruleParams.first{userParamDouble < $0 } == nil
        case .LESS_THAN:
            guard
                dataType == .DATETIME || dataType == .INT,
                let userParamDouble = Double(userParam)
            else {
                return true
            }
            
            let ruleParams = ruleParam.compactMap{Double($0)}
            return ruleParams.first{userParamDouble >= $0 } == nil
        case .LESS_EQUAL:
            guard
                dataType == .DATETIME || dataType == .INT,
                let userParamDouble = Double(userParam)
            else {
                return true
            }
            
            let ruleParams = ruleParam.compactMap{Double($0)}
            return ruleParams.first{userParamDouble > $0 } == nil
        default:
            return true
        }
        
    }
    
    private class func checkVisitorInfoAttr(parameter : String) -> String
    {
        if parameter != ""
        {
            let visitorInfo = DengageLocalStorage.shared.getVisitorInfo()
            var attribute = visitorInfo?.Attrs
            
            if attribute?[parameter] != nil
            {
                return "\(attribute?[parameter] ?? "")"
            }
            
        }
        
        return ""
        
    }
    
    private class func daysUntil(birthday: Date) -> Int {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let date = cal.startOfDay(for: birthday)
        let components = cal.dateComponents([.day, .month], from: date)
        let nextDate = cal.nextDate(after: today, matching: components, matchingPolicy: .nextTimePreservingSmallerComponents)
        return cal.dateComponents([.day], from: today, to: nextDate ?? today).day ?? 0
    }
    
    private class func compareDate(visitorInfoDate : Date , serverDate: Date) -> ComparisonResult {
        let cal = Calendar.current
        let result = cal.compare(visitorInfoDate, to: serverDate, toGranularity: .day)
        return result
    }
    
    private class func operateEventHistoryFilter(criterion: Criterion) -> Bool {
        
        guard let eventType = criterion.eventType else { return false }
        
        let clientEvents = DengageLocalStorage.shared.getClientEvents()
        guard let tableEvents = clientEvents[eventType] else { return false }
        
        let windowMillis = parseTimeWindow(criterion.timeWindow)
        let cutoffTime = Date().timeIntervalSince1970 * 1000 - windowMillis
        
        let eventsInWindow = tableEvents.filter { $0.timestamp >= cutoffTime }
        
        let filteredEvents: [ClientEvent]
        if let filters = criterion.filters, !filters.isEmpty {
            filteredEvents = applyEventFilters(events: eventsInWindow,
                                               filters: filters,
                                               logicalOp: criterion.filtersLogicalOp)
        } else {
            filteredEvents = eventsInWindow
        }
        
        let aggregateValue: Int
        switch criterion.aggregateType {
        case "count":
            aggregateValue = filteredEvents.count
        case "distinct_count":
            guard let field = criterion.aggregateField else { return false }
            let distinctValues = Set(filteredEvents.compactMap { event in
                event.eventDetails[field] as? String
            })
            aggregateValue = distinctValues.count
        default:
            return false
        }
        
        guard let targetValueString = criterion.values.first,
              let targetValue = Int(targetValueString) else { return false }
        
        switch criterion.comparison {
        case .EQUALS:
            return aggregateValue == targetValue
        case .NOT_EQUALS:
            return aggregateValue != targetValue
        case .GREATER_THAN:
            return aggregateValue > targetValue
        case .GREATER_EQUAL:
            return aggregateValue >= targetValue
        case .LESS_THAN:
            return aggregateValue < targetValue
        case .LESS_EQUAL:
            return aggregateValue <= targetValue
        default:
            return false
        }
    }
    
    private class func parseTimeWindow(_ timeWindow: TimeWindow?) -> Double {
        guard let timeWindow = timeWindow else { return Double.greatestFiniteMagnitude }
        
        do {
            // Parse ISO 8601 duration format (e.g., P7D, PT24H, P30M)
            let pattern = "P(?:(\\d+)D)?(?:T(?:(\\d+)H)?(?:(\\d+)M)?(?:(\\d+)S)?)?"
            let regex = try NSRegularExpression(pattern: pattern)
            let nsString = timeWindow.value as NSString
            let results = regex.matches(in: timeWindow.value, range: NSRange(location: 0, length: nsString.length))
            
            guard let match = results.first else { return Double.greatestFiniteMagnitude }
            
            var days: Double = 0
            var hours: Double = 0
            var minutes: Double = 0
            var seconds: Double = 0
            
            if match.range(at: 1).location != NSNotFound {
                days = Double(nsString.substring(with: match.range(at: 1))) ?? 0
            }
            if match.range(at: 2).location != NSNotFound {
                hours = Double(nsString.substring(with: match.range(at: 2))) ?? 0
            }
            if match.range(at: 3).location != NSNotFound {
                minutes = Double(nsString.substring(with: match.range(at: 3))) ?? 0
            }
            if match.range(at: 4).location != NSNotFound {
                seconds = Double(nsString.substring(with: match.range(at: 4))) ?? 0
            }
            
            return (days * 24 * 60 * 60 * 1000) +
                   (hours * 60 * 60 * 1000) +
                   (minutes * 60 * 1000) +
                   (seconds * 1000)
        } catch {
            DengageLog().log(message: "Error parsing time window: \(error.localizedDescription)")
            return Double.greatestFiniteMagnitude
        }
    }
    
    private class func applyEventFilters(events: [ClientEvent], 
                                       filters: [EventFilter], 
                                       logicalOp: String?) -> [ClientEvent] {
        if filters.isEmpty { return events }
        
        return events.filter { event in
            let filterResults = filters.map { filter in
                applyEventFilter(event: event, filter: filter)
            }
            
            switch logicalOp {
            case "AND":
                return filterResults.allSatisfy { $0 }
            case "OR":
                return filterResults.contains(true)
            default:
                return filterResults.allSatisfy { $0 } // default to AND
            }
        }
    }
    
    private class func applyEventFilter(event: ClientEvent, filter: EventFilter) -> Bool {
        guard let fieldValue = event.eventDetails[filter.field] as? String else { return false }
        
        switch filter.op {
        case "EQUALS", "EQ":
            return filter.values.contains(fieldValue)
        case "NOT_EQUALS", "NE":
            return !filter.values.contains(fieldValue)
        case "IN":
            return filter.values.contains(fieldValue)
        case "NOT_IN":
            return !filter.values.contains(fieldValue)
        case "LIKE":
            return filter.values.contains { fieldValue.lowercased().contains($0.lowercased()) }
        case "NOT_LIKE":
            return !filter.values.contains { fieldValue.lowercased().contains($0.lowercased()) }
        case "STARTS_WITH":
            return filter.values.contains { fieldValue.lowercased().hasPrefix($0.lowercased()) }
        case "NOT_STARTS_WITH":
            return !filter.values.contains { fieldValue.lowercased().hasPrefix($0.lowercased()) }
        case "ENDS_WITH":
            return filter.values.contains { fieldValue.lowercased().hasSuffix($0.lowercased()) }
        case "NOT_ENDS_WITH":
            return !filter.values.contains { fieldValue.lowercased().hasSuffix($0.lowercased()) }
        case "GREATER_THAN", "GT":
            guard let numFieldValue = Double(fieldValue),
                  let numFilterValue = Double(filter.values.first ?? "") else { return false }
            return numFieldValue > numFilterValue
        case "GREATER_EQUAL", "GTE":
            guard let numFieldValue = Double(fieldValue),
                  let numFilterValue = Double(filter.values.first ?? "") else { return false }
            return numFieldValue >= numFilterValue
        case "LESS_THAN", "LT":
            guard let numFieldValue = Double(fieldValue),
                  let numFilterValue = Double(filter.values.first ?? "") else { return false }
            return numFieldValue < numFilterValue
        case "LESS_EQUAL", "LTE":
            guard let numFieldValue = Double(fieldValue),
                  let numFilterValue = Double(filter.values.first ?? "") else { return false }
            return numFieldValue <= numFilterValue
        default:
            return false
        }
    }
}

enum SpecialRuleParameter: String {
    case CATEGORY_PATH = "dn.cat_path"
    case CART_ITEM_COUNT = "dn.cart_item_count"
    case CART_AMOUNT = "dn.cart_amount"
    case STATE = "dn.state"
    case CITY = "dn.city"
    case TIMEZONE = "dn.tz"
    case LANGUAGE = "dn.lang"
    case SCREEN_WIDTH = "dn.sc_width"
    case SCREEN_HEIGHT = "dn.sc_height"
    case OS_VERSION = "dn.os_ver"
    case OS = "dn.os"
    case DEVICE_NAME = "dn.device_name"
    case COUNTRY = "dn.country"
    case MONTH = "dn.month"
    case WEEK_DAY = "dn.week_day"
    case HOUR = "dn.hour"
    case PAGE_VIEW_IN_VISIT = "dn.pviv"
    case ANONYMOUS = "dn.anonym"
    case VISIT_DURATION = "dn.visit_duration"
    case FIRST_VISIT = "dn.first_visit"
    case LAST_VISIT = "dn.last_visit_ts"
    case BRAND_NAME = "dn.brand_name"
    case MODEL_NAME = "dn.model_nam"
    case PUSH_PERMISSION = "dn.wp_perm"
    case VISIT_COUNT = "dn.visit_count"
    case SEGMENT = "dn.segment"
    case TAG = "dn.tag"
    case EVENT_HISTORY = "event_history"
    case CART = "cart"
}

struct VisitCountData: Codable {
    let count: Int
    let timeAmount: Int
}


