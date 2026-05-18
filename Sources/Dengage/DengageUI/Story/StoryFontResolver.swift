import UIKit

/// Resolves a font family name to a `UIFont`, preferring fonts already registered with the
/// host app (via `Info.plist`'s `UIAppFonts`, dynamic `CTFontManager` registration, or
/// Apple's preinstalled fonts) and falling back to the system font.
///
/// A CSS-style stack like `"Arial, Helvetica, sans-serif"` is supported — each candidate
/// is tried in order. For every candidate the resolver tries, in order:
///   1. The raw name as a PostScript font name (`UIFont(name:size:)`).
///   2. The raw name as a family name, picking the face whose traits best match the
///      requested weight / italic combination.
///   3. A sanitized variant of the name (lowercased, non-alphanumerics stripped) compared
///      against registered family / PostScript names — handles `"Neue Haas Grotesk Text Pro"`
///      vs `"NeueHaasGroteskTextPro-Regular"` style differences.
///
/// Generic CSS families (`sans-serif`, `serif`, `monospace`, `system-ui`, etc.) are mapped
/// to the appropriate system font.
internal enum StoryFontResolver {

    private static var cache: [CacheKey: UIFont] = [:]
    private static var missing: Set<String> = []
    private static let queue = DispatchQueue(label: "com.dengage.story.fontresolver", attributes: .concurrent)

    private struct CacheKey: Hashable {
        let name: String
        let size: CGFloat
        let weight: CGFloat
        let italic: Bool
    }

