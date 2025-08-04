//
//  ApiUrlConfiguration.swift
//  Dengage
//
//  Created by Egemen Gülkılık on 18.02.2025.
//

import Foundation

@objc public class ApiUrlConfiguration: NSObject, Codable {
    public var denEventApiUrl: String
    public var denPushApiUrl: String
    public var denInAppApiUrl: String
    public var denGeofenceApiUrl: String?
    public var fetchRealTimeInAppApiUrl: String

    public init(
        denEventApiUrl: String,
        denPushApiUrl: String,
        denInAppApiUrl: String,
        denGeofenceApiUrl: String? = nil,
        fetchRealTimeInAppApiUrl: String
    ) {
        self.denEventApiUrl = denEventApiUrl
        self.denPushApiUrl = denPushApiUrl
        self.denInAppApiUrl = denInAppApiUrl
        self.denGeofenceApiUrl = denGeofenceApiUrl ?? ""
        self.fetchRealTimeInAppApiUrl = fetchRealTimeInAppApiUrl
    }
}



