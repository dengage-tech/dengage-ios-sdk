import Foundation

struct AbTest: Codable {
    let variants: [AbTestVariant]?

    /// True when the campaign has collapsed to a single variant at 100% — the winner phase
    /// (or a single-bucket configuration). In that case the SDK can render directly without
    /// calling `/ab/assign`.
    var isDeterministic: Bool {
        guard let list = variants, list.count == 1 else { return false }
        return (list[0].percentage ?? 0) >= 100
    }
}

struct AbTestVariant: Codable {
    let contentId: String?
    let percentage: Double?
    let isControlGroup: Bool?
    let type: String?
    let props: ContentParams?

    enum CodingKeys: String, CodingKey {
        case contentId
        case percentage
        case isControlGroup
        case type
        case props
    }
}

/// Response from `/api/realtime-inapp/{acc}/{app}/ab/assign?cid={publicId}`.
struct AbTestAssignmentResponse: Codable {
    let contentId: String?
    let isControlGroup: Bool?

    static let controlGroupId = "00000000-0000-0000-0000-000000000000"

    /// True when the user has been bucketed into the control group — render nothing.
    var isControlBucket: Bool {
        if isControlGroup == true { return true }
        return contentId?.lowercased() == AbTestAssignmentResponse.controlGroupId
    }
}
