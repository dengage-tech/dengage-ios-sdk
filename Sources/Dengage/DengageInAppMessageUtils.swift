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
        
        let inAppMessageWithoutScreenName = inAppMessages.sorted.first { message -> Bool in
            return (message.data.displayCondition.screenNameFilters ?? []).isEmpty && isDisplayTimeAvailable(for: message) && operateRealTimeValues(message: message, params: params, config: config)
        }
        
        if let screenName = screenName, !screenName.isEmpty{
            let inAppMessageWithScreenName = inAppMessages.sorted.first { message -> Bool in
                return message.data.displayCondition.screenNameFilters?.first{ nameFilter -> Bool in
                    return operateScreenValues(value: nameFilter.value, for: screenName, operatorType: nameFilter.operatorType)
                } != nil && isDisplayTimeAvailable(for: message) && operateRealTimeValues(message: message,
                                                                                          params: params,
                                                                                          config: config)
            }
            return inAppMessageWithScreenName
        }else{
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
    
    private class func isDisplayTimeAvailable(for inAppMessage: InAppMessage)  -> Bool {
        return true
        return (inAppMessage.data.displayTiming.showEveryXMinutes == nil ||
                inAppMessage.data.displayTiming.showEveryXMinutes == 0 ||
                (inAppMessage.nextDisplayTime ?? Date().timeMiliseconds) <= Date().timeMiliseconds)
    }
    
    // Real Time
    
    private class func operateRealTimeValues(message: InAppMessage,
                                             params: [String:String]? = nil,
                                             config: DengageConfiguration) -> Bool {
        guard let ruleSet = message.data.displayCondition.ruleSet,
              message.data.isRealTime else { return true }
        
        switch ruleSet.logicOperator {
        case .AND:
            print(message.data.publicId)
            return ruleSet.rules.allSatisfy{ rule in
                operateDisplay(for: rule, with: params, config: config)
            }
        case .OR:
            return ruleSet.rules.contains{ rule in
                operateDisplay(for: rule, with: params, config: config)
            }
        }
    }
    
    
    private class func operateDisplay(for rule: Rule,
                                      with params: [String:String]? = nil,
                                      config: DengageConfiguration) -> Bool{
        switch rule.logicOperatorBetweenCriterions {
        case .AND:
            return rule.criterions.allSatisfy{ criterion in
                operate(criterion, with: params, config: config)
            }
        case .OR:
            return rule.criterions.contains{ criterion in
                operate(criterion, with: params, config: config)
            }
        }
    }
    
    private class func operate(_ criterion: Criterion,
                               with params: [String:String]? = nil,
                               config: DengageConfiguration) -> Bool {
        guard let specialRule = SpecialRuleParameter(rawValue: criterion.parameter) else {
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: params?[criterion.parameter])
        }
        
        
        switch specialRule {
        case .CATEGORY_PATH:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: config.realTimeCategoryPath ?? "")
        case .CART_ITEM_COUNT:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: config.realTimeCartItemCount ?? "0")
        case .CART_AMOUNT:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: config.realTimeCartAmount ?? "0")
        case .STATE:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: config.state ?? "")
        case .CITY:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: config.city ?? "")
        case .TIMEZONE:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: config.deviceTimeZone)
        case .LANGUAGE:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: config.deviceLanguage)
        case .SCREEN_WIDTH:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: UIScreen.main.bounds.width.description)
        case .SCREEN_HEIGHT:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: UIScreen.main.bounds.height.description)
        case .OS_VERSION:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: UserAgentUtils.deviceVersion)
        case .OS:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: "ios")
        case .DEVICE_NAME:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: UserAgentUtils.deviceName)
        case .COUNTRY:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: config.deviceCountryCode)
        case .MONTH:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: Date().month)
        case .WEEK_DAY:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: Date().weekDay)
        case .HOUR:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: Date().hour)
        case .PAGE_VIEW_IN_VISIT:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: String(config.pageViewCount))
        case .ANONYMOUS:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: (config.contactKey.type == "c").description)
        case .VISIT_DURATION:
            guard
                let lastSessionStartTime = DengageLocalStorage.shared.value(for: .lastSessionStartTime) as? Double else {return true}
            let lastSessionDuration = (Date().timeIntervalSince1970 - lastSessionStartTime)
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: String(lastSessionDuration))
        case .FIRST_VISIT:
            guard
                let firstVisitTime = DengageLocalStorage.shared.value(for: .firstLaunchTime) as? Double else {return true}
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: String(firstVisitTime))
        case .LAST_VISIT:
            guard
                let lastVisitTime = DengageLocalStorage.shared.value(for: .lastVisitTime) as? Double else {return true}
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: String(lastVisitTime))
        case .BRAND_NAME:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: "apple")
        case .MODEL_NAME:
            return operate(with: criterion.comparison,
                           for: criterion.dataType,
                           ruleParam: criterion.values,
                           userParam: "iphone")
            
        }
    }
    
    private class func operate(
        with operatorType: ComparisonType,
        for dataType: CriterionDataType,
        ruleParam: [String]? = nil,
        userParam: String? = nil
    ) -> Bool {
        guard
            let ruleParam = ruleParam,
            let userParam = userParam,
            ruleParam.isEmpty == false,
            userParam.isEmpty == false
        else {
            return false
        }

        switch operatorType {
        case .EQUALS:
            return ruleParam.first{$0.lowercased() == userParam.lowercased()} != nil
        case .NOT_EQUALS:
            return ruleParam.first{$0.lowercased() == userParam.lowercased()} != nil
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
}



