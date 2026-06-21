//
//  ClinicCase.swift
//  HuahuaDiary
//

import SwiftUI

enum ClinicStatus: String, Hashable, Codable, CaseIterable {
    case all        // filter-only sentinel
    case recheck
    case recovering
    case healed
    case dead

    var label: String {
        switch self {
        case .all:        "全部"
        case .recheck:    "待复诊"
        case .recovering: "恢复中"
        case .healed:     "已康复"
        case .dead:       "已离开"
        }
    }

    /// Foreground tint for the badge / progress bar.
    var color: Color {
        switch self {
        case .all:        HHColor.ink
        case .recheck:    Color(hex: "#3E6B8C")
        case .recovering: HHColor.terra
        case .healed:     Color(hex: "#2C7A4B")
        case .dead:       Color(hex: "#8A7B6B")
        }
    }

    /// Background fill (low-opacity) for the badge pill.
    var background: Color {
        switch self {
        case .all:        HHColor.paperCard
        case .recheck:    Color(hex: "#3E6B8C", opacity: 0.12)
        case .recovering: Color(hex: "#C98A3C", opacity: 0.14)
        case .healed:     Color(hex: "#2C7A4B", opacity: 0.12)
        case .dead:       Color(hex: "#6E6256", opacity: 0.14)
        }
    }
}

struct ClinicCase: Identifiable, Hashable, Codable {
    let id: String
    let plantId: String
    let no: String           // "No.014"
    let date: String         // "6月7日"
    let seen: String         // "今天"
    let complaint: String
    let diagnosis: String
    let rx: String           // 医嘱
    let status: ClinicStatus
    let progress: Int        // 0…100
    let note: String

    // Identity overrides for dead patients no longer in the garden
    let patientName: String?
    let patientSpecies: String?

    // Death-only fields
    let cause: String?
    let lesson: String?
}
