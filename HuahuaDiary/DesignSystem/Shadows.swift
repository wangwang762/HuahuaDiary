//
//  Shadows.swift
//  HuahuaDiary
//

import SwiftUI

enum HHRadius {
    static let sm: CGFloat = 5
    static let md: CGFloat = 8
    static let lg: CGFloat = 11
    static let xl: CGFloat = 14
    static let xxl: CGFloat = 18
    static let pill: CGFloat = 999
}

struct HHShadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat

    static let sh1 = HHShadow(color: Color(.sRGB, red: 60/255, green: 45/255, blue: 25/255, opacity: 0.06),
                              radius: 4, x: 0, y: 1)
    static let sh2 = HHShadow(color: Color(.sRGB, red: 60/255, green: 45/255, blue: 25/255, opacity: 0.09),
                              radius: 18, x: 0, y: 6)
    static let sh3 = HHShadow(color: Color(.sRGB, red: 50/255, green: 38/255, blue: 22/255, opacity: 0.14),
                              radius: 40, x: 0, y: 16)
    static let card = HHShadow(color: Color(.sRGB, red: 60/255, green: 45/255, blue: 25/255, opacity: 0.10),
                               radius: 26, x: 0, y: 8)
    static let cardInner = HHShadow(color: Color(.sRGB, red: 60/255, green: 45/255, blue: 25/255, opacity: 0.05),
                                    radius: 3, x: 0, y: 1)
}

extension View {
    func hhShadow(_ s: HHShadow) -> some View {
        shadow(color: s.color, radius: s.radius, x: s.x, y: s.y)
    }
    func paperCardShadow() -> some View {
        self
            .shadow(color: HHShadow.card.color, radius: HHShadow.card.radius, x: 0, y: HHShadow.card.y)
            .shadow(color: HHShadow.cardInner.color, radius: HHShadow.cardInner.radius, x: 0, y: HHShadow.cardInner.y)
    }
}
