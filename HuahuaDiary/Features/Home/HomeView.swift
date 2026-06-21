//
//  HomeView.swift
//  HuahuaDiary
//
//  Tab 1 — 日记本: immersive weather header + filter pills +
//  two-column equal-height plant cover grid + adopt-new slot.
//

import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var app

    @State private var filter: HomeFilter = .all
    @State private var selectedPlant: Plant?
    @State private var sheetVisible = false
    @State private var showOnboarding = false

    enum HomeFilter: Hashable {
        case all
        case care
    }

    private var careList: [Plant] { app.plants.filter { $0.statusTone == .warn } }
    private var grid: [Plant] { filter == .care ? careList : app.plants }

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                WeatherHeader(
                    weather: app.weather,
                    titleStyle: app.titleStyle,
                    bgFlourish: app.bgFlourish
                )
                filterRow
                    .padding(.horizontal, 22)
                    .padding(.top, 16)

                LazyVGrid(columns: columns, spacing: 13) {
                    ForEach(grid) { p in
                        DiaryCoverCard(plant: p) {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            selectedPlant = p
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                                sheetVisible = true
                            }
                        }
                    }
                    AdoptNewCard {
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        showOnboarding = true
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 130)
                .animation(HHMotion.smooth, value: filter)
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(HHColor.paper)
        .scrollClipDisabled()
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showOnboarding) {
            OnboardingFlow()
                .environment(app)
        }
        // ── 日记本弹窗 ──
        .overlay {
            if selectedPlant != nil {
                DiaryBookOverlay(
                    plant: $selectedPlant,
                    visible: $sheetVisible
                ) {
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.88)) {
                        sheetVisible = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.38) {
                        selectedPlant = nil
                    }
                }
                .ignoresSafeArea()
            }
        }
    }

    // MARK: - Filter pills
    private var filterRow: some View {
        HStack(spacing: 9) {
            FilterPill(
                label: "全部", icon: .book, count: app.plants.count,
                active: filter == .all
            ) { withAnimation(HHMotion.snap) { filter = .all } }

            FilterPill(
                label: "需照料", icon: .bell, count: careList.count,
                active: filter == .care
            ) { withAnimation(HHMotion.snap) { filter = .care } }

            Spacer()
        }
    }
}

private struct FilterPill: View {
    let label: String
    let icon: HHIconName
    let count: Int
    let active: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            UISelectionFeedbackGenerator().selectionChanged()
            onTap()
        }) {
            HStack(spacing: 7) {
                HHIcon(name: icon, size: 16, color: active ? Color.white : HHColor.inkSoft,
                       strokeWidth: active ? 2.0 : 1.7)
                Text(label)
                    .font(HHFont.ui(13.5, weight: .semibold))
                    .foregroundStyle(active ? Color.white : HHColor.inkSoft)
                Text("\(count)")
                    .font(HHFont.num(12, weight: .semibold))
                    .foregroundStyle(active ? Color.white.opacity(0.78) : HHColor.inkFaint)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 9)
            .background(
                Capsule(style: .continuous)
                    .fill(active ? AnyShapeStyle(HHColor.green) : AnyShapeStyle(Color.clear))
                    .overlay(
                        Capsule(style: .continuous)
                            .strokeBorder(active ? HHColor.green : HHColor.hairline, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .pressScale(0.96)
    }
}

#Preview {
    RootView()
        .environment(AppState())
}
