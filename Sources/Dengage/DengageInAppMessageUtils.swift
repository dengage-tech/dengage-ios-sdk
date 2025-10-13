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
        
        let isDebugDevice = isDebugDevice(config: config)
        let traceId = isDebugDevice ? UUID().uuidString : nil
        let currentCampaignList = isDebugDevice ? getCurrentCampaignList(inAppMessages: inAppMessages) : []
        
        let sortedMessages = inAppMessages.sorted
        
        if let screenName = screenName, !screenName.isEmpty {
            if let matchedMessage = sortedMessages.first(where: { message in
                var context = [String: String]()
                var criterionIndex = 0
                
                // Add screen name context if present
                if let screenNameFilter = message.data.displayCondition.screenNameFilters?.first {
                    let expectedScreenName = screenNameFilter.value.joined(separator: ",")
                    let operatorType = screenNameFilter.operatorType.rawValue
                    let screenNameResult = isScreenNameMatching(screenFilters: message.data.displayCondition.screenNameFilters ?? [], screenName: screenName, logicOperator: message.data.displayCondition.screenNameFilterLogicOperator)
                    context["screen_name_\(criterionIndex)"] = "\(expectedScreenName)|\(screenName)|\(operatorType)|\(screenNameResult)"
                    criterionIndex += 1
                }
                
                let result = message.isDisplayTimeAvailable()
                && isScreenNameMatching(screenFilters: message.data.displayCondition.screenNameFilters ?? [],
                                        screenName: screenName,
                                        logicOperator: message.data.displayCondition.screenNameFilterLogicOperator)
                && operateRealTimeValues(message: message, with: params, config: config, context: &context, criterionIndex: &criterionIndex)
                && isInLineInApp(inAppMessage: message, propertyID: propertyId, storyPropertyId: storyPropertyId)
                
                if isDebugDevice, let traceId = traceId {
                    sendEvaluationLog(
                        inAppMessage: message,
                        traceId: traceId,
                        screenName: screenName,
                        currentCampaignList: currentCampaignList,
                        matched: result,
                        context: context,
                        config: config
                    )
                }
                
                return result
            }) {
                return matchedMessage
            }
            
            return sortedMessages.first { message in
                var context = [String: String]()
                var criterionIndex = 0
                
                let result = (message.data.displayCondition.screenNameFilters ?? []).isEmpty
                && message.isDisplayTimeAvailable()
                && operateRealTimeValues(message: message, with: params, config: config, context: &context, criterionIndex: &criterionIndex)
                && isInLineInApp(inAppMessage: message, propertyID: propertyId, storyPropertyId: storyPropertyId)
                
                if isDebugDevice, let traceId = traceId, (message.data.displayCondition.screenNameFilters ?? []).isEmpty {
                    sendEvaluationLog(
                        inAppMessage: message,
                        traceId: traceId,
                        screenName: screenName,
                        currentCampaignList: currentCampaignList,
                        matched: result,
                        context: context,
                        config: config
                    )
                }
                
                return result
            }
        } else {
            return sortedMessages.first { message in
                var context = [String: String]()
                var criterionIndex = 0
                
                let result = (message.data.displayCondition.screenNameFilters ?? []).isEmpty
                && message.isDisplayTimeAvailable()
                && operateRealTimeValues(message: message, with: params, config: config, context: &context, criterionIndex: &criterionIndex)
                && isInLineInApp(inAppMessage: message, propertyID: propertyId, storyPropertyId: storyPropertyId)
                
                if isDebugDevice, let traceId = traceId {
                    sendEvaluationLog(
                        inAppMessage: message,
                        traceId: traceId,
                        screenName: screenName,
                        currentCampaignList: currentCampaignList,
                        matched: result,
                        context: context,
                        config: config
                    )
                }
                
                return result
            }
        }
    }
    
    private class func isDebugDevice(config: DengageConfiguration) -> Bool {
        guard let debugDeviceIds = config.remoteConfiguration?.debugDeviceIds else { return false }
        return debugDeviceIds.contains(config.applicationIdentifier)
    }
    
    private class func getCurrentCampaignList(inAppMessages: [InAppMessage]) -> [String] {
        return inAppMessages.map { message in
            let prefix = message.data.isRealTime ? "r_" : "f_"
            return prefix + (message.data.publicId ?? message.id)
        }
    }
    
    private class func sendEvaluationLog(
        inAppMessage: InAppMessage,
        traceId: String,
        screenName: String?,
        currentCampaignList: [String],
        matched: Bool,
        context: [String: String],
        config: DengageConfiguration
    ) {
        DispatchQueue.global(qos: .background).async {
            do {
                let sessionManager = DengageSessionManager(config: config)
                
                let debugLog = DebugLog(
                    traceId: traceId,
                    appGuid: config.remoteConfiguration?.appId,
                    appId: config.remoteConfiguration?.appId,
                    account: config.remoteConfiguration?.accountName,
                    device: config.applicationIdentifier,
                    sessionId: sessionManager.currentSessionId,
                    sdkVersion: SDK_VERSION,
                    currentCampaignList: currentCampaignList,
                    campaignId: inAppMessage.data.publicId ?? inAppMessage.id,
                    campaignType: inAppMessage.data.isRealTime ? "realtime" : "bulk",
                    sendId: inAppMessage.data.isRealTime ? nil : inAppMessage.id,
                    message: matched ? "Campaign matched for evaluation" : "Campaign unmatched for evaluation",
                    context: context,
                    contactKey: config.getContactKey(),
                    channel: "ios",
                    currentRules: [
                        "displayCondition": try JSONSerialization.jsonObject(with: JSONEncoder().encode(inAppMessage.data.displayCondition))
                    ]
                )
                
                let request = DebugLogRequest(screenName: screenName ?? "unknown", debugLog: debugLog)
                let apiClient = DengageNetworking(config: config)
                
                apiClient.send(request: request) { result in
                    switch result {
                    case .success:
                        Logger.log(message: "Debug log sent successfully")
                    case .failure(let error):
                        Logger.log(message: "Error sending debug log: \(error.localizedDescription)")
                    }
                }
            } catch {
                Logger.log(message: "Error creating debug log: \(error.localizedDescription)")
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
                                             config: DengageConfiguration, context: inout [String: String], criterionIndex: inout Int) -> Bool {
        
        guard let ruleSet = message.data.displayCondition.ruleSet,
              message.data.isRealTime
                
        else {
            
            return true
            
            
        }
        
        switch ruleSet.logicOperator {
            
        case .AND:
            return ruleSet.rules.allSatisfy{ rule in
                operateDisplay(for: rule, with: params,config: config, message: message, context: &context, criterionIndex: &criterionIndex)
            }
        case .OR:
            return ruleSet.rules.contains{ rule in
                operateDisplay(for: rule, with: params, config: config, message: message, context: &context, criterionIndex: &criterionIndex)
            }
        }
    }
    
    
    private class func operateDisplay(for rule: Rule,
                                      with params: [String:String]? = nil,
                                      config: DengageConfiguration, message:InAppMessage, context: inout [String: String], criterionIndex: inout Int) -> Bool{
        
        switch rule.logicOperatorBetweenCriterions {
        case .AND:
            return rule.criterions.allSatisfy{ criterion in
                let result = operate(criterion, with: params, config: config, message: message, context: &context, criterionIndex: criterionIndex)
                criterionIndex += 1
                return result
            }
        case .OR:
            return rule.criterions.contains{ criterion in
                let result = operate(criterion, with: params, config: config, message: message, context: &context, criterionIndex: criterionIndex)
                criterionIndex += 1
                return result
            }
        }
    }
    
    private class func operate(_ criterion: Criterion,
                               with params: [String:String]? = nil,
                               config: DengageConfiguration, message:InAppMessage, context: inout [String: String], criterionIndex: Int) -> Bool {
        
        var actualValue = ""
        var result = false
        
        guard let specialRule = SpecialRuleParameter(rawValue: criterion.parameter) else {
            
            if checkVisitorInfoAttr(parameter: criterion.parameter) != ""
            {
                let userParam = checkVisitorInfoAttr(parameter: criterion.parameter)
                actualValue = userParam
                
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
                        result = (0...window).contains(daysSince)
                    case 0:
                        result = calendar.isDate(today, inSameDayAs: thisYearBirthday)
                    default:
                        let window = daysValue
                        let nextBirthday = thisYearBirthday < today
                        ? calendar.date(byAdding: .year, value: 1, to: thisYearBirthday)!
                        : thisYearBirthday
                        let daysUntil = calendar.dateComponents([.day], from: today, to: nextBirthday).day ?? Int.max
                        result = (0...window).contains(daysUntil)
                    }
                } else if criterion.dataType == .DATETIME {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    guard let visitorInfoDate = dateFormatter.date(from: userParam) else { return false }
                    
                    guard let serverDate = dateFormatter.date(from: criterion.values.first ?? "") else { return false }
                    
                    let comparisonResult = self.compareDate(visitorInfoDate: visitorInfoDate, serverDate: serverDate)
                    
                    switch criterion.comparison {
                    case .EQUALS:
                        result = comparisonResult == .orderedSame
                    case .NOT_EQUALS:
                        result = comparisonResult != .orderedSame
                    case .LATER_THAN:
                        result = comparisonResult == .orderedDescending
                    case .LATER_EQUAL:
                        result = comparisonResult == .orderedDescending || comparisonResult == .orderedSame
                    case .LESS_THAN:
                        result = comparisonResult == .orderedAscending
                    case .LESS_EQUAL:
                        result = comparisonResult == .orderedDescending || comparisonResult == .orderedSame
                    default:
                        result = true
                    }
                }
                else
                {
                    if userParam == "null" && params != nil
                    {
                        actualValue = params?[criterion.parameter] ?? ""
                        result = operate(with: criterion.comparison,
                                       for: criterion.dataType,
                                       ruleParam: criterion.values,
                                       userParam: actualValue, message: message, valueSource: criterion.valueSource)
                    }
                    else
                    {
                        result = operate(with: criterion.comparison,
                                       for: criterion.dataType,
                                       ruleParam: criterion.values,
                                       userParam: userParam, message: message, valueSource: criterion.valueSource)
                    }
                   
                }
                
                
            }
            else
            {
                actualValue = params?[criterion.parameter] ?? ""
                result = operate(with: criterion.comparison,
                               for: criterion.dataType,
                               ruleParam: criterion.values,
                               userParam: actualValue, message: message, valueSource: criterion.valueSource)
            }
            
            // Add to context
            let key = "\(criterion.parameter)_\(criterionIndex)"
            let expectedValue = criterion.values.joined(separator: ",")
            context[key] = "\(expectedValue)|\(actualValue)|\(criterion.comparison.rawValue)|\(result)"
            
            return result
        }
        
        // Handle special rule parameters and add to context
        switch specialRule {
        case .CATEGORY_PATH:
            actualValue = config.realTimeCategoryPath ?? ""
            result = operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: actualValue, message: message, valueSource: criterion.valueSource)
        case .CART_ITEM_COUNT:
            result = operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: config.realTimeCartItemCount ?? "0", message: message, valueSource: criterion.valueSource)
        case .CART_AMOUNT:
            result = operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: config.realTimeCartAmount ?? "0", message: message, valueSource: criterion.valueSource)
        case .STATE:
            result = operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: config.state ?? "", message: message, valueSource: criterion.valueSource)
        case .CITY:
            result = operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: config.city ?? "", message: message, valueSource: criterion.valueSource)
        case .TIMEZONE:
            result = operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: config.deviceTimeZone, message: message, valueSource: criterion.valueSource)
        case .LANGUAGE:
            result = operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: config.getLanguage(), message: message, valueSource: criterion.valueSource)
        case .SCREEN_WIDTH:
            result = operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: UIScreen.main.nativeBounds.width.description, message: message, valueSource: criterion.valueSource)
        case .SCREEN_HEIGHT:
            result = operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: UIScreen.main.nativeBounds.height.description, message: message, valueSource: criterion.valueSource)
        case .OS_VERSION:
            result = operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: UserAgentUtils.deviceVersion, message: message, valueSource: criterion.valueSource)
        case .OS:
            result = operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: "ios", message: message, valueSource: criterion.valueSource)
        case .DEVICE_NAME:
            result = operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: UserAgentUtils.deviceName, message: message, valueSource: criterion.valueSource)
        case .COUNTRY:
            result = operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: config.deviceCountryCode, message: message, valueSource: criterion.valueSource)
        case .MONTH:
            
            result = operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: Date().threeLetterMonth, message: message, valueSource: criterion.valueSource)
        case .WEEK_DAY:
            
            result = operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: Date().threeLetterWeekDay , message: message, valueSource: criterion.valueSource)
        case .HOUR:

            result = operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: Date().hour, message: message, valueSource: criterion.valueSource)
        case .PAGE_VIEW_IN_VISIT:
            result = operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: String(config.pageViewCount), message: message, valueSource: criterion.valueSource)
        case .ANONYMOUS:
            result = operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: (config.contactKey.type == "d").description, message: message, valueSource: criterion.valueSource)
        case .VISIT_DURATION:
            guard let lastSessionStartTime = DengageLocalStorage.shared.value(for: .lastSessionStartTime) as? Double else {
                return true
            }

            let lastSessionDurationInMinutes = Int((Date().timeIntervalSince1970 - lastSessionStartTime) / 60)
            
            result = operate(with: criterion.comparison,
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
            
            result = operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: firstVisit, message: message, valueSource: criterion.valueSource)
        case .LAST_VISIT:
            guard
                let lastVisitTime = DengageLocalStorage.shared.value(for: .lastVisitTime) as? Double else {return true}
            result = operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: String(lastVisitTime), message: message, valueSource: criterion.valueSource)
        case .BRAND_NAME:
            result = operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: "apple", message: message, valueSource: criterion.valueSource)
        case .MODEL_NAME:
            result = operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: "iphone", message: message, valueSource: criterion.valueSource)
        case .PUSH_PERMISSION:
            result = operate(with: criterion.comparison,
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
            return DengageEventHistoryUtils.operateEventHistoryFilter(criterion: criterion)
        case .CART_ITEMS:
            return DengageCartUtils.operateCartFilter(criterion: criterion)
        case .LAST_PRODUCT_ID:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: config.getLastProductId() ?? "", message: message, valueSource: criterion.valueSource)
        case .LAST_PRODUCT_PRICE:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: config.getLastProductPrice() ?? "", message: message, valueSource: criterion.valueSource)
        case .LAST_CATEGORY_PATH:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: config.getLastCategoryPath() ?? "", message: message, valueSource: criterion.valueSource)
        case .CURRENT_PAGE_TITLE:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: config.getCurrentPageTitle() ?? "", message: message, valueSource: criterion.valueSource)
        case .CURRENT_PAGE_TYPE:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: config.getCurrentPageType() ?? "", message: message, valueSource: criterion.valueSource)
        }
        
        return result
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
        case .CONTAINS_ALL:
            return ruleParam.allSatisfy { ruleValue in
                userParam.lowercased().contains(ruleValue.lowercased())
            }
        case .CONTAINS_ANY:
            return ruleParam.contains { ruleValue in
                userParam.lowercased().contains(ruleValue.lowercased())
            }
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
    case CART_ITEMS = "cart_items"
    case LAST_PRODUCT_ID = "last_product_id"
    case LAST_PRODUCT_PRICE = "last_product_price"
    case LAST_CATEGORY_PATH = "last_category_path"
    case CURRENT_PAGE_TITLE = "current_page_title"
    case CURRENT_PAGE_TYPE = "current_page_type"
}

struct VisitCountData: Codable {
    let count: Int
    let timeAmount: Int
}


