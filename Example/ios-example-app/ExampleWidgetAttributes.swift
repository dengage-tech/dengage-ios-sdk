import Foundation
import ActivityKit
import Dengage

@available(iOS 16.1, *)
struct ExampleAppFirstWidgetAttributes: DengageLiveActivityAttributes {
    var dengage: DengageLiveActivityAttributeData
    
    public struct ContentState: DengageLiveActivityContentState {
        public var message: String
        public var dengage: DengageLiveActivityContentStateData?
        
        public init(message: String) {
            self.message = message
            self.dengage = nil
        }
    }
    
    public var title: String
    
    public init(title: String, dengage: DengageLiveActivityAttributeData) {
        self.title = title
        self.dengage = dengage
    }
}

@available(iOS 16.1, *)
struct ExampleAppSecondWidgetAttributes: DengageLiveActivityAttributes {
    var dengage: DengageLiveActivityAttributeData
    
    public struct ContentState: DengageLiveActivityContentState {
        public var message: String
        public var progress: Double
        public var status: String
        public var bugs: Int
        public var dengage: DengageLiveActivityContentStateData?
        
        public init(message: String, progress: Double, status: String, bugs: Int) {
            self.message = message
            self.progress = progress
            self.status = status
            self.bugs = bugs
            self.dengage = nil
        }
    }
    
    public var title: String
    
    public init(title: String, dengage: DengageLiveActivityAttributeData) {
        self.title = title
        self.dengage = dengage
    }
}

@available(iOS 16.1, *)
struct ExampleAppThirdWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var message: String
        
        public init(message: String) {
            self.message = message
        }
    }
    
    public var title: String
    public var isPushToStart: Bool
    
    public init(title: String, isPushToStart: Bool) {
        self.title = title
        self.isPushToStart = isPushToStart
    }
}

