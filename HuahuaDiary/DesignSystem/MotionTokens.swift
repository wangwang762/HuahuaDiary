//
//  MotionTokens.swift
//  HuahuaDiary
//

import SwiftUI

enum HHMotion {
    static let snap = Animation.spring(response: 0.32, dampingFraction: 0.78)
    static let rise = Animation.spring(response: 0.55, dampingFraction: 0.82)
    static let pop = Animation.spring(response: 0.42, dampingFraction: 0.62)
    static let riseEase = Animation.timingCurve(0.2, 0.7, 0.3, 1, duration: 0.5)
    static let smooth = Animation.smooth(duration: 0.32)
}

struct PressScale: ViewModifier {
    @State private var pressing = false
    var scale: CGFloat = 0.96
    var haptic: UIImpactFeedbackGenerator.FeedbackStyle? = .soft

    func body(content: Content) -> some View {
        content
            .scaleEffect(pressing ? scale : 1.0)
            .animation(HHMotion.snap, value: pressing)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !pressing {
                            pressing = true
                            if let style = haptic {
                                UIImpactFeedbackGenerator(style: style).impactOccurred(intensity: 0.55)
                            }
                        }
                    }
                    .onEnded { _ in pressing = false }
            )
    }
}

extension View {
    func pressScale(_ scale: CGFloat = 0.96, haptic: UIImpactFeedbackGenerator.FeedbackStyle? = .soft) -> some View {
        modifier(PressScale(scale: scale, haptic: haptic))
    }
}
