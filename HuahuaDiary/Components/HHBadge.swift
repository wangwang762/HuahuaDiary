//
//  HHBadge.swift
//  HuahuaDiary
//

import SwiftUI

struct HHBadge: View {
    let text: String
    var icon: String? = nil          // SF Symbol name
    var foreground: Color = HHColor.ink
    var background: Color = HHColor.greenBubble
    var fontSize: CGFloat = 11
    var horizontalPadding: CGFloat = 9
    var verticalPadding: CGFloat = 3

    var body: some View {
        HStack(spacing: 4) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: fontSize, weight: .semibold))
            }
            Text(text)
                .font(HHFont.ui(fontSize, weight: .semibold))
        }
        .foregroundStyle(foreground)
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .background(Capsule(style: .continuous).fill(background))
        .fixedSize()
    }
}

// MARK: - "需照料" warn chip (top-right of cover card)
struct WarnChip: View {
    var body: some View {
        HStack(spacing: 4) {
            HHIcon(name: .bell, size: 11, color: .white, strokeWidth: 2.0)
            Text("需照料")
                .font(HHFont.ui(10, weight: .bold))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().fill(HHColor.terra))
        .shadow(color: .black.opacity(0.18), radius: 3, x: 0, y: 2)
    }
}
