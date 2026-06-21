//
//  PlantSprite.swift
//  HuahuaDiary
//
//  Hand-translated line-art per species, mirroring components.jsx PlantSprite.
//  ViewBox: 0,0,40,72 with body strokes + filled pot.
//

import SwiftUI

struct PlantSprite: View {
    let shape: PlantShape
    var color: Color = HHColor.greenDeep
    var pot: Color = Color(hex: "#C98A3C")
    var height: CGFloat = 70
    var sway: Bool = false
    var swayAmplitude: Double = 3   // degrees
    var swayDelay: Double = 0

    @State private var rocking: Bool = false

    private var width: CGFloat { height * 0.78 }

    var body: some View {
        ZStack {
            // Body — sway around the soil line (bottom-center).
            ScaledBody(shape: shape, color: color)
                .rotationEffect(
                    .degrees(rocking ? swayAmplitude : -swayAmplitude),
                    anchor: .bottom
                )
                .animation(
                    sway
                        ? .easeInOut(duration: 3.6).repeatForever(autoreverses: true)
                        : .default,
                    value: rocking
                )

            // Pot — sits on the soil line, no sway.
            PotShape()
                .fill(pot)
                .frame(width: width, height: height)
        }
        .frame(width: width, height: height)
        .onAppear {
            guard sway else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + swayDelay) {
                rocking = true
            }
        }
    }
}

/// Scales the 40×72 viewBox into the target frame.
private struct ScaledBody: View {
    let shape: PlantShape
    let color: Color

    var body: some View {
        GeometryReader { proxy in
            let sx = proxy.size.width / 40
            let sy = proxy.size.height / 72
            shape.bodyPath
                .applying(CGAffineTransform(scaleX: sx, y: sy))
                .stroke(color, style: StrokeStyle(lineWidth: 2.4, lineCap: .round, lineJoin: .round))
        }
    }
}

// MARK: - Pot (brown filled shape — base + rim band)
private struct PotShape: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 40
        let sy = rect.height / 72
        var p = Path()
        // pot front face
        p.move(to: CGPoint(x: 11 * sx, y: 64 * sy))
        p.addLine(to: CGPoint(x: 29 * sx, y: 64 * sy))
        p.addLine(to: CGPoint(x: 26.6 * sx, y: 72 * sy))
        p.addLine(to: CGPoint(x: 13.4 * sx, y: 72 * sy))
        p.closeSubpath()
        // pot rim
        p.move(to: CGPoint(x: 10 * sx, y: 62 * sy))
        p.addLine(to: CGPoint(x: 30 * sx, y: 62 * sy))
        p.addLine(to: CGPoint(x: 30 * sx, y: 65 * sy))
        p.addLine(to: CGPoint(x: 10 * sx, y: 65 * sy))
        p.closeSubpath()
        return p
    }
}

