import Foundation

/// ISO 8601 (offset'li) <-> Date dönüşümü (contract §0: `2026-05-18T10:00:00+03:00`).
public enum GeofenceIso {

    private static let withFraction: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private static let plain: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    public static func string(from date: Date) -> String {
        return plain.string(from: date)
    }

    public static func date(from value: String?) -> Date? {
        guard let value = value, !value.isEmpty else { return nil }
        return plain.date(from: value) ?? withFraction.date(from: value)
    }
}
