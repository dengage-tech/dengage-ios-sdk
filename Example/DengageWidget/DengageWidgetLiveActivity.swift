//
//  DengageWidgetLiveActivity.swift
//  DengageWidget
//
//  Created by Egemen Gülkılık on 24.02.2025.
//

import ActivityKit
import WidgetKit
import SwiftUI
import Dengage


struct DengageWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DengageWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension DengageWidgetAttributes {
    fileprivate static var preview: DengageWidgetAttributes {
        DengageWidgetAttributes(name: "World")
    }
}

extension DengageWidgetAttributes.ContentState {
    fileprivate static var smiley: DengageWidgetAttributes.ContentState {
        DengageWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: DengageWidgetAttributes.ContentState {
         DengageWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: DengageWidgetAttributes.preview) {
   DengageWidgetLiveActivity()
} contentStates: {
    DengageWidgetAttributes.ContentState.smiley
    DengageWidgetAttributes.ContentState.starEyes
}
