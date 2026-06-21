//
//  HHIcon.swift
//  HuahuaDiary
//
//  Custom line icon set — matches the SVG icon paths from components.jsx.
//  All icons are drawn on a 24×24 viewBox with rounded linecaps/joins.
//

import SwiftUI

// MARK: - Icon names

enum HHIconName {
    case book
    case bell
    case pin
    case sun
    case cloud
    case cloudRain
    case doctor
    case grid
    case chevronRight
    case plus
    case leaf
}

// MARK: - Icon view

struct HHIcon: View {
    let name: HHIconName
    var size: CGFloat = 24
    var color: Color = .primary
    var strokeWidth: CGFloat = 1.8

    var body: some View {
        Canvas { ctx, _ in
            let scale = size / 24.0
            ctx.scaleBy(x: scale, y: scale)

            var path = iconPath(name)

            let style = StrokeStyle(
                lineWidth: strokeWidth / scale,
                lineCap: .round,
                lineJoin: .round
            )
            ctx.stroke(path, with: .color(color), style: style)
        }
        .frame(width: size, height: size)
    }

    // MARK: - Paths (24×24 viewBox)

    private func iconPath(_ name: HHIconName) -> Path {
        switch name {

        case .book:
            // "M5 4.5h11a2 2 0 0 1 2 2V20H7a2 2 0 0 1-2-2z" + "M9 4.5V19"
            return Path { p in
                p.move(to: .init(x: 5, y: 4.5))
                p.addLine(to: .init(x: 16, y: 4.5))
                p.addArc(center: .init(x: 16, y: 6.5), radius: 2,
                         startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
                p.addLine(to: .init(x: 18, y: 20))
                p.addLine(to: .init(x: 7, y: 20))
                p.addArc(center: .init(x: 5, y: 20), radius: 2,
                         startAngle: .degrees(0), endAngle: .degrees(-180), clockwise: true)
                p.closeSubpath()
                // spine line
                p.move(to: .init(x: 9, y: 4.5))
                p.addLine(to: .init(x: 9, y: 19))
            }

        case .bell:
            // "M6 9a6 6 0 0 1 12 0c0 5 2 6 2 6H4s2-1 2-6Z" + "M10 19a2 2 0 0 0 4 0"
            return Path { p in
                p.move(to: .init(x: 6, y: 9))
                p.addArc(center: .init(x: 12, y: 9), radius: 6,
                         startAngle: .degrees(180), endAngle: .degrees(0), clockwise: true)
                p.addCurve(to: .init(x: 20, y: 15),
                           control1: .init(x: 18, y: 9),
                           control2: .init(x: 20, y: 12))
                p.addLine(to: .init(x: 4, y: 15))
                p.addCurve(to: .init(x: 6, y: 9),
                           control1: .init(x: 4, y: 12),
                           control2: .init(x: 6, y: 12))
                p.closeSubpath()
                // clapper
                p.move(to: .init(x: 10, y: 19))
                p.addArc(center: .init(x: 12, y: 19), radius: 2,
                         startAngle: .degrees(180), endAngle: .degrees(0), clockwise: true)
            }

        case .pin:
            // "M12 21s7-5.6 7-11a7 7 0 1 0-14 0c0 5.4 7 11 7 11Z" + circle cx=12 cy=10 r=2.5
            return Path { p in
                p.move(to: .init(x: 12, y: 21))
                p.addCurve(to: .init(x: 19, y: 10),
                           control1: .init(x: 17, y: 18),
                           control2: .init(x: 19, y: 14))
                p.addArc(center: .init(x: 12, y: 10), radius: 7,
                         startAngle: .degrees(0), endAngle: .degrees(180), clockwise: false)
                p.addCurve(to: .init(x: 12, y: 21),
                           control1: .init(x: 5, y: 14),
                           control2: .init(x: 7, y: 18))
                p.closeSubpath()
                // center circle
                p.addEllipse(in: .init(x: 9.5, y: 7.5, width: 5, height: 5))
            }

        case .sun:
            // circle cx=12 cy=12 r=4 + rays
            return Path { p in
                p.addEllipse(in: .init(x: 8, y: 8, width: 8, height: 8))
                // N
                p.move(to: .init(x: 12, y: 2.5)); p.addLine(to: .init(x: 12, y: 4.5))
                // S
                p.move(to: .init(x: 12, y: 19.5)); p.addLine(to: .init(x: 12, y: 21.5))
                // W
                p.move(to: .init(x: 2.5, y: 12)); p.addLine(to: .init(x: 4.5, y: 12))
                // E
                p.move(to: .init(x: 19.5, y: 12)); p.addLine(to: .init(x: 21.5, y: 12))
                // NW
                p.move(to: .init(x: 5, y: 5)); p.addLine(to: .init(x: 6.5, y: 6.5))
                // SE
                p.move(to: .init(x: 17.5, y: 17.5)); p.addLine(to: .init(x: 19, y: 19))
                // NE
                p.move(to: .init(x: 19, y: 5)); p.addLine(to: .init(x: 17.5, y: 6.5))
                // SW
                p.move(to: .init(x: 6.5, y: 17.5)); p.addLine(to: .init(x: 5, y: 19))
            }

        case .cloud:
            // "M7 18a4.2 4.2 0 0 1 .5-8.4 5.2 5.2 0 0 1 9.9 1.3A3.5 3.5 0 0 1 17 18Z"
            return Path { p in
                p.move(to: .init(x: 7, y: 18))
                p.addArc(center: .init(x: 7, y: 13.8), radius: 4.2,
                         startAngle: .degrees(90), endAngle: .degrees(270), clockwise: false)
                p.addCurve(to: .init(x: 17.5, y: 11.6),
                           control1: .init(x: 8.5, y: 9.6),
                           control2: .init(x: 14.5, y: 9.3))
                p.addArc(center: .init(x: 17, y: 14.5), radius: 3.5,
                         startAngle: .degrees(-50), endAngle: .degrees(90), clockwise: false)
                p.closeSubpath()
            }

        case .cloudRain:
            // cloud + rain lines
            return Path { p in
                // cloud body
                p.move(to: .init(x: 7, y: 15))
                p.addArc(center: .init(x: 7, y: 11), radius: 4,
                         startAngle: .degrees(90), endAngle: .degrees(270), clockwise: false)
                p.addCurve(to: .init(x: 17, y: 12.3),
                           control1: .init(x: 8.5, y: 7),
                           control2: .init(x: 14.5, y: 7.3))
                p.addArc(center: .init(x: 17, y: 12.3), radius: 2.7,
                         startAngle: .degrees(-40), endAngle: .degrees(90), clockwise: false)
                p.closeSubpath()
                // rain drops
                p.move(to: .init(x: 8, y: 18)); p.addLine(to: .init(x: 7, y: 20))
                p.move(to: .init(x: 12, y: 18)); p.addLine(to: .init(x: 11, y: 20))
                p.move(to: .init(x: 16, y: 18)); p.addLine(to: .init(x: 15, y: 20))
            }

        case .doctor:
            // stethoscope shape from design:
            // "M6 4.2v4.3a4 4 0 0 0 8 0V4.2" + "M5.4 4.2H6.4M13.6 4.2h1"
            // "M10 12.4v1.1a3.6 3.6 0 0 0 7.2 0v-.6" + circle cx=17.6 cy=11 r=1.9
            return Path { p in
                // headset U-shape
                p.move(to: .init(x: 6, y: 4.2))
                p.addLine(to: .init(x: 6, y: 8.5))
                p.addArc(center: .init(x: 10, y: 8.5), radius: 4,
                         startAngle: .degrees(180), endAngle: .degrees(0), clockwise: true)
                p.addLine(to: .init(x: 14, y: 4.2))
                // ear tips
                p.move(to: .init(x: 5.4, y: 4.2)); p.addLine(to: .init(x: 6.4, y: 4.2))
                p.move(to: .init(x: 13.6, y: 4.2)); p.addLine(to: .init(x: 14.6, y: 4.2))
                // tube to chest piece
                p.move(to: .init(x: 10, y: 12.4))
                p.addLine(to: .init(x: 10, y: 13.5))
                p.addArc(center: .init(x: 13.6, y: 13.5), radius: 3.6,
                         startAngle: .degrees(180), endAngle: .degrees(0), clockwise: true)
                p.addLine(to: .init(x: 17.2, y: 11))
                // chest piece circle
                p.addEllipse(in: .init(x: 15.7, y: 9.1, width: 3.8, height: 3.8))
            }

        case .grid:
            // 2×2 grid of rounded rects
            return Path { p in
                let rects: [(CGFloat, CGFloat)] = [(4,4),(13,4),(4,13),(13,13)]
                for (x, y) in rects {
                    p.addRoundedRect(in: .init(x: x, y: y, width: 7, height: 7),
                                     cornerSize: .init(width: 1.6, height: 1.6))
                }
            }

        case .chevronRight:
            return Path { p in
                p.move(to: .init(x: 9, y: 5))
                p.addLine(to: .init(x: 16, y: 12))
                p.addLine(to: .init(x: 9, y: 19))
            }

        case .plus:
            return Path { p in
                p.move(to: .init(x: 12, y: 5)); p.addLine(to: .init(x: 12, y: 19))
                p.move(to: .init(x: 5, y: 12)); p.addLine(to: .init(x: 19, y: 12))
            }

        case .leaf:
            return Path { p in
                p.move(to: .init(x: 5, y: 19.4))
                p.addLine(to: .init(x: 7.3, y: 17))
                p.move(to: .init(x: 7.3, y: 17))
                p.addCurve(to: .init(x: 18.6, y: 6),
                            control1: .init(x: 4, y: 10.5),
                            control2: .init(x: 11.5, y: 5.8))
                p.addCurve(to: .init(x: 7.3, y: 17),
                            control1: .init(x: 19, y: 13),
                            control2: .init(x: 14, y: 18))
                p.move(to: .init(x: 9.3, y: 14.7))
                p.addCurve(to: .init(x: 16.2, y: 10.8),
                            control1: .init(x: 11, y: 13),
                            control2: .init(x: 13.5, y: 11.5))
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        HStack(spacing: 20) {
            HHIcon(name: .book, size: 24, color: HHColor.inkSoft)
            HHIcon(name: .bell, size: 24, color: HHColor.inkSoft)
            HHIcon(name: .pin, size: 24, color: HHColor.inkSoft)
            HHIcon(name: .sun, size: 24, color: Color(hex: "#B3852F"))
            HHIcon(name: .cloud, size: 24, color: HHColor.inkSoft)
            HHIcon(name: .cloudRain, size: 24, color: HHColor.inkSoft)
        }
        HStack(spacing: 20) {
            HHIcon(name: .doctor, size: 24, color: HHColor.inkSoft)
            HHIcon(name: .grid, size: 24, color: HHColor.inkSoft)
            HHIcon(name: .chevronRight, size: 24, color: HHColor.inkFaint)
            HHIcon(name: .plus, size: 24, color: HHColor.inkFaint)
            HHIcon(name: .leaf, size: 24, color: HHColor.green)
        }
    }
    .padding()
    .background(HHColor.paper)
}
