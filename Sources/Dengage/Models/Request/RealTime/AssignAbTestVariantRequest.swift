import Foundation

/// Resolves which A/B variant the SDK should render for a single impression of an active
/// A/B test campaign. Spec URL:
/// `GET https://<push>/api/realtime-inapp/{accountId}/{appId}/ab/assign?cid={publicId}`
struct AssignAbTestVariantRequest: APIRequest {

    typealias Response = AbTestAssignmentResponse

    let method: HTTPMethod = .get
    let endpointType: EndpointType = .inapp
    var path: String {
        return "/api/realtime-inapp/\(accountName)/\(appId)/ab/assign"
    }

    var queryParameters: [URLQueryItem] {
        return [URLQueryItem(name: "cid", value: campaignId)]
    }

    let accountName: String
    let appId: String
    /// The campaign's publicId.
    let campaignId: String
}
