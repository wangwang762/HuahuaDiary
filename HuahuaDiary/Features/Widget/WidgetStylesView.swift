//
//  WidgetStylesView.swift
//  HuahuaDiary
//
//  小组件样式页 — 对照 screens-widget.jsx 还原
//  · 花园版（只有花园）
//  · 正方形 / 长方形 横向分页预览
//  · 配色五选一
//

import SwiftUI

// MARK: - 配色主题（对照 WTHEMES）

struct WTheme: Identifiable {
    let id: String
    let accent: Color
    let light0: Color   // light[0]
    let light1: Color   // light[1]
    let warm0: Color    // warm[0]
    let warm1: Color    // warm[1]
    let ink: Color
    let sub: Color
}

private let wthemes: [WTheme] = [
    WTheme(id: "pine",  accent: Color(hex:"#2C6147"),
           light0: Color(hex:"#ECF2E6"), light1: Color(hex:"#D8E6CF"),
           warm0:  Color(hex:"#E9F1E2"), warm1:  Color(hex:"#D2E4C8"),
           ink: Color(hex:"#21311f"), sub: Color(hex:"#3f6b4a")),
    WTheme(id: "terra", accent: Color(hex:"#C8553C"),
           light0: Color(hex:"#F7E9E1"), light1: Color(hex:"#EDD2C4"),
           warm0:  Color(hex:"#F8E7D6"), warm1:  Color(hex:"#F0CCAE"),
           ink: Color(hex:"#3a201a"), sub: Color(hex:"#9a5640")),
    WTheme(id: "dusk",  accent: Color(hex:"#3E6B8C"),
           light0: Color(hex:"#E4ECF2"), light1: Color(hex:"#CDDAE7"),
           warm0:  Color(hex:"#E6EDF3"), warm1:  Color(hex:"#CFDCEA"),
           ink: Color(hex:"#1f2f3f"), sub: Color(hex:"#42647d")),
    WTheme(id: "plum",  accent: Color(hex:"#8A5A8C"),
           light0: Color(hex:"#EFE6F0"), light1: Color(hex:"#DDC9DF"),
           warm0:  Color(hex:"#F0E6F1"), warm1:  Color(hex:"#DEC9E0"),
           ink: Color(hex:"#332036"), sub: Color(hex:"#6e4d70")),
    WTheme(id: "gold",  accent: Color(hex:"#D7A23F"),
           light0: Color(hex:"#F7EFD7"), light1: Color(hex:"#EEDDAE"),
           warm0:  Color(hex:"#F9ECCB"), warm1:  Color(hex:"#F1D89E"),
           ink: Color(hex:"#3d2c11"), sub: Color(hex:"#8a6a2a")),
]

// MARK: - 主视图

struct WidgetStylesView: View {
    @Environment(AppState.self) private var app

    @State private var sizeIdx: Int = 0          // 0=正方形 1=长方形
    @State private var themeId: String = "pine"
    @State private var scrollPos: Int = 0

    private var theme: WTheme { wthemes.first { $0.id == themeId } ?? wthemes[0] }
    private let sizeNames = ["正方形", "长方形"]

