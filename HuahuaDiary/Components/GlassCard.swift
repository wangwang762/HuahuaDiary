//
//  GlassCard.swift
//  HuahuaDiary
//
//  The warm "paper card" used everywhere — solid cream fill, hairline border,
//  soft stacked shadow. Matches CSS .glass-card.
//

import SwiftUI

struct GlassCard<Content: View>: View {
    var radius: CGFloat = HHRadius.xl
    var padding: EdgeInsets = EdgeInsets(top: 14, leading: 14, bottom: 14, trailing: 14)
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(HHColor.paperCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .strokeBorder(HHColor.hairline, lineWidth: 1)
                    )
            )
            .paperCardShadow()
    }
}

// MARK: - Hairline (1px rule)
struct Hairline: View {
    var color: Color = HHColor.hairline
    var body: some View { Rectangle().fill(color).frame(height: 1) }
}

// MARK: - Solid rule (heavier)
struct EditorialRule: View {
    var body: some View { Rectangle().fill(HHColor.rule).frame(height: 1) }
}
