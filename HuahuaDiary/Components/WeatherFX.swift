//
//  WeatherFX.swift
//  HuahuaDiary
//
//  Atmosphere overlay for the immersive weather header:
//  rain drops · sun motes · drifting clouds.
//

import SwiftUI

enum WeatherFXKind {
    case rain
    case sun
    case cloudy
}

struct WeatherFXLayer: View {
    let kind: WeatherFXKind

    var body: some View {
        ZStack {
            switch kind {
            case .rain: RainField()
            case .sun: SunMotes()
            case .cloudy: CloudDrift()
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Rain

private struct RainField: View {
    private static func makeDrops() -> [Drop] {
        (0..<22).map { i in
            let x = Double((i * 5 + (i % 3) * 2) % 100) / 100.0
            let length = 13.0 + Double(i % 4) * 4.0
            let duration = 0.75 + Double(i % 3) * 0.22
            let delay = Double(i % 7) * 0.18
            return Drop(x: x, length: length, duration: duration, delay: delay)
        }
    }
    private let drops: [Drop] = RainField.makeDrops()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(drops) { d in
                    Raindrop(length: d.length, duration: d.duration, delay: d.delay, height: geo.size.height)
                        .position(x: d.x * geo.size.width, y: 0)
                }
            }
        }
    }

    struct Drop: Identifiable {
        let id = UUID()
        let x: Double
        let length: Double
        let duration: Double
        let delay: Double
    }
}

private struct Raindrop: View {
    let length: Double
    let duration: Double
    let delay: Double
    let height: Double

    @State private var animating = false

    var body: some View {
        Capsule()
            .fill(
                LinearGradient(
                    colors: [
                        Color(hex: "#6E8295", opacity: 0.0),
                        Color(hex: "#5F7388", opacity: 0.55)
                    ],
                    startPoint: .top, endPoint: .bottom
                )
            )
            .frame(width: 1.4, height: length)
            .offset(y: animating ? height + 40 : -40)
            .opacity(animating ? 0 : 1)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                        animating = true
                    }
                }
            }
    }
}

// MARK: - Sun motes (rising sparkles)

private struct SunMotes: View {
    private static func makeMotes() -> [Mote] {
        (0..<10).map { i in
            let x = 0.10 + Double(i) * 0.09
            let y = 0.30 + Double(i % 4) * 0.16
            let duration = 3.0 + Double(i % 3) * 0.7
            let delay = Double(i % 5) * 0.6
            return Mote(x: x, y: y, duration: duration, delay: delay)
        }
    }
    private let motes: [Mote] = SunMotes.makeMotes()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(motes) { m in
                    MoteOrb(duration: m.duration, delay: m.delay)
                        .position(x: m.x * geo.size.width, y: m.y * geo.size.height)
                }
            }
        }
    }

    struct Mote: Identifiable {
        let id = UUID()
        let x: Double
        let y: Double
        let duration: Double
        let delay: Double
    }
}

private struct MoteOrb: View {
    let duration: Double
    let delay: Double
    @State private var on = false

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [Color(hex: "#FFF6D8"), Color(hex: "#FFF6D8", opacity: 0)],
                    center: .center,
                    startRadius: 0, endRadius: 3
                )
            )
            .frame(width: 6, height: 6)
            .offset(y: on ? -46 : 0)
            .opacity(on ? 0 : 0.85)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.easeIn(duration: duration).repeatForever(autoreverses: false)) {
                        on = true
                    }
                }
            }
    }
}

// MARK: - Drifting clouds

private struct CloudDrift: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                CloudBlob(width: 110, height: 34, duration: 7, delay: 0)
                    .position(x: geo.size.width * 0.18, y: 48)
                CloudBlob(width: 88, height: 28, duration: 9, delay: 1.2)
                    .position(x: geo.size.width * 0.78, y: 78)
                CloudBlob(width: 70, height: 22, duration: 11, delay: 2.0)
                    .position(x: geo.size.width * 0.46, y: 96)
            }
        }
    }
}

private struct CloudBlob: View {
    let width: Double
    let height: Double
    let duration: Double
    let delay: Double
    @State private var drift = false

    var body: some View {
        Capsule()
            .fill(Color.white.opacity(0.5))
            .blur(radius: 6)
            .frame(width: width, height: height)
            .offset(x: drift ? 16 : -12)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                        drift = true
                    }
                }
            }
    }
}
