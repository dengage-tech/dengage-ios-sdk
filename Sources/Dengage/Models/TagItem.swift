import Foundation
@objc public class TagItem: NSObject{
    let tagName: String
    let tagValue: String
    let changeTime: String?
    let removeTime: String?
    let changeValue: String?
    
    var parameters:[String:String]{
        var params = [String:String]()
        params["tag"] = tagName
        params["value"] = tagValue
        params["changeTime"] = changeTime
        params["changeValue"] = changeValue
        params["removeTime"] = removeTime
        return params
    }
    
    @objc public init(tagName: String,
                      tagValue: String,
                      changeTime: Date? = nil,
                      removeTime: Date? = nil,
                      changeValue: String? = nil) {
        self.tagName = tagName
        self.tagValue = tagValue
        self.changeTime = Utilities.convertToString(to: changeTime)
        self.removeTime = Utilities.convertToString(to: removeTime)
        self.changeValue = changeValue
    }
    
    internal init(with params:[String:String]) {
        tagName = params["tag"] ?? ""
        tagValue = params["value"] ?? ""
        changeValue = params["changeValue"]
        removeTime = params["removeTime"]
        changeTime = params["changeTime"]
    }
}
