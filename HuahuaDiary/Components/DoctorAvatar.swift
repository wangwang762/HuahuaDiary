//
//  DoctorAvatar.swift
//  HuahuaDiary
//
//  花大夫 emblem — pine-green disc with white leaf + lime pulse line.
//  Mirrors components.jsx DoctorAvatar.
//

import SwiftUI

struct DoctorAvatar: View {
    var size: CGFloat = 46

    var body: some View {
        ZStack {
            // Disc — radial gradient (pine)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "#3A8A64"), Color(hex: "#1D4A34")],
                        center: UnitPoint(x: 0.32, y: 0.24),
                        startRadius: 0,
                        endRadius: size * 0.95
                    )
                )
                .overlay(Circle().strokeBorder(Color.white.opacity(0.14), lineWidth: 1))
                .shadow(color: Color(hex: "#143C28", opacity: 0.32), radius: 7, x: 0, y: 5)

            LeafPulseGlyph()
                .frame(width: size * 0.62, height: size * 0.62)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Leaf with a lime pulse line
private struct LeafPulseGlyph: View {
    var body: some View {
        Canvas { ctx, size in
            let scale = size.width / 24
            func pt(_ x: Double, _ y: Double) -> CGPoint {
                CGPoint(x: x * scale, y: y * scale)
            }

            // Leaf body (white)
            var leaf = Path()
            leaf.move(to: pt(19, 5))
            leaf.addCurve(to: pt(8, 16.2),
                          control1: pt(19, 12),
                          control2: pt(14.5, 16.5))
            leaf.addCurve(to: pt(19, 5),
                          control1: pt(7.7, 9.8),
                          control2: pt(12, 5.4))
            leaf.closeSubpath()
            ctx.fill(leaf, with: .color(Color.white.opacity(0.94)))

            // Mid-rib (subtle green)
            var rib = Path()
            rib.move(to: pt(9, 15.4))
            rib.addCurve(to: pt(17, 9.6),
                         control1: pt(11.6, 12.4),
                         control2: pt(14.4, 10.6))
            ctx.stroke(rib,
                       with: .color(Color(hex: "#2F8064")),
                       style: StrokeStyle(lineWidth: 1.3 * scale, lineCap: .round))

            // Lime pulse line across the leaf
            var pulse = Path()
            pulse.move(to: pt(5.5, 12.4))
            pulse.addLine(to: pt(8.5, 12.4))
            pulse.addLine(to: pt(9.9, 9.4))
            pulse.addLine(to: pt(11.7, 14.4))
            pulse.addLine(to: pt(13.0, 12.0))
            pulse.addLine(to: pt(15.3, 12.0))
            ctx.stroke(pulse,
                       with: .color(HHColor.lime),
                       style: StrokeStyle(lineWidth: 1.7 * scale, lineCap: .round, lineJoin: .round))
        }
    }
}
