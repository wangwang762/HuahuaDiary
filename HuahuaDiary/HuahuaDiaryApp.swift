//
//  HuahuaDiaryApp.swift
//  HuahuaDiary
//

import SwiftUI

@main
struct HuahuaDiaryApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .preferredColorScheme(.light)
                .tint(HHColor.green)
                .onChange(of: appState.plants)      { _, _ in appState.save() }
                .onChange(of: appState.clinicCases) { _, _ in appState.save() }
        }
    }
}