    var body: some View {
        VStack(spacing: 0) {
            pageHeader
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    previewPager
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    colorSection
                        .padding(.top, 24)
                        .padding(.bottom, 130)
                }
            }
        }
        .background(HHColor.paper)
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: 页头
    private var pageHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 3) {
                Text("小组件样式")
                    .font(HHFont.display(22, weight: .bold))
                    .foregroundStyle(HHColor.ink)
                Text("把小花园放上桌面，随时看看它们")
                    .font(HHFont.journal(12.5))
                    .foregroundStyle(HHColor.inkFaint)
            }
            Spacer()
            Button("完成") { }
                .font(HHFont.ui(15, weight: .semibold))
                .foregroundStyle(HHColor.green)
        }
        .padding(.horizontal, 22)
        .padding(.top, 54)
        .padding(.bottom, 0)
    }

    // MARK: 分页预览容器
    private var previewPager: some View {
        VStack(spacing: 0) {
            // 横向分页 ScrollView
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    // 正方形 widget
                    SquareGardenWidget(plants: app.plants, theme: theme)
                        .frame(width: 152, height: 152)
                        .clipShape(RoundedRectangle(cornerRadius: 24 * 0.655, style: .continuous))
                        .shadow(color: .black.opacity(0.13), radius: 10, x: 0, y: 4)
                        .scrollTransition { content, phase in
                            content.opacity(phase.isIdentity ? 1 : 0.6)
                                   .scaleEffect(phase.isIdentity ? 1 : 0.95)
                        }
                        .containerRelativeFrame(.horizontal, count: 1, spacing: 20)
                        .id(0)

                    // 长方形 widget
                    WideGardenWidget(plants: app.plants, theme: theme)
                        .frame(width: 300, height: 142)
                        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                        .shadow(color: .black.opacity(0.13), radius: 10, x: 0, y: 4)
                        .scrollTransition { content, phase in
                            content.opacity(phase.isIdentity ? 1 : 0.6)
                                   .scaleEffect(phase.isIdentity ? 1 : 0.95)
                        }
                        .containerRelativeFrame(.horizontal, count: 1, spacing: 20)
                        .id(1)
                }
                .scrollTargetLayout()
            }
            .contentMargins(.horizontal, 48, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned)
            .frame(height: 200)
            .onScrollTargetVisibilityChange(idType: Int.self) { ids in
                if let first = ids.first { sizeIdx = first }
            }

            // 点 + 尺寸标签
            HStack(spacing: 18) {
                ForEach(sizeNames.indices, id: \.self) { i in
                    let on = i == sizeIdx
                    HStack(spacing: 6) {
                        Capsule()
                            .fill(on ? theme.accent : Color(hex:"#221F18", opacity: 0.18))
                            .frame(width: on ? 16 : 7, height: 7)
                            .animation(HHMotion.snap, value: sizeIdx)
                        Text(sizeNames[i])
                            .font(HHFont.journal(11.5, weight: on ? .bold : .regular))
                            .foregroundStyle(on ? theme.accent : HHColor.inkFaint)
                            .animation(HHMotion.snap, value: sizeIdx)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 10)
            .padding(.bottom, 14)
        }
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color(hex:"#efe7d8"), location: 0),
                            .init(color: Color(hex:"#e6dbc7"), location: 0.6),
                            .init(color: Color(hex:"#ddd0b7"), location: 1)
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                // 主题色顶部晕染
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(
                            RadialGradient(
                                colors: [theme.accent.opacity(0.12), theme.accent.opacity(0)],
                                center: UnitPoint(x: 0.5, y: -0.1),
                                startRadius: 0, endRadius: 250
                            )
                        )
                        .animation(HHMotion.smooth, value: themeId)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }

    // MARK: 配色
    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("配色")
                    .font(HHFont.ui(13, weight: .semibold))
                    .foregroundStyle(HHColor.ink)
                Rectangle()
                    .fill(HHColor.hairline)
                    .frame(height: 1)
                Text("随季节换个心情")
                    .font(HHFont.journal(12))
                    .foregroundStyle(HHColor.inkFaint)
            }
            .padding(.horizontal, 24)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(wthemes) { tm in
                        let on = themeId == tm.id
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            withAnimation(HHMotion.snap) { themeId = tm.id }
                        } label: {
                            ThemeSwatch(theme: tm, selected: on)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 4)
            }
        }
    }
}

// MARK: - 色卡

private struct ThemeSwatch: View {
    let theme: WTheme
    let selected: Bool

    // 色卡背景 = 实际花园渐变（对照 balconyBg）
    private var balconyGrad: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: Color(hex:"#eef4f8"), location: 0),
                .init(color: theme.light0, location: 0.46),
                .init(color: theme.warm1, location: 1)
            ],
            startPoint: .top, endPoint: .bottom
        )
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // 天空渐变底
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(balconyGrad)
                .frame(width: 52, height: 52)

            // 底部主题色条（代表主题色调）
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(theme.accent.opacity(0.9))
                .frame(width: 52, height: 9)
                .mask(
                    VStack(spacing: 0) {
                        Color.clear
                        Color.black.frame(height: 9)
                    }
                )

            // 选中勾
            if selected {
                Circle()
                    .fill(theme.accent)
                    .frame(width: 22, height: 22)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                    )
                    .shadow(color: .black.opacity(0.22), radius: 2, x: 0, y: 1)
            }
        }
        .frame(width: 52, height: 52)
        .overlay(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .strokeBorder(
                    selected ? theme.accent : Color(hex:"#221F18", opacity: 0.12),
                    lineWidth: selected ? 2 : 1
                )
        )
        .shadow(
            color: selected ? theme.accent.opacity(0.35) : .black.opacity(0.08),
            radius: selected ? 8 : 3, x: 0, y: 2
        )
        .scaleEffect(selected ? 1.05 : 1)
        .animation(HHMotion.snap, value: selected)
    }
}

