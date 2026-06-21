//
//  ContentView.swift
//  HuahuaDiary
//
//  Root composition — hosts the three tabs over a single paper canvas
//  with a floating custom BottomNavBar.
//

import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var app

    var body: some View {
        @Bindable var app = app

        ZStack(alignment: .bottom) {
            PaperCanvas()

            ZStack {
                switch app.currentTab {
                case .diary:  DiaryTabView()
                case .doctor: DoctorTabView()
                case .widget: WidgetTabView()
                }
            }
            .transition(.opacity)
            .animation(HHMotion.smooth, value: app.currentTab)

            // 进入子页（拍照/问诊）时隐藏底部导航栏
            if app.doctorPath.isEmpty && app.diaryPath.isEmpty {
                BottomNavBar(tab: $app.currentTab)
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Tab containers (each owns its own navigation stack)

struct DiaryTabView: View {
    @Environment(AppState.self) private var app
    var body: some View {
        @Bindable var app = app
        NavigationStack(path: $app.diaryPath) {
            HomeView()
                .navigationDestination(for: DiaryRoute.self) { route in
                    switch route {
                    case .plantDiary(let id):
                        if let p = app.plant(by: id) { PlantDiaryView(plant: p) }
                    case .diaryEntry(let plantId, let entryId):
                        if let p = app.plant(by: plantId),
                           let e = p.diary.first(where: { $0.id == entryId }) {
                            DiaryEntryView(plant: p, entry: e)
                        }
                    case .capture(let plantId, _):
                        if let p = app.plant(by: plantId) {
                            CaptureView(plant: p, isIntake: false)
                        }
                    case .plantChat(let plantId):
                        if let p = app.plant(by: plantId) { PlantChatView(plant: p) }
                    case .profile(let plantId):
                        if let p = app.plant(by: plantId) { PlantProfileView(plant: p) }
                    }
                }
        }
        .background(Color.clear)
        .scrollContentBackground(.hidden)
    }
}

struct DoctorTabView: View {
    @Environment(AppState.self) private var app
    var body: some View {
        @Bindable var app = app
        let _ = app.doctorPath   // 强制 @Observable 追踪此属性，确保路径变化时重渲染
        NavigationStack(path: $app.doctorPath) {
            DoctorHomeView()
                .navigationDestination(for: DoctorRoute.self) { route in
                    switch route {
                    case .doctorChat(let plantId):
                        let p = app.plant(by: plantId) ?? MockData.unknownPlant
                        DoctorChatView(plant: p)
                    case .capture(let plantId, let intake):
                        let p = intake
                            ? (app.plants.first ?? MockData.ciji)
                            : (app.plant(by: plantId) ?? MockData.ciji)
                        CaptureView(plant: p, isIntake: intake)
                    }
                }
        }
        .background(Color.clear)
    }
}

struct WidgetTabView: View {
    var body: some View {
        WidgetStylesView()
    }
}


#Preview {
    RootView()
        .environment(AppState())
}
