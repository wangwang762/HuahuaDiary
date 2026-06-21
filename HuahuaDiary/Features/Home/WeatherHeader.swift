//
//  WeatherHeader.swift
//  HuahuaDiary
//
//  Immersive masthead: weather mood gradient · atmospheric FX · city pill ·
//  weather icon · mood phrase · title · editorial rule.
//

import SwiftUI

// MARK: - Weather mood preset
struct WeatherMoodPreset {
    let icon: HHIconName
    let temp: String
    let skyTop: Color
    let skyMid: Color
    let glow: Color?
    let phrase: String
    let note: String
    let tint: Color
    let fx: WeatherFXKind

    static func preset(for w: WeatherMood) -> WeatherMoodPreset {
        switch w {
        case .rain:
            return WeatherMoodPreset(
                icon: .cloudRain, temp: "22°",
                skyTop: Color(hex: "#AEBCCB"), skyMid: Color(hex: "#C8CED4"),
                glow: nil, phrase: "细雨天", note: "宜窝在家，陪花说说话",
                tint: Color(hex: "#5C6B7A"), fx: .rain
            )
        case .sun:
            return WeatherMoodPreset(
                icon: .sun, temp: "27°",
                skyTop: Color(hex: "#F7E2A2"), skyMid: Color(hex: "#F4E7CF"),
                glow: Color(hex: "#FFEEB4", opacity: 0.9), phrase: "阳光正好", note: "晒晒你，也晒晒它们",
                tint: Color(hex: "#B3852F"), fx: .sun
            )
        case .cloudy:
            return WeatherMoodPreset(
                icon: .cloud, temp: "24°",
                skyTop: Color(hex: "#D2D7CF"), skyMid: Color(hex: "#E4E2D4"),
                glow: nil, phrase: "云慢悠悠的", note: "刚刚好的一天",
                tint: Color(hex: "#79806F"), fx: .cloudy
            )
        }
    }
}

// MARK: - Header
struct WeatherHeader: View {
    let weather: WeatherMood
    let titleStyle: AppTitleStyle
    let bgFlourish: Bool
    var city: String = "上海"

    private var preset: WeatherMoodPreset { WeatherMoodPreset.preset(for: weather) }

    /// 从 UIKit 获取真实的顶部安全区距离（灵动岛 / 刘海）
    private var statusBarHeight: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.top ?? 54
    }

    var body: some View {
        ZStack(alignment: .top) {
            // 天空渐变 — 延伸到屏幕最顶部
            LinearGradient(
                stops: [
                    .init(color: preset.skyTop, location: 0.0),
                    .init(color: preset.skyMid, location: 0.42),
                    .init(color: HHColor.paper.opacity(0.5), location: 0.78),
                    .init(color: HHColor.paper, location: 1.0)
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea(edges: .top)

            // 晴天右上角光晕
            if let glow = preset.glow {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [glow, Color(hex: "#FFEEB4", opacity: 0)],
                            center: .center,
                            startRadius: 0, endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                    .offset(x: 140, y: -70)
                    .allowsHitTesting(false)
            }

            // 天气粒子动效
            if bgFlourish {
                WeatherFXLayer(kind: preset.fx)
                    .ignoresSafeArea(edges: .top)
            }

            // 内容区 — 用 UIKit 读到的真实安全区高度做顶部偏移
            VStack(alignment: .leading, spacing: 0) {
                Color.clear.frame(height: statusBarHeight + 10)
                topRow
                Spacer().frame(height: 14)
                moodLine
                Spacer().frame(height: 12)
                TitleMark(style: titleStyle)
                Spacer().frame(height: 14)
                EditorialRule()
                Spacer().frame(height: 6)
            }
            .padding(.horizontal, 22)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: top row
    private var topRow: some View {
        HStack {
            Button { } label: {
                HStack(spacing: 4) {
                    HHIcon(name: .pin, size: 15, color: preset.tint, strokeWidth: 1.8)
                    Text(city)
                        .font(HHFont.ui(13, weight: .semibold))
                        .foregroundStyle(HHColor.ink)
                    HHIcon(name: .chevronRight, size: 12, color: HHColor.inkFaint, strokeWidth: 1.8)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            HStack(spacing: 6) {
                HHIcon(name: preset.icon, size: 17, color: preset.tint, strokeWidth: 1.8)
                Text(weather.rawValue)
                    .font(HHFont.ui(13, weight: .semibold))
                    .foregroundStyle(HHColor.inkSoft)
                Text(preset.temp)
                    .font(HHFont.num(13, weight: .semibold))
                    .foregroundStyle(HHColor.inkSoft)
            }
        }
    }

    // MARK: mood line
    private var moodLine: some View {
        HStack(alignment: .lastTextBaseline, spacing: 10) {
            Text(preset.phrase)
                .font(HHFont.hand(21, weight: .bold))
                .foregroundStyle(preset.tint)
            Text(preset.note)
                .font(HHFont.journal(13))
                .foregroundStyle(HHColor.inkSoft)
        }
    }
}

// MARK: - Title mark (three styles)
struct TitleMark: View {
    let style: AppTitleStyle

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            switch style {
            case .clean:
                Text("花花日记本")
                    .font(HHFont.journal(33, weight: .medium))
                    .tracking(2)
                    .foregroundStyle(HHColor.ink)
            case .hand:
                Text("花花日记本")
                    .font(HHFont.hand(38, weight: .bold))
                    .tracking(3)
                    .foregroundStyle(HHColor.ink)
            case .mixed:
                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text("花花")
                        .font(HHFont.script(50))
                        .foregroundStyle(HHColor.greenDeep)
                    Text("日记本")
                        .font(HHFont.journal(27, weight: .medium))
                        .tracking(2)
                        .foregroundStyle(HHColor.ink)
                }
            }
            Text("A DIARY FOR YOUR PLANTS")
                .font(HHFont.ui(9))
                .tracking(3.4)
                .foregroundStyle(HHColor.inkFaint)
        }
    }
}