// MARK: - 正方形花园 widget

struct SquareGardenWidget: View {
    let plants: [Plant]
    let theme: WTheme

    private var star: Plant { plants.first ?? MockData.ciji }
    private var quote: String {
        // 用植物自身的 voice，去掉括号旁白 （小声）→ 只留正文
        let cleaned = star.voice.replacingOccurrences(
            of: "（[^）]*）", with: "", options: .regularExpression
        ).trimmingCharacters(in: .whitespaces)
        return cleaned.isEmpty ? star.voice : cleaned
    }

    // Widget 尺寸：152×152（原始 232×232 × 0.655 缩放）
    // starH = H * 0.5 = 76；shelfW = starH * 0.7 ≈ 53
    private let starH: CGFloat = 76
    private let shelfH: CGFloat = 8
    private let spaceBelow: CGFloat = 12  // shelf 与底部的间距

    private var shelfWidth: CGFloat { starH * 0.7 }
    private var seat: CGFloat { spaceBelow + shelfH - 4 } // 植物盆底距底部

    var body: some View {
        ZStack {
            // 天空背景
            BalconyBackground(theme: theme)

            // 左侧文字（名字 + 天气 + 引言）
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center) {
                    Text(star.name)
                        .font(HHFont.display(18, weight: .bold))
                        .foregroundStyle(theme.ink)
                        .lineLimit(1)
                    Spacer()
                    WeatherChip()
                }
                .padding(.bottom, 8)

                Text("\u{201C}\(quote)\u{201D}")
                    .font(HHFont.journal(11.5))
                    .foregroundStyle(theme.ink.opacity(0.92))
                    .lineSpacing(2)
                    .lineLimit(4)
                    // 最大 68% 宽度 ≈ 103pt（widget 总宽 152pt）
                    .frame(maxWidth: 103, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()
            }
            .padding(14)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            // 雨丝 FX
            RainFX()
        }
        // 迷你木架：绝对定位在右下角
        .overlay(alignment: .bottomTrailing) {
            WoodenShelf(width: shelfWidth)
                .padding(.trailing, 8)
                .padding(.bottom, spaceBelow)
        }
        // 植物图：绝对定位在木架上方（带随风摆动动效）
        .overlay(alignment: .bottomTrailing) {
            SwayingPlant(plant: star, width: shelfWidth, height: starH)
                .padding(.trailing, 8)
                .padding(.bottom, seat)
        }
        // 小访客（蜜蜂/蝴蝶/小鸟）随机飞过
        .overlay { CrittersOverlay() }
    }
}

// MARK: - 长方形花园 widget（全家福）

struct WideGardenWidget: View {
    let plants: [Plant]
    let theme: WTheme

    // Widget 尺寸：300×142（原始 320×152 × 1.0 缩放）
    // plantH = H * 0.42 ≈ 60；seat = 12 + 8 - 4 = 16
    private let plantH: CGFloat = 60
    private let shelfH: CGFloat = 8
    private let spaceBelow: CGFloat = 12

    private var seat: CGFloat { spaceBelow + shelfH - 4 }

    var body: some View {
        ZStack {
            BalconyBackground(theme: theme)

            // 顶部文字
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("我的小花园 · 全家福")
                            .font(HHFont.display(15, weight: .bold))
                            .foregroundStyle(theme.ink)
                        HStack(spacing: 3) {
                            Text("\(plants.count) 盆 · 都还活着")
                                .font(HHFont.ui(10.5, weight: .semibold))
                                .foregroundStyle(theme.sub)
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 9))
                                .foregroundStyle(theme.sub)
                        }
                    }
                    Spacer()
                    WeatherChip()
                }
                Spacer()
            }
            .padding(14)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            RainFX()
        }
        // 全宽木架：绝对定位在距底部 spaceBelow
        .overlay(alignment: .bottom) {
            WoodenShelf(width: nil)
                .padding(.bottom, spaceBelow)
        }
        // 植物排在架上：绝对定位在距底部 seat（奇数索引略矮 0.94，错落感）
        .overlay(alignment: .bottom) {
            HStack(alignment: .bottom, spacing: 0) {
                ForEach(Array(plants.enumerated()), id: \.element.id) { idx, plant in
                    // reversed 交替 → 左右左右摇摆；delay 错开出发时间增加自然感
                    SwayingPlant(
                        plant: plant,
                        width: nil,
                        height: plantH * (idx % 2 == 1 ? 0.94 : 1),
                        reversed: idx % 2 == 1,
                        delay: 0.05 + Double(idx) * 0.18
                    )
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, seat)
        }
        // 小访客（蜜蜂/蝴蝶/小鸟）随机飞过
        .overlay { CrittersOverlay() }
    }
}

