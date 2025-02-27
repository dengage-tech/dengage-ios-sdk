//
//  DengageWidgetAttributes.swift
//  Dengage
//
//  Created by Egemen Gülkılık on 25.02.2025.
//

import ActivityKit

@available(iOS 16.1, *)
public struct DengageWidgetAttributes: ActivityAttributes {
    
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        public var emoji: String
        public init(emoji: String) {
            self.emoji = emoji
        }
    }
    
    public init(name: String) {
        self.name = name
    }

    public let name: String
}
