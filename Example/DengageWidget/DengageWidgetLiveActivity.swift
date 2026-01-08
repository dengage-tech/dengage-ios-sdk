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


@available(iOS 16.1, *)
struct DengageWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ExampleAppFirstWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.message)")
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
                    Text("Bottom \(context.state.message)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.message)")
            } minimal: {
                Text(context.state.message)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

@available(iOS 16.1, *)
struct DengageWidgetSecondLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ExampleAppSecondWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack(alignment: .leading, spacing: 8) {
                Text(context.attributes.title)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(context.state.message)
                    .font(.body)
                
                ProgressView(value: context.state.progress)
                    .progressViewStyle(LinearProgressViewStyle())
                
                
                HStack {
                    Text("Status: \(context.state.status)")
                        .font(.caption)
                    Spacer()
                    Text("Bugs: \(context.state.bugs)")
                        .font(.caption)
                }
            }
            .padding()
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.white)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.attributes.title)
                        .font(.headline)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(Int(context.state.progress * 100))%")
                        .font(.headline)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.state.message)
                        ProgressView(value: context.state.progress)
                        HStack {
                            Text(context.state.status)
                            Spacer()
                            Text("Bugs: \(context.state.bugs)")
                        }
                        .font(.caption)
                    }
                }
            } compactLeading: {
                Text(context.attributes.title)
                    .font(.caption2)
            } compactTrailing: {
                Text("\(Int(context.state.progress * 100))%")
                    .font(.caption2)
            } minimal: {
                Text("\(Int(context.state.progress * 100))%")
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.blue)
        }
    }
}