// MARK: - 共享子组件

/// 花园天空渐变背景（对照 balconyBg）
private struct BalconyBackground: View {
    let theme: WTheme

    var body: some View {
        LinearGradient(
            stops: [
                .init(color: Color(hex:"#eef4f8"), location: 0),
                .init(color: theme.light0, location: 0.46),
                .init(color: theme.warm1, location: 1)
            ],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

/// 木窗台（对照 wooden windowsill）
private struct WoodenShelf: View {
    var width: CGFloat?   // nil = 全宽

    var body: some View {
        ZStack(alignment: .top) {
            // 顶部高光
            Rectangle()
                .fill(Color(hex:"#fff5e1", opacity: 0.55))
                .frame(height: 1.5)
                .frame(maxWidth: .infinity, alignment: .top)
            // 主木架
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex:"#e7c79e"),
                            Color(hex:"#d3a468"),
                            Color(hex:"#c0934f")
                        ],
                        startPoint: .top, endPoint: .bottom
                    )
                )
        }
        .frame(width: width, height: 8)
        .shadow(color: Color(hex:"#785028", opacity: 0.18), radius: 4, x: 0, y: 3)
    }
}

/// 天气胶囊（对照 WxChip）
private struct WeatherChip: View {
    var body: some View {
        HStack(spacing: 4) {
            HHIcon(name: .cloudRain, size: 12, color: Color(hex:"#221F18", opacity: 0.65), strokeWidth: 1.5)
            Text("22°")
                .font(HHFont.num(11, weight: .semibold))
                .foregroundStyle(Color(hex:"#221F18", opacity: 0.65))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.6))
        )
    }
}

/// 随风摆动植物（对照 screens-widget.jsx swayBody 关键帧）
/// 以 soilFraction 为旋转锚点，±3.2° 来回摇摆
/// reversed=true → 先向右再向左（奇数索引用），实现全家福"左右左右"交替效果
private struct SwayingPlant: View {
    let plant: Plant
    let width: CGFloat?
    let height: CGFloat
    var reversed: Bool = false
    var delay: Double = 0.05

    @State private var sway = false

    private var duration: Double {
        switch plant.shape {
        case .cactus:    3.6
        case .succulent: 2.8
        case .pothos:    3.2
        case .monstera:  4.0
        case .sunflower: 2.4
        }
    }

    // reversed 时把两个端点对调，实现初始方向相反
    private var deg: Double { (reversed ? !sway : sway) ? 3.2 : -3.2 }

    var body: some View {
        Image(plant.cutoutAssetName)
            .resizable()
            .scaledToFit()
            .frame(width: width, height: height)
            .rotationEffect(
                .degrees(deg),
                anchor: UnitPoint(x: 0.5, y: plant.shape.soilFraction)
            )
            .animation(
                .easeInOut(duration: duration / 2)
                    .repeatForever(autoreverses: true),
                value: sway
            )
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    sway = true
                }
            }
    }
}

// MARK: - 小访客（蜜蜂 / 蝴蝶 / 小鸟）对照 screens-widget.jsx CritterArt + Critters

private enum CritterKind {
    case bee, butterfly, bird
    static func next() -> CritterKind {
        // 蜜蜂/蝴蝶较常见，小鸟更稀有（同 JSX types 数组比例）
        [CritterKind.bee, .butterfly, .bee, .butterfly, .bird].randomElement()!
    }
}

