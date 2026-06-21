//
//  Plant.swift
//  HuahuaDiary
//
//  Core models for a plant, its diary, care, traits.
//  Source of truth (mock): design_handoff_huahua_diary/data.js
//

import SwiftUI

// MARK: - Species shape
enum PlantShape: String, Codable, CaseIterable {
    case cactus
    case succulent
    case pothos
    case monstera
    case sunflower

    var displayName: String {
        switch self {
        case .cactus: "仙人掌"
        case .succulent: "多肉"
        case .pothos: "绿萝"
        case .monstera: "龟背竹"
        case .sunflower: "向日葵"
        }
    }

    /// 摆动旋转锚点：Y 轴比例（从顶部起，1.0 = 最底部）
    /// 对照 screens-widget.jsx PlantCut soilFraction
    var soilFraction: Double {
        switch self {
        case .cactus:   0.72   // 花盆约占高度 28%
        case .succulent: 0.65
        case .pothos:   0.60
        case .monstera: 0.62
        case .sunflower: 0.55
        }
    }
}

// MARK: - Status tone
enum StatusTone: String, Codable {
    case good
    case warn
}

// MARK: - Self-care tip icon
enum CareTipIcon: String, Codable {
    case drop
    case sun
    case leaf
    case heart
}

struct CareTip: Identifiable, Hashable, Codable {
    let id: UUID
    let icon: CareTipIcon
    let label: String
    let text: String

    init(icon: CareTipIcon, label: String, text: String) {
        self.id = UUID()
        self.icon = icon
        self.label = label
        self.text = text
    }
}

struct SelfCare: Hashable, Codable {
    let say: String
    let tips: [CareTip]
}

// MARK: - Plant
struct Plant: Identifiable, Hashable, Codable {
    let id: String
    var name: String
    let species: String
    let shape: PlantShape
    let paletteKind: PaletteKind
    var tagsOn: [String]
    var tagsOff: [String]
    var custom: String
    var style: String
    var voice: String
    var opener: String
    var days: Int
    var mood: String
    var stars: Int
    var status: String
    var statusTone: StatusTone
    var photoId: String
    var born: String
    var diary: [DiaryEntry]
    var selfCare: SelfCare

    // Optional: marks an un-archived (newly added) plant in the onboarding flow.
    var isNew: Bool = false

    /// Derived from paletteKind — not stored separately.
    var palette: PlantPalette { paletteKind.palette }

    /// Cover crop scale per plant body proportion (tall plants ease down).
    var coverScale: CGFloat {
        switch shape {
        case .sunflower: 0.80
        case .monstera:  0.85
        case .cactus:    1.00
        case .pothos:    1.06
        case .succulent: 1.16
        }
    }

    /// 卡通透明 PNG（首页封面卡用）
    var cutoutAssetName: String {
        switch id {
        case "ciji":     return "plants/ciji-cut"
        case "tuanzi":   return "plants/tuanzi-cut"
        case "yuanyuan": return "plants/tuanzi-cut"
        case "alv":      return "plants/alv-cut"
        case "laobei":   return "plants/laobei-cut"
        case "zhaozhao": return "plants/zhaozhao-cut"
        default:         return "plants/ciji-cut"
        }
    }

    /// 真实植物照片（档案详情页用）
    var photoAssetName: String {
        switch id {
        case "ciji":     return "plants/ciji"
        case "tuanzi":   return "plants/tuanzi"
        case "yuanyuan": return "plants/tuanzi"
        case "alv":      return "plants/alv"
        case "laobei":   return "plants/laobei"
        case "zhaozhao": return "plants/zhaozhao"
        default:         return "plants/ciji"
        }
    }
}
