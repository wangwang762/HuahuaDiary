//
//  AppState.swift
//  HuahuaDiary
//
//  Observable global state — the plants, clinic cases, current tab,
//  navigation stack, and the user's tweaks (weather / title style / flourish).
//

import SwiftUI
import Observation
import Foundation

// MARK: - Tabs
enum AppTab: String, Hashable, CaseIterable {
    case diary
    case doctor
    case widget

    var label: String {
        switch self {
        case .diary: "日记"
        case .doctor: "花大夫"
        case .widget: "小组件"
        }
    }

    var sfSymbol: String {
        switch self {
        case .diary: "book.closed"
        case .doctor: "stethoscope"
        case .widget: "square.grid.2x2"
        }
    }

    var hhIcon: HHIconName {
        switch self {
        case .diary:   .book
        case .doctor:  .doctor
        case .widget:  .grid
        }
    }
}

// MARK: - Tweaks (mirrors React Tweaks panel)
enum WeatherMood: String, CaseIterable, Identifiable {
    case rain = "小雨"
    case sun = "晴"
    case cloudy = "多云"
    var id: String { rawValue }
}

// MARK: - Persistence container

private struct GardenData: Codable {
    var plants: [Plant]
    var clinicCases: [ClinicCase]
}

@Observable
final class AppState {

    // MARK: - Persistence

    private static let saveURL: URL = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("garden.json")
    }()

    // MARK: - Garden data
    var plants: [Plant]
    var clinicCases: [ClinicCase]

    // Onboarding gate (persisted in UserDefaults).
    static let onboardKey = "hh-onboarded"
    var hasOnboarded: Bool = UserDefaults.standard.bool(forKey: onboardKey)

    // Tab + navigation
    var currentTab: AppTab = .diary
    var diaryPath: [DiaryRoute] = []
    var doctorPath: [DoctorRoute] = []

    // Tweaks (live editorial controls)
    var weather: WeatherMood = .rain
    var titleStyle: AppTitleStyle = .clean
    var bgFlourish: Bool = true

    // MARK: - Init — load from disk, fall back to seed data

    init() {
        if let data = try? Data(contentsOf: Self.saveURL),
           let garden = try? JSONDecoder().decode(GardenData.self, from: data) {
            plants = garden.plants
            clinicCases = garden.clinicCases
        } else {
            plants = MockData.plants
            clinicCases = MockData.clinicCases
        }
    }

    // MARK: - Save to disk

    func save() {
        guard let data = try? JSONEncoder().encode(GardenData(plants: plants, clinicCases: clinicCases)) else { return }
        try? data.write(to: Self.saveURL, options: .atomic)
    }

    // MARK: - Helpers

    func plant(by id: String) -> Plant? { plants.first { $0.id == id } }

    func updateOnboarded(_ v: Bool) {
        hasOnboarded = v
        UserDefaults.standard.set(v, forKey: Self.onboardKey)
    }

    /// 新增或替换一盆植物，并立即保存
    func upsert(_ plant: Plant) {
        if let idx = plants.firstIndex(where: { $0.id == plant.id }) {
            plants[idx] = plant
        } else {
            plants.append(plant)
        }
        save()
    }

    /// 往某盆植物追加一条日记，并立即保存
    func appendDiary(_ entry: DiaryEntry, to plantId: String) {
        guard let idx = plants.firstIndex(where: { $0.id == plantId }) else { return }
        plants[idx].diary.insert(entry, at: 0)
        save()
    }
}

// MARK: - Navigation routes
enum DiaryRoute: Hashable {
    case plantDiary(plantId: String)
    case diaryEntry(plantId: String, entryId: String)
    case capture(plantId: String, intake: Bool)
    case plantChat(plantId: String)
    case profile(plantId: String)
}

enum DoctorRoute: Hashable {
    case doctorChat(plantId: String)
    case capture(plantId: String, intake: Bool)
}