/// 蜜蜂：黄色椭圆体 + 透明翅膀（快速扑动 0.09s）
private struct BeeShape: View {
    @State private var flap = false
    var body: some View {
        ZStack {
            // 翅膀（两侧，锚点靠近身体连接处）
            Ellipse()
                .fill(Color(red:0.86,green:0.93,blue:1).opacity(0.85))
                .overlay(Ellipse().strokeBorder(Color(red:0.47,green:0.59,blue:0.71).opacity(0.5), lineWidth:0.5))
                .frame(width: 9, height: 5.5)
                .offset(x: -3, y: -5)
                .scaleEffect(y: flap ? 0.35 : 1.0, anchor: .bottom)
            Ellipse()
                .fill(Color(red:0.86,green:0.93,blue:1).opacity(0.85))
                .overlay(Ellipse().strokeBorder(Color(red:0.47,green:0.59,blue:0.71).opacity(0.5), lineWidth:0.5))
                .frame(width: 9, height: 5.5)
                .offset(x: 3, y: -5)
                .scaleEffect(y: flap ? 0.35 : 1.0, anchor: .bottom)
            // 身体（黄色椭圆 + 黑色条纹）
            Ellipse()
                .fill(Color(hex:"#F2B73A"))
                .overlay(Ellipse().strokeBorder(Color(hex:"#6b4a14"), lineWidth:0.7))
                .frame(width: 10, height: 7)
            Path { p in
                p.move(to: .init(x:-1, y:-3)); p.addLine(to: .init(x:-1, y:3))
                p.move(to: .init(x: 2, y:-3)); p.addLine(to: .init(x: 2, y:3))
            }
            .stroke(Color(hex:"#5a3d12"), lineWidth:1.1)
            .frame(width: 10, height: 7)
            // 眼睛
            Circle().fill(Color(hex:"#3a2a10")).frame(width:3, height:3).offset(x:4, y:-2)
            Circle().fill(.white).frame(width:0.8, height:0.8).offset(x:3.5, y:-2.4)
        }
        .frame(width: 22, height: 22)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.09).repeatForever(autoreverses: true)) { flap = true }
        }
    }
}

/// 蝴蝶：橙色翅膀（上下各一对，中轴合拢扑动 0.2s）
private struct ButterflyShape: View {
    @State private var flap = false
    var body: some View {
        ZStack {
            // 左翅（两片：上翅 + 下翅）
            Group {
                Path { p in
                    p.move(to: .init(x:12,y:12))
                    p.addCurve(to:.init(x:4,y:6), control1:.init(x:8,y:5), control2:.init(x:3,y:6))
                    p.addCurve(to:.init(x:5.5,y:13), control1:.init(x:2,y:10), control2:.init(x:3.5,y:13))
                    p.closeSubpath()
                }.fill(Color(hex:"#EBA35E")).overlay(
                    Path { p in
                        p.move(to: .init(x:12,y:12))
                        p.addCurve(to:.init(x:4,y:6), control1:.init(x:8,y:5), control2:.init(x:3,y:6))
                        p.addCurve(to:.init(x:5.5,y:13), control1:.init(x:2,y:10), control2:.init(x:3.5,y:13))
                        p.closeSubpath()
                    }.stroke(Color(hex:"#b56b2f"), lineWidth:0.5)
                )
                Path { p in
                    p.move(to: .init(x:11,y:12))
                    p.addCurve(to:.init(x:3,y:18), control1:.init(x:4,y:12), control2:.init(x:1,y:16))
                    p.addCurve(to:.init(x:10,y:16), control1:.init(x:6,y:21), control2:.init(x:10,y:18))
                    p.closeSubpath()
                }.fill(Color(hex:"#F2B470"))
                Circle().fill(Color(hex:"#FBE7C8")).frame(width:1.8,height:1.8).offset(x:-5.4, y:-1.4)
            }
            .scaleEffect(x: flap ? 0.3 : 1.0, anchor: UnitPoint(x:0.6, y:0.5))

            // 右翅（镜像）
            Group {
                Path { p in
                    p.move(to: .init(x:12,y:12))
                    p.addCurve(to:.init(x:20,y:6), control1:.init(x:16,y:5), control2:.init(x:21,y:6))
                    p.addCurve(to:.init(x:18.5,y:13), control1:.init(x:22,y:10), control2:.init(x:20.5,y:13))
                    p.closeSubpath()
                }.fill(Color(hex:"#F2B470")).overlay(
                    Path { p in
                        p.move(to: .init(x:12,y:12))
                        p.addCurve(to:.init(x:20,y:6), control1:.init(x:16,y:5), control2:.init(x:21,y:6))
                        p.addCurve(to:.init(x:18.5,y:13), control1:.init(x:22,y:10), control2:.init(x:20.5,y:13))
                        p.closeSubpath()
                    }.stroke(Color(hex:"#b56b2f"), lineWidth:0.5)
                )
                Path { p in
                    p.move(to: .init(x:13,y:12))
                    p.addCurve(to:.init(x:21,y:18), control1:.init(x:20,y:12), control2:.init(x:23,y:16))
                    p.addCurve(to:.init(x:14,y:16), control1:.init(x:18,y:21), control2:.init(x:14,y:18))
                    p.closeSubpath()
                }.fill(Color(hex:"#EBA35E"))
                Circle().fill(Color(hex:"#FBE7C8")).frame(width:1.8,height:1.8).offset(x:5.4, y:-1.4)
            }
            .scaleEffect(x: flap ? 0.3 : 1.0, anchor: UnitPoint(x:0.4, y:0.5))

            // 身体（细长椭圆）
            Ellipse().fill(Color(hex:"#4a3420")).frame(width:1.8,height:7).offset(y:1)
            // 触角
            Path { p in
                p.move(to:.init(x:12,y:8)); p.addLine(to:.init(x:10,y:6))
                p.move(to:.init(x:12,y:8)); p.addLine(to:.init(x:14,y:6))
            }
            .stroke(Color(hex:"#4a3420"), lineWidth:0.6)
            .frame(width:24, height:14)
        }
        .frame(width: 24, height: 22)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.2).repeatForever(autoreverses: true)) { flap = true }
        }
    }
}

