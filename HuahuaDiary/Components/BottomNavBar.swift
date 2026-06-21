//
//  BottomNavBar.swift
//  HuahuaDiary
//
//  Custom 3-tab pill nav floating over the canvas with a gradient fade backdrop.
//  Mirrors components.jsx BottomNav.
//

import SwiftUI

struct BottomNavBar: View {
    @Binding var tab: AppTab

    private var bottomInset: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.bottom ?? 34
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // 渐变遮罩，让内容滚动到导航栏下面时不突兀
            LinearGradient(
                stops: [
                    .init(color: HHColor.paper.opacity(0), location: 0.0),
                    .init(color: HHColor.paper.opacity(0.95), location: 0.65)
                ],
                startPoint: .top, endPoint: .bottom
            )
            .frame(height: bottomInset + 90)
            .allowsHitTesting(false)

            HStack(spacing: 4) {
                ForEach(AppTab.allCases, id: \.self) { item in
                    NavPill(item: item, active: tab == item) {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(HHMotion.snap) { tab = item }
                    }
                }
            }
            .padding(5)
            .background(
                Capsule(style: .continuous)
                    .fill(HHColor.paperCard)
                    .overlay(Capsule().strokeBorder(HHColor.hairline, lineWidth: 1))
            )
            .hhShadow(.sh2)
            // 贴着 Home 指示条上方 + 8pt 呼吸空间
            .padding(.bottom, bottomInset + 8)
        }
    }
}

private struct NavPill: View {
    let item: AppTab
    let active: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 7) {
                HHIcon(
                    name: item.hhIcon,
                    size: 20,
                    color: active ? Color.white : HHColor.inkFaint,
                    strokeWidth: active ? 2.0 : 1.7
                )
                if active {
                    Text(item.label)
                        .font(HHFont.ui(13.5, weight: .semibold))
                        .foregroundStyle(.white)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, active ? 16 : 13)
            .padding(.vertical, 9)
            .frame(minWidth: active ? nil : 44)
            .background(
                Capsule(style: .continuous)
                    .fill(active ? AnyShapeStyle(HHColor.green) : AnyShapeStyle(Color.clear))
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.label)
    }
}
