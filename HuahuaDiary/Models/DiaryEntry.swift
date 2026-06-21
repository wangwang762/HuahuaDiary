//
//  DiaryEntry.swift
//  HuahuaDiary
//

import Foundation

// MARK: - Highlighted journal copy
/// A diary "quote" is built of segments — plain prose, coral-highlighted spans,
/// and green-highlighted spans (designer's hl / grn vocabulary).
enum JournalSegment: Hashable, Codable {
    case plain(String)
    case highlight(String) // coral
    case green(String)
}

enum DiaryKind: String, Hashable, Codable {
    case record
    case diagnosis
}

enum DiaryType: String, Hashable, Codable {
    case talk
    case photo
    case born
    case doctor
    case water
}

struct DiaryEntry: Identifiable, Hashable, Codable {
    let id: String
    var kind: DiaryKind
    var day: String        // "今天", "3 天前", "认识第 1 天"
    var date: String       // "6月7日"
    var weather: String    // "🌧 小雨 22°"
    var mood: String
    var type: DiaryType
    var photo: String?     // image-slot id
    var quote: [JournalSegment]   // empty for diagnosis entries
    var voice: String      // the plant's first-person line
    var stars: Int

    // Diagnosis-specific
    var symptom: String?
    var conclusion: String?
    var plan: String?

    // Soft concern hook — "找花大夫" prompt
    var concern: String?
}