/// 小鸟（燕子剪影）：翅膀扑动 0.22s + 身体轻微上下晃动
private struct BirdShape: View {
    @State private var flap = false
    @State private var bob = false
    var body: some View {
        ZStack {
            // 燕子身体轮廓
            Path { p in
                p.move(to: .init(x:14,y:9))
                p.addCurve(to:.init(x:18.2,y:10.2), control1:.init(x:15.6,y:8.6), control2:.init(x:17,y:9.4))
                p.addCurve(to:.init(x:17.9,y:13.2), control1:.init(x:19.3,y:11), control2:.init(x:18.8,y:12.4))
                p.addCurve(to:.init(x:21.8,y:12.6), control1:.init(x:18.8,y:14.2), control2:.init(x:20.4,y:13.4))
                p.addCurve(to:.init(x:17.2,y:16.1), control1:.init(x:22.8,y:14.4), control2:.init(x:20.1,y:16))
                p.addCurve(to:.init(x:17.2,y:17.9), control1:.init(x:17.4,y:16.7), control2:.init(x:17.4,y:17.3))
                p.addCurve(to:.init(x:14,y:17), control1:.init(x:16.3,y:18.8), control2:.init(x:15.2,y:18.3))
                p.addCurve(to:.init(x:10.8,y:17.9), control1:.init(x:12.8,y:18.3), control2:.init(x:11.7,y:18.8))
                p.addCurve(to:.init(x:10.8,y:16.1), control1:.init(x:10.6,y:17.3), control2:.init(x:10.6,y:16.7))
                p.addCurve(to:.init(x:6.2,y:12.6), control1:.init(x:7.9,y:16), control2:.init(x:5.2,y:14.4))
                p.addCurve(to:.init(x:10.1,y:13.2), control1:.init(x:7.6,y:13.4), control2:.init(x:9.2,y:14.2))
                p.addCurve(to:.init(x:9.8,y:10.2), control1:.init(x:9.2,y:12.4), control2:.init(x:8.7,y:11))
                p.addCurve(to:.init(x:14,y:9), control1:.init(x:11,y:9.4), control2:.init(x:12.4,y:8.6))
            }.fill(Color(hex:"#5a6b7a"))

            // 左翅
            Path { p in
                p.move(to:.init(x:13.6,y:12.8))
                p.addCurve(to:.init(x:5.4,y:11.2), control1:.init(x:10,y:10.5), control2:.init(x:7,y:10.4))
                p.addLine(to:.init(x:9.8,y:14.4))
                p.closeSubpath()
            }
            .fill(Color(hex:"#46545f"))
            .rotationEffect(.degrees(flap ? -22 : 5), anchor: UnitPoint(x:0.5, y:0.55))

            // 右翅
            Path { p in
                p.move(to:.init(x:14.4,y:12.8))
                p.addCurve(to:.init(x:22.6,y:11.2), control1:.init(x:18,y:10.5), control2:.init(x:21,y:10.4))
                p.addLine(to:.init(x:18.2,y:14.4))
                p.closeSubpath()
            }
            .fill(Color(hex:"#46545f"))
            .rotationEffect(.degrees(flap ? 22 : -5), anchor: UnitPoint(x:0.5, y:0.55))

            // 眼睛
            Circle().fill(Color(hex:"#1f2a33")).frame(width:1.5,height:1.5).offset(x:4.4, y:1.4)
        }
        .frame(width: 30, height: 22)
        .offset(y: bob ? -3 : 0)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.22).repeatForever(autoreverses: true)) { flap = true }
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) { bob = true }
        }
    }
}

