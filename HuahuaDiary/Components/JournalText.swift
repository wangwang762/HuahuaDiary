//
//  JournalText.swift
//  HuahuaDiary
//
//  Renders an array of JournalSegment with coral / green highlights inline.
//  Mirrors the React <Journal> component.
//

import SwiftUI

struct JournalText: View {
    let segments: [JournalSegment]
    var size: CGFloat = 14
    var lineSpacing: CGFloat = 4
    var color: Color = HHColor.ink

    var body: some View {
        Text(attributed)
            .font(HHFont.journal(size))
            .foregroundStyle(color)
            .lineSpacing(lineSpacing)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var attributed: AttributedString {
        var result = AttributedString("")
        for seg in segments {
            switch seg {
            case .plain(let s):
                result += AttributedString(s)
            case .highlight(let s):
                var part = AttributedString(s)
                part.foregroundColor = HHColor.coral
                result += part
            case .green(let s):
                var part = AttributedString(s)
                part.foregroundColor = HHColor.greenDeep
                part.font = HHFont.journal(size, weight: .semibold)
                result += part
            }
        }
        return result
    }
}
