//
//  Typography.swift
//  HuahuaDiary
//

import SwiftUI

enum HHFont {
    static let serifFamily  = "Songti SC"          // 衬线正文
    static let uiFamily     = "PingFang SC"        // UI 无衬线
    static let handFamily   = "STKaiti"            // 手写/毛笔风（iOS 内置楷体，最接近 LXGW WenKai）
    static let scriptFamily = "STKaiti"            // 装饰性草书
    static let numFamily    = "DdmcSans-Medium"    // 数字专用

    static func journal(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom(serifFamily, size: size).weight(weight)
    }

    static func journalItalic(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom(serifFamily, size: size).weight(weight)
    }

    static func display(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .custom(serifFamily, size: size).weight(weight)
    }

    static func hand(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .custom(handFamily, size: size).weight(weight)
    }

    static func script(_ size: CGFloat) -> Font {
        .custom(scriptFamily, size: size).weight(.regular).italic()
    }

    static func ui(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom(uiFamily, size: size).weight(weight)
    }

    static func num(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .custom(numFamily, size: size).weight(weight)
    }

    static let kicker: Font = .custom(uiFamily, size: 10.5).weight(.semibold)
}

struct KickerStyle: ViewModifier {
    var color: Color = HHColor.inkSoft
    func body(content: Content) -> some View {
        content
            .font(HHFont.kicker)
            .tracking(2.4)
            .textCase(.uppercase)
            .foregroundStyle(color)
    }
}

extension View {
    func kicker(color: Color = HHColor.inkSoft) -> some View {
        modifier(KickerStyle(color: color))
    }
}

enum AppTitleStyle: String, CaseIterable, Identifiable {
    case clean = "清秀"
    case hand  = "手写"
    case mixed = "混排"
    var id: String { rawValue }
}