/// 小访客动画容器（对照 screens-widget.jsx Critters 组件）
/// 随机飞入 → 停在植物旁 → 飞走，间隔 10-23 秒
private struct CrittersOverlay: View {
    @State private var visible = false
    @State private var kind: CritterKind = .bee
    @State private var pos: CGPoint = .zero
    @State private var opacity: Double = 0
    @State private var rotation: Double = 0
    @State private var flipX: Bool = false
    @State private var timer: Timer? = nil

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                if visible {
                    critterContent()
                        .scaleEffect(x: flipX ? -1 : 1, y: 1)
                        .rotationEffect(.degrees(rotation))
                        .position(pos)
                        .opacity(opacity)
                }
            }
            .onAppear { schedule(size: geo.size, delay: 3 + Double.random(in: 0...5)) }
            .onDisappear { timer?.invalidate(); timer = nil }
        }
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private func critterContent() -> some View {
        switch kind {
        case .bee:       BeeShape()
        case .butterfly: ButterflyShape()
        case .bird:      BirdShape()
        }
    }

    private func schedule(size: CGSize, delay: TimeInterval) {
        timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in
            fly(in: size)
        }
    }

    private func fly(in size: CGSize) {
        kind = CritterKind.next()
        let fromLeft = Bool.random()
        flipX = !fromLeft
        let dir: Double = fromLeft ? 1 : -1
        let startX: CGFloat = fromLeft ? -25 : size.width + 25
        let endX:   CGFloat = fromLeft ? size.width + 25 : -25
        let landX = size.width  * CGFloat.random(in: 0.28...0.72)
        let landY = size.height * CGFloat.random(in: 0.44...0.62)

        pos      = CGPoint(x: startX, y: size.height * 0.2)
        rotation = dir * 10
        opacity  = 0
        visible  = true

        // 飞入（3.5s）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.easeInOut(duration: 3.5)) {
                pos      = CGPoint(x: landX, y: landY)
                opacity  = 1
                rotation = 0
            }
        }
        // 飞走（2s）
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.5) {
            withAnimation(.easeIn(duration: 2.0)) {
                pos      = CGPoint(x: endX, y: size.height * 0.14)
                opacity  = 0
                rotation = dir * 6
            }
        }
        // 重置，安排下一只（10-23s 的间隔）
        DispatchQueue.main.asyncAfter(deadline: .now() + 9.0) {
            visible = false
            schedule(size: size, delay: 10 + Double.random(in: 0...13))
        }
    }
}

/// 雨丝特效（静态，对照 WeatherFX rain）
private struct RainFX: View {
    var body: some View {
        Canvas { ctx, size in
            ctx.opacity = 0.35
            let rc = Color(hex:"#78a0d2", opacity: 0.45)
            let step: CGFloat = 53
            var x: CGFloat = 0
            var idx = 0
            while x < size.width + size.height * 0.3 {
                let h = size.height * (0.16 + CGFloat(idx % 3) * 0.06)
                var path = Path()
                let startX = x - size.height * 0.22
                let endX = startX + size.height * 0.22
                path.move(to: CGPoint(x: startX, y: 0))
                path.addLine(to: CGPoint(x: endX, y: h / 1))
                ctx.stroke(path, with: .color(rc), lineWidth: 1.2)
                x += step
                idx += 1
            }
        }
        .rotationEffect(.degrees(12))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .allowsHitTesting(false)
    }
}