// MARK: - Plant body path per species
extension PlantShape {
    /// Body path in the 40×72 SVG viewBox space — no scaling baked in.
    var bodyPath: Path {
        var p = Path()
        switch self {

        case .cactus:
            // Main trunk
            p.move(to: CGPoint(x: 20, y: 64))
            p.addLine(to: CGPoint(x: 20, y: 30))

            // Left arm — two cubic segments
            p.move(to: CGPoint(x: 20, y: 46))
            p.addCurve(to: CGPoint(x: 8, y: 34),
                       control1: CGPoint(x: 20, y: 38),
                       control2: CGPoint(x: 14, y: 34))
            p.addCurve(to: CGPoint(x: 16, y: 48),
                       control1: CGPoint(x: 8, y: 42),
                       control2: CGPoint(x: 8.4, y: 48))

            // Right arm — two cubic segments
            p.move(to: CGPoint(x: 20, y: 40))
            p.addCurve(to: CGPoint(x: 32, y: 51),
                       control1: CGPoint(x: 20, y: 47),
                       control2: CGPoint(x: 26, y: 51))
            p.addCurve(to: CGPoint(x: 24, y: 36),
                       control1: CGPoint(x: 32, y: 42),
                       control2: CGPoint(x: 31.6, y: 36))

        case .succulent:
            // Center stalk
            p.move(to: CGPoint(x: 20, y: 64))
            p.addLine(to: CGPoint(x: 20, y: 46))
            // Left leaf
            p.move(to: CGPoint(x: 20, y: 46))
            p.addCurve(to: CGPoint(x: 7, y: 48),
                       control1: CGPoint(x: 17, y: 39),
                       control2: CGPoint(x: 11, y: 37))
            p.addCurve(to: CGPoint(x: 20, y: 48),
                       control1: CGPoint(x: 8, y: 54),
                       control2: CGPoint(x: 12, y: 57))
            // Right leaf (mirror)
            p.move(to: CGPoint(x: 20, y: 46))
            p.addCurve(to: CGPoint(x: 33, y: 48),
                       control1: CGPoint(x: 23, y: 39),
                       control2: CGPoint(x: 29, y: 37))
            p.addCurve(to: CGPoint(x: 20, y: 48),
                       control1: CGPoint(x: 32, y: 54),
                       control2: CGPoint(x: 28, y: 57))
            // Center upright leaf
            p.move(to: CGPoint(x: 20, y: 48))
            p.addCurve(to: CGPoint(x: 19, y: 30),
                       control1: CGPoint(x: 19, y: 40),
                       control2: CGPoint(x: 16, y: 35))
            p.addCurve(to: CGPoint(x: 20, y: 48),
                       control1: CGPoint(x: 23, y: 34),
                       control2: CGPoint(x: 24, y: 42))

        case .pothos:
            // Stem rising and arching up
            p.move(to: CGPoint(x: 20, y: 64))
            p.addLine(to: CGPoint(x: 20, y: 40))
            p.addCurve(to: CGPoint(x: 31, y: 29),
                       control1: CGPoint(x: 20, y: 33),
                       control2: CGPoint(x: 25, y: 29))
            // Lower-left heart leaf
            p.move(to: CGPoint(x: 20, y: 52))
            p.addCurve(to: CGPoint(x: 8, y: 44),
                       control1: CGPoint(x: 14, y: 53),
                       control2: CGPoint(x: 9, y: 50))
            p.addCurve(to: CGPoint(x: 20, y: 52),
                       control1: CGPoint(x: 14, y: 43),
                       control2: CGPoint(x: 19, y: 46))
            // Upper-right vine leaf
            p.move(to: CGPoint(x: 22, y: 44))
            p.addCurve(to: CGPoint(x: 32, y: 32),
                       control1: CGPoint(x: 27, y: 42),
                       control2: CGPoint(x: 32, y: 38))
            p.addCurve(to: CGPoint(x: 22, y: 44),
                       control1: CGPoint(x: 27, y: 33),
                       control2: CGPoint(x: 23, y: 37))
            // Mid-left leaf
            p.move(to: CGPoint(x: 18, y: 40))
            p.addCurve(to: CGPoint(x: 9, y: 29),
                       control1: CGPoint(x: 13, y: 39),
                       control2: CGPoint(x: 9, y: 35))
            p.addCurve(to: CGPoint(x: 18, y: 40),
                       control1: CGPoint(x: 14, y: 30),
                       control2: CGPoint(x: 17, y: 34))

        case .monstera:
            // Stalk
            p.move(to: CGPoint(x: 20, y: 64))
            p.addLine(to: CGPoint(x: 20, y: 42))
            // Big left leaf with characteristic splits
            p.move(to: CGPoint(x: 20, y: 42))
            p.addCurve(to: CGPoint(x: 6, y: 27),
                       control1: CGPoint(x: 11, y: 42),
                       control2: CGPoint(x: 6, y: 36))
            p.addCurve(to: CGPoint(x: 20, y: 42),
                       control1: CGPoint(x: 15, y: 27),
                       control2: CGPoint(x: 20, y: 32))
            p.closeSubpath()
            // Splits / fenestrations on left leaf
            p.move(to: CGPoint(x: 11, y: 31)); p.addLine(to: CGPoint(x: 14, y: 31))
            p.move(to: CGPoint(x: 11, y: 36)); p.addLine(to: CGPoint(x: 16, y: 36))
            p.move(to: CGPoint(x: 14, y: 41)); p.addLine(to: CGPoint(x: 17, y: 41))
            // Right leaf
            p.move(to: CGPoint(x: 20, y: 40))
            p.addCurve(to: CGPoint(x: 33, y: 27),
                       control1: CGPoint(x: 28, y: 40),
                       control2: CGPoint(x: 33, y: 35))
            p.addCurve(to: CGPoint(x: 20, y: 40),
                       control1: CGPoint(x: 25, y: 27),
                       control2: CGPoint(x: 20, y: 31))
            p.closeSubpath()

        case .sunflower:
            // Long stalk
            p.move(to: CGPoint(x: 20, y: 64))
            p.addLine(to: CGPoint(x: 20, y: 34))
            // Flower head
            p.addEllipse(in: CGRect(x: 14, y: 16, width: 12, height: 12))
            // Rays
            let rays: [(CGPoint, CGPoint)] = [
                (.init(x: 20, y: 8),  .init(x: 20, y: 14)),
                (.init(x: 20, y: 30), .init(x: 20, y: 36)),
                (.init(x: 6,  y: 22), .init(x: 12, y: 22)),
                (.init(x: 28, y: 22), .init(x: 34, y: 22)),
                (.init(x: 11, y: 13), .init(x: 15, y: 17)),
                (.init(x: 29, y: 13), .init(x: 25, y: 17)),
                (.init(x: 11, y: 31), .init(x: 15, y: 27)),
                (.init(x: 29, y: 31), .init(x: 25, y: 27))
            ]
            for (a, b) in rays { p.move(to: a); p.addLine(to: b) }
            // Single leaf on stem
            p.move(to: CGPoint(x: 16, y: 50))
            p.addCurve(to: CGPoint(x: 8, y: 43),
                       control1: CGPoint(x: 11, y: 50),
                       control2: CGPoint(x: 8, y: 47))
            p.addCurve(to: CGPoint(x: 16, y: 50),
                       control1: CGPoint(x: 12, y: 43),
                       control2: CGPoint(x: 16, y: 45))
            p.closeSubpath()
        }
        return p
    }
}

#Preview {
    HStack(spacing: 18) {
        ForEach(PlantShape.allCases, id: \.self) { shape in
            PlantSprite(shape: shape, color: HHColor.greenDeep, height: 80, sway: true)
        }
    }
    .padding()
    .background(HHColor.paper)
}
