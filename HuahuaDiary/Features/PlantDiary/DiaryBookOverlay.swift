//
//  DiaryBookOverlay.swift
//  HuahuaDiary
//
//  两档高度半浮层弹窗
//  · 把手上划 → 展开到 96%，高度实时跟随手指
//  · 把手轻下滑（展开态）→ 回到 85%
//  · 把手用力下滑 → 关闭
//  · 内容区始终可滚动（含模拟器鼠标滚轮）
//

import SwiftUI

// MARK: - 高度档位

private enum SheetDetent: Equatable {
    case compact    // 85%
    case expanded   // 96%
}

// MARK: - 外壳

struct DiaryBookOverlay: View {
    @Binding var plant: Plant?
    @Binding var visible: Bool
    let onDismiss: () -> Void

    @State private var detent: SheetDetent = .compact
    @State private var dragOffset: CGFloat = 0   // 负 = 向上拖，正 = 向下拖

    var body: some View {
        GeometryReader { geo in
            let screenH = geo.size.height
                        + geo.safeAreaInsets.top
                        + geo.safeAreaInsets.bottom

            ZStack(alignment: .bottom) {
                // ── 黑色蒙层 ──
                Color.black
                    .opacity(visible ? 0.52 : 0)
                    .ignoresSafeArea()
                    .allowsHitTesting(visible)
                    .onTapGesture { onDismiss() }
                    .animation(.easeInOut(duration: 0.22), value: visible)

                // ── 面板 ──
                if let p = plant {
                    BookPanel(
                        plant: p,
                        visible: visible,
                        detent: $detent,
                        dragOffset: $dragOffset,
                        screenHeight: screenH,
                        onDismiss: onDismiss
                    )
                }
            }
        }
        .onChange(of: visible) { _, isVisible in
            if isVisible {
                detent = .compact
                dragOffset = 0
            }
        }
    }
}

// MARK: - 面板主体

private struct BookPanel: View {
    let plant: Plant
    let visible: Bool
    @Binding var detent: SheetDetent
    @Binding var dragOffset: CGFloat
    let screenHeight: CGFloat
    let onDismiss: () -> Void

    @Environment(AppState.self) private var app

    // 档位基准高度
    private var baseHeight: CGFloat {
        switch detent {
        case .compact:  screenHeight * 0.85
        case .expanded: screenHeight * 0.96
        }
    }

    // 实时高度：向上拖时面板跟手增高，向下拖时保持基准（用 offset 表现）
    private var liveHeight: CGFloat {
        if dragOffset < 0 {
            // 向上拖 → 高度增长，上限 96%
            let growth = min(-dragOffset, screenHeight * 0.12)
            return min(screenHeight * 0.96, baseHeight + growth)
        }
        return baseHeight
    }

    // 实时 Y 偏移：向下拖时面板随手下移（弹性阻尼），关闭时滑出
    private var liveYOffset: CGFloat {
        guard visible else { return baseHeight + 30 }
        if dragOffset > 0 {
            // 向下拖 — 弹性阻尼，拖得越多阻力越大
            return pow(dragOffset * 0.6, 0.82)
        }
        return 0
    }

    var body: some View {
        VStack(spacing: 0) {
            // ── 把手行（手势区域）──
            handleRow

            // ── 日记内容（始终可滚动）──
            PlantDiaryView(
                plant: plant,
                isSheetMode: true,
                onDiagnoseOverride: {
                    withAnimation(HHMotion.snap) { app.currentTab = .doctor }
                }
            )
        }
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: 22, bottomLeadingRadius: 0,
                bottomTrailingRadius: 0, topTrailingRadius: 22,
                style: .continuous
            )
            .fill(HHColor.paper)
            .ignoresSafeArea(edges: .bottom)
        )
        .overlay(alignment: .top) {
            UnevenRoundedRectangle(
                topLeadingRadius: 22, bottomLeadingRadius: 0,
                bottomTrailingRadius: 0, topTrailingRadius: 22,
                style: .continuous
            )
            .strokeBorder(HHColor.hairline, lineWidth: 1)
            .frame(height: 52)
        }
        .frame(maxWidth: .infinity)
        .frame(height: liveHeight)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 22, bottomLeadingRadius: 0,
                bottomTrailingRadius: 0, topTrailingRadius: 22,
                style: .continuous
            )
        )
        // 入场书本翻开动效
        .scaleEffect(visible ? 1.0 : 0.94, anchor: .init(x: 0.5, y: 1.0))
        .opacity(visible ? 1.0 : 0)
        .offset(y: liveYOffset)
        // 档位切换弹簧
        .animation(.spring(response: 0.42, dampingFraction: 0.82), value: detent)
        // 入/出场弹簧
        .animation(.spring(response: 0.46, dampingFraction: 0.80), value: visible)
        // 拖动高度和偏移实时响应
        .animation(.interactiveSpring(response: 0.22, dampingFraction: 0.90), value: dragOffset)
    }

    // MARK: 把手行
    private var handleRow: some View {
        ZStack {
            // 把手手势覆盖整行
            Color.clear
                .contentShape(Rectangle())
                .gesture(handleDragGesture)

            // 把手胶囊：展开态略深
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(detent == .expanded ? HHColor.inkFaint : HHColor.hairline)
                .frame(width: 38, height: 5)
                .animation(.easeInOut(duration: 0.18), value: detent)

            // 右侧成长小报
            HStack {
                Spacer()
                Button { /* TODO */ } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 13, weight: .semibold))
                        Text("成长小报")
                            .font(HHFont.ui(13, weight: .semibold))
                            .lineLimit(1)
                            .fixedSize()
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 13)
                    .padding(.vertical, 7)
                    .background(
                        Capsule()
                            .fill(plant.palette.deep)
                            .shadow(color: plant.palette.accent.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 52)
    }

    // MARK: 把手拖动手势
    private var handleDragGesture: some Gesture {
        DragGesture(minimumDistance: 8, coordinateSpace: .local)
            .onChanged { g in
                dragOffset = g.translation.height
            }
            .onEnded { g in
                let dy = g.translation.height
                let vy = g.predictedEndTranslation.height
                dragOffset = 0

                switch detent {
                case .compact:
                    if dy < -40 || vy < -180 {
                        // 上滑 → 展开
                        withAnimation(.spring(response: 0.40, dampingFraction: 0.78)) {
                            detent = .expanded
                        }
                    } else if dy > 100 || vy > 260 {
                        // 下滑 → 关闭
                        onDismiss()
                    }
                    // 其余：弹回（dragOffset = 0 触发动画）

                case .expanded:
                    if dy > 220 || vy > 550 {
                        // 用力下滑 → 直接关闭
                        onDismiss()
                    } else if dy > 60 || vy > 160 {
                        // 轻下滑 → 回到 85%
                        withAnimation(.spring(response: 0.40, dampingFraction: 0.82)) {
                            detent = .compact
                        }
                    }
                    // 其余：弹回
                }
            }
    }
}
