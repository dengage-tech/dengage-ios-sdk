//
//  Mustache.swift
//  Dengage
//
//  Created by Egemen Gülkılık on 10.02.2025.
//

import Foundation

enum MustacheError: Error {
    case tagNotClosed
    case unexpectedClosingTag(String)
    case unclosedSection(String)
}

enum Token {
    case text(String)
    case variable(tag: String)
    case unescaped(tag: String)
    case section(tag: String, tokens: [Token])
    case invertedSection(tag: String, tokens: [Token])
}

class Context {
    let view: Any?
    let parent: Context?
    
    init(view: Any?, parent: Context? = nil) {
        self.view = view
        self.parent = parent
    }
    
    func push(newView: Any?) -> Context {
        return Context(view: newView, parent: self)
    }
    
    func lookup(key: String) -> Any? {
        if key == "." { return view }
        let parts = key.split(separator: ".").map { String($0) }
        var value: Any? = view
        for part in parts {
            if let dict = value as? [String: Any] {
                value = dict[part]
            } else {
                value = nil
                break
            }
        }
        if value == nil, let parent = parent {
            return parent.lookup(key: key)
        }
        return value
    }
}

final class Mustache {

    static func render(_ template: String, _ data: [String: Any]) -> String {
        do {
            let tokens = try parse(template)
            let context = Context(view: data)
            return renderTokens(tokens: tokens, context: context)
        } catch {
            Logger.log(message: "Error rendering template: \(error)")
            return ""
        }
    }
    
    private static func parse(_ template: String) throws -> [Token] {
        var index = template.startIndex
        return try parseTokens(template: template, index: &index, stopTag: nil)
    }
    
    private static func parseTokens(template: String, index: inout String.Index, stopTag: String?) throws -> [Token] {
        var tokens: [Token] = []
        
        while index < template.endIndex {
            if let openRange = template.range(of: "{{", range: index..<template.endIndex) {
                if openRange.lowerBound > index {
                    let text = String(template[index..<openRange.lowerBound])
                    tokens.append(.text(text))
                }
                index = openRange.upperBound
                
                guard let closeRange = template.range(of: "}}", range: index..<template.endIndex) else {
                    throw MustacheError.tagNotClosed
                }
                
                let tagContent = String(template[index..<closeRange.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
                index = closeRange.upperBound
                
                if tagContent.hasPrefix("/") {
                    let tagName = tagContent.dropFirst().trimmingCharacters(in: .whitespacesAndNewlines)
                    if let stopTag = stopTag, tagName == stopTag {
                        return tokens
                    } else {
                        throw MustacheError.unexpectedClosingTag(String(tagName))
                    }
                } else if tagContent.hasPrefix("#") {
                    let tagName = tagContent.dropFirst().trimmingCharacters(in: .whitespacesAndNewlines)
                    let sectionTokens = try parseTokens(template: template, index: &index, stopTag: String(tagName))
                    tokens.append(.section(tag: String(tagName), tokens: sectionTokens))
                } else if tagContent.hasPrefix("^") {
                    let tagName = tagContent.dropFirst().trimmingCharacters(in: .whitespacesAndNewlines)
                    let sectionTokens = try parseTokens(template: template, index: &index, stopTag: String(tagName))
                    tokens.append(.invertedSection(tag: String(tagName), tokens: sectionTokens))
                } else if tagContent.hasPrefix("{") && tagContent.hasSuffix("}") {
                    let tagName = tagContent.dropFirst().dropLast().trimmingCharacters(in: .whitespacesAndNewlines)
                    tokens.append(.unescaped(tag: String(tagName)))
                } else if tagContent.hasPrefix("&") {
                    let tagName = tagContent.dropFirst().trimmingCharacters(in: .whitespacesAndNewlines)
                    tokens.append(.unescaped(tag: String(tagName)))
                } else {
                    tokens.append(.variable(tag: tagContent))
                }
            } else {
                let text = String(template[index..<template.endIndex])
                tokens.append(.text(text))
                index = template.endIndex
                break
            }
        }
        if let stop = stopTag {
            throw MustacheError.unclosedSection(stop)
        }
        return tokens
    }
    
    private static func renderTokens(tokens: [Token], context: Context) -> String {
        var result = ""
        for token in tokens {
            switch token {
            case .text(let text):
                result.append(text)
                
            case .variable(let tag):
                if let value = context.lookup(key: tag) {
                    result.append(escapeHtml(String(describing: value)))
                }
                
            case .unescaped(let tag):
                if let value = context.lookup(key: tag) {
                    result.append(String(describing: value))
                }
                
            case .section(let tag, let sectionTokens):
                if let value = context.lookup(key: tag) {
                    if let array = value as? [Any] {
                        for item in array {
                            let newContext = context.push(newView: item)
                            result.append(renderTokens(tokens: sectionTokens, context: newContext))
                        }
                    } else if isTruthy(value) {
                        let newContext = context.push(newView: value)
                        result.append(renderTokens(tokens: sectionTokens, context: newContext))
                    }
                }
                
            case .invertedSection(let tag, let sectionTokens):
                let value = context.lookup(key: tag)
                if !isTruthy(value) {
                    result.append(renderTokens(tokens: sectionTokens, context: context))
                }
            }
        }
        return result
    }
    
    private static func isTruthy(_ value: Any?) -> Bool {
        guard let value = value else { return false }
        if let boolVal = value as? Bool {
            return boolVal
        }
        if let array = value as? [Any] {
            return !array.isEmpty
        }
        if let str = value as? String {
            return !str.isEmpty
        }
        return true
    }
    
    private static func escapeHtml(_ input: String) -> String {
        var result = input
        result = result.replacingOccurrences(of: "&", with: "&amp;")
        result = result.replacingOccurrences(of: "<", with: "&lt;")
        result = result.replacingOccurrences(of: ">", with: "&gt;")
        result = result.replacingOccurrences(of: "\"", with: "&quot;")
        result = result.replacingOccurrences(of: "'", with: "&#39;")
        return result
    }
}
