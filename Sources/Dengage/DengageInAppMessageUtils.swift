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
    class func findPriorInAppMessage(inAppMessages: [InAppMessage],
                                     screenName: String? = nil,
                                     params: [String:String]? = nil,
                                     config: DengageConfiguration) -> InAppMessage? {
        
        if let screenName = screenName, !screenName.isEmpty  {
            
            let inAppMessageWithScreenName = inAppMessages.sorted.first { message -> Bool in
                
                if let arrScreenFilter = message.data.displayCondition.screenNameFilters
                {
                    if message.isDisplayTimeAvailable() && operateRealTimeValues(message: message,params: params,config: config)
                    {
                        let operatorFilter = message.data.displayCondition.screenNameFilterLogicOperator
                        
                        var arrDisplay = [Bool]()
                        
                        for nameFilter in arrScreenFilter
                        {
                            arrDisplay.append(operateScreenValues(value: nameFilter.value, for: screenName, operatorType: nameFilter.operatorType))
                        }
                        
                        switch operatorFilter {
                            
                        case .AND:
                            
                            let isDisplay = arrDisplay.filter{($0 == false)}
                            
                            if isDisplay.count == 0
                            {
                                return true
                            }
                            
                        case .OR:
                            
                            let isDisplay = arrDisplay.filter{($0 == true)}
                            
                            if isDisplay.count != 0
                            {
                                return true
                            }
                            
                        case .none:
                            
                            return message.data.displayCondition.screenNameFilters?.first{ nameFilter -> Bool in
                                
                                return operateScreenValues(value: nameFilter.value, for: screenName, operatorType: nameFilter.operatorType)
                                
                            } != nil && message.isDisplayTimeAvailable() && operateRealTimeValues(message: message,params: params,config: config)
                        }
                    }
                    
                }
                
                return false
                
            }
            
            return inAppMessageWithScreenName
            
        }else {
            
            let inAppMessageWithoutScreenName = inAppMessages.sorted.first { message -> Bool in
                return (message.data.displayCondition.screenNameFilters ?? []).isEmpty && message.isDisplayTimeAvailable() && operateRealTimeValues(message: message, params: params, config: config)
            }
            return inAppMessageWithoutScreenName
        }
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
    
    private class func operateRealTimeValues(message: InAppMessage,
                                             params: [String:String]? = nil,
                                             config: DengageConfiguration) -> Bool {
        
        guard let ruleSet = message.data.displayCondition.ruleSet,
              message.data.isRealTime
                
        else {
            
            return true
            
            
        }
        
        switch ruleSet.logicOperator {
        case .AND:
            return ruleSet.rules.allSatisfy{ rule in
                operateDisplay(for: rule, with: params, config: config, message: message)
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
                
                if criterion.parameter == "dn.master_contact.birth_date"
                {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    guard let formatedStartDate = dateFormatter.date(from: userParam) else { return false }
                    
                    let diffInDays = self.daysUntil(birthday: formatedStartDate)
                    
                    let diffInDaysStr = "\(diffInDays)"
                    
                    if diffInDaysStr == criterion.values.first
                    {
                        return true
                    }
                    else
                    {
                        return false
                    }
                    
                }
                else if criterion.dataType == .DATETIME
                {
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
                    return operate(with: criterion.comparison,
                                   for: criterion.dataType,
                                   ruleParam: criterion.values,
                                   userParam: userParam, message: message, valueSource: criterion.valueSource)
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
                           userParam: config.deviceLanguage, message: message, valueSource: criterion.valueSource)
        case .SCREEN_WIDTH:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: UIScreen.main.bounds.width.description, message: message, valueSource: criterion.valueSource)
        case .SCREEN_HEIGHT:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: UIScreen.main.bounds.height.description, message: message, valueSource: criterion.valueSource)
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
                           userParam: Date().month, message: message, valueSource: criterion.valueSource)
        case .WEEK_DAY:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: Date().weekDay, message: message, valueSource: criterion.valueSource)
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
            guard
                let lastSessionStartTime = DengageLocalStorage.shared.value(for: .lastSessionStartTime) as? Double else {return true}
            let lastSessionDuration = (Date().timeIntervalSince1970 - lastSessionStartTime)
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: String(lastSessionDuration), message: message, valueSource: criterion.valueSource)
        case .FIRST_VISIT:
            guard
                let firstVisitTime = DengageLocalStorage.shared.value(for: .firstLaunchTime) as? Double else {return true}
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: String(firstVisitTime), message: message, valueSource: criterion.valueSource)
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
            else {return true}
            return operateVisitorRule(with: criterion.comparison,
                                      for: criterion.dataType,
                                      ruleParam: criterion.values,
                                      userParam: segments.map{String($0)})
        case .TAG:
            guard
                let visitorInfo = DengageLocalStorage.shared.getVisitorInfo(),
                let tags = visitorInfo.tags,
                !tags.isEmpty
            else {return true}
            return operateVisitorRule(with: criterion.comparison,
                                      for: criterion.dataType,
                                      ruleParam: criterion.values,
                                      userParam: tags.map{String($0)})
            
            
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
    
    
}

struct VisitCountData: Codable {
    let count: Int
    let timeAmount: Int
}