    static func resolve(familyName: String?,
                        size: CGFloat,
                        weight: UIFont.Weight = .regular,
                        italic: Bool = false) -> UIFont {
        let fallback = systemFont(size: size, weight: weight, italic: italic)

        guard let raw = familyName?.trimmingCharacters(in: .whitespacesAndNewlines),
              !raw.isEmpty else {
            return fallback
        }

        let candidates = raw
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines.union(CharacterSet(charactersIn: "\"'"))) }
            .filter { !$0.isEmpty }

        for candidate in candidates {
            if let generic = genericSystemFont(for: candidate, size: size, weight: weight, italic: italic) {
                return generic
            }
            if let font = lookup(candidate, size: size, weight: weight, italic: italic) {
                return font
            }
        }
        return fallback
    }

    // MARK: - Lookup

    private static func lookup(_ name: String,
                               size: CGFloat,
                               weight: UIFont.Weight,
                               italic: Bool) -> UIFont? {
        let key = CacheKey(name: name.lowercased(), size: size, weight: weight.rawValue, italic: italic)
        if let cached = queue.sync(execute: { cache[key] }) {
            return cached
        }
        if queue.sync(execute: { missing.contains(key.name) }) {
            return nil
        }

        let resolved = resolveUncached(name, size: size, weight: weight, italic: italic)

        queue.async(flags: .barrier) {
            if let resolved = resolved {
                cache[key] = resolved
            } else {
                missing.insert(key.name)
            }
        }
        return resolved
    }

    private static func resolveUncached(_ name: String,
                                        size: CGFloat,
                                        weight: UIFont.Weight,
                                        italic: Bool) -> UIFont? {
        // 1. Direct PostScript name match.
        if let font = UIFont(name: name, size: size) {
            return applyTraits(to: font, weight: weight, italic: italic)
        }

        // 2. Treat as family name, choose the face that best matches traits.
        let familyFaces = UIFont.fontNames(forFamilyName: name)
        if !familyFaces.isEmpty {
            return bestFace(in: familyFaces, size: size, weight: weight, italic: italic)
        }

        // 3. Sanitized comparison against the registered font catalog.
        let needle = sanitize(name)
        guard !needle.isEmpty else { return nil }

        for family in UIFont.familyNames where sanitize(family) == needle {
            return bestFace(in: UIFont.fontNames(forFamilyName: family),
                            size: size, weight: weight, italic: italic)
        }
        for family in UIFont.familyNames {
            for face in UIFont.fontNames(forFamilyName: family) where sanitize(face) == needle {
                if let font = UIFont(name: face, size: size) {
                    return applyTraits(to: font, weight: weight, italic: italic)
                }
            }
        }
        return nil
    }

    private static func bestFace(in faces: [String],
                                 size: CGFloat,
                                 weight: UIFont.Weight,
                                 italic: Bool) -> UIFont? {
        let scored = faces.compactMap { face -> (UIFont, Int)? in
            guard let font = UIFont(name: face, size: size) else { return nil }
            return (font, traitScore(face: face, weight: weight, italic: italic))
        }
        return scored.min(by: { $0.1 < $1.1 })?.0
    }

    private static func traitScore(face: String, weight: UIFont.Weight, italic: Bool) -> Int {
        let lower = face.lowercased()
        let wantItalic = italic || lower.contains("italic") || lower.contains("oblique")
        let faceItalic = lower.contains("italic") || lower.contains("oblique")
        let italicPenalty = (wantItalic == faceItalic) ? 0 : 10

        let faceWeight: Int = {
            switch true {
            case lower.contains("ultralight"), lower.contains("ultra-light"): return 100
            case lower.contains("thin"): return 200
            case lower.contains("extralight"), lower.contains("extra-light"): return 200
            case lower.contains("light"): return 300
            case lower.contains("medium"): return 500
            case lower.contains("semibold"), lower.contains("demibold"): return 600
            case lower.contains("extrabold"), lower.contains("ultrabold"): return 800
            case lower.contains("heavy"), lower.contains("black"): return 900
            case lower.contains("bold"): return 700
            default: return 400 // regular
            }
        }()

        let wantWeight = uiWeightToCss(weight)
        return abs(faceWeight - wantWeight) + italicPenalty
    }

    private static func uiWeightToCss(_ weight: UIFont.Weight) -> Int {
        switch weight {
        case .ultraLight: return 100
        case .thin:       return 200
        case .light:      return 300
        case .regular:    return 400
        case .medium:     return 500
        case .semibold:   return 600
        case .bold:       return 700
        case .heavy:      return 800
        case .black:      return 900
        default:          return 400
        }
    }

    // MARK: - System / generic fonts

    private static func genericSystemFont(for candidate: String,
                                          size: CGFloat,
                                          weight: UIFont.Weight,
                                          italic: Bool) -> UIFont? {
        switch candidate.lowercased() {
        case "system", "system-ui", "-apple-system", "sans-serif", "sans serif", "sansserif":
            return systemFont(size: size, weight: weight, italic: italic)
        case "monospace", "ui-monospace":
            if #available(iOS 13.0, *) {
                let mono = UIFont.monospacedSystemFont(ofSize: size, weight: weight)
                return italic ? applyTraits(to: mono, weight: weight, italic: true) : mono
            }
            return UIFont(name: "Menlo", size: size).map { applyTraits(to: $0, weight: weight, italic: italic) }
        case "serif", "ui-serif":
            return UIFont(name: "Times New Roman", size: size).map { applyTraits(to: $0, weight: weight, italic: italic) }
                ?? systemFont(size: size, weight: weight, italic: italic)
        default:
            return nil
        }
    }

    private static func systemFont(size: CGFloat, weight: UIFont.Weight, italic: Bool) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        guard italic else { return base }
        if let descriptor = base.fontDescriptor.withSymbolicTraits(.traitItalic) {
            return UIFont(descriptor: descriptor, size: size)
        }
        return base
    }

    private static func applyTraits(to font: UIFont, weight: UIFont.Weight, italic: Bool) -> UIFont {
        var traits: UIFontDescriptor.SymbolicTraits = font.fontDescriptor.symbolicTraits
        if weight >= .semibold { traits.insert(.traitBold) }
        if italic { traits.insert(.traitItalic) }
        guard !traits.isEmpty,
              let descriptor = font.fontDescriptor.withSymbolicTraits(traits) else {
            return font
        }
        return UIFont(descriptor: descriptor, size: font.pointSize)
    }

    // MARK: - Helpers

    private static func sanitize(_ name: String) -> String {
        name.lowercased().unicodeScalars
            .filter { CharacterSet.alphanumerics.contains($0) }
            .reduce(into: "") { $0.append(Character($1)) }
    }
}
