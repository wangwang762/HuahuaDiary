//
//  Colors.swift
//  HuahuaDiary
//
//  Design tokens — color palette
//  Source of truth: design_handoff_huahua_diary/styles.css :root
//

import SwiftUI

extension Color {
    init(hex: String, opacity: Double = 1.0) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        var v: UInt64 = 0
        Scanner(string: s).scanHexInt64(&v)
        let r = Double((v >> 16) & 0xff) / 255.0
        let g = Double((v >> 8) & 0xff) / 255.0
        let b = Double(v & 0xff) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }
}

enum HHColor {
    // MARK: - Paper / surface
    static let paper       = Color(hex: "#F1EADB")
    static let paperDeep   = Color(hex: "#E8DDC8")
    static let paperCard   = Color(hex: "#FBF6EB")
    static let paperWarm   = Color(hex: "#F5EFE2")
    static let glass       = Color(hex: "#FBF6EB", opacity: 0.86)
    static let glassStrong = Color(hex: "#FBF6EB", opacity: 0.94)

    // MARK: - Ink (typography)
    static let ink      = Color(hex: "#221F18")
    static let inkSoft  = Color(hex: "#6B6256")
    static let inkFaint = Color(hex: "#A99E8B")
    static let hairline = Color(hex: "#221F18", opacity: 0.14)
    static let rule     = Color(hex: "#221F18", opacity: 0.82)

    // MARK: - Pine green (primary brand)
    static let green       = Color(hex: "#2C6147")
    static let greenDeep   = Color(hex: "#1E4632")
    static let greenForest = Color(hex: "#163525")
    static let greenNight  = Color(hex: "#0C2014")
    static let greenSoft   = Color(hex: "#DBE5D2")
    static let greenBubble = Color(hex: "#E7EEDF")

    static let greenGradient = LinearGradient(
        colors: [Color(hex: "#357355"), Color(hex: "#234B36")],
        startPoint: .top, endPoint: .bottom
    )

    // MARK: - Acid lime (editorial highlight)
    static let lime     = Color(hex: "#E6E24F")
    static let limeDeep = Color(hex: "#C7C32C")
    static let limeSoft = Color(hex: "#F0EE9E")

    // MARK: - Warm accents
    static let coral     = Color(hex: "#C8553C")
    static let coralSoft = Color(hex: "#E0917E")
    static let gold      = Color(hex: "#D7A23F")
    static let goldLight = Color(hex: "#F0D58A")
    static let terra     = Color(hex: "#BE7B33")

    static let goldGradient = LinearGradient(
        colors: [Color(hex: "#F0D58A"), Color(hex: "#D7A23F")],
        startPoint: .top, endPoint: .bottom
    )

    // MARK: - Canvas backgrounds
    static let canvasGradient = LinearGradient(
        stops: [
            .init(color: Color(hex: "#F5EFE2"), location: 0.0),
            .init(color: paper, location: 0.30),
            .init(color: paper, location: 1.0)
        ],
        startPoint: .top, endPoint: .bottom
    )

    static let stageBackground = RadialGradient(
        colors: [Color(hex: "#F1E4D0"), Color(hex: "#E4D4BD"), Color(hex: "#DBC8AC")],
        center: .top,
        startRadius: 20, endRadius: 700
    )
}

// MARK: - Palette identifier (Codable — used for persistence)
enum PaletteKind: String, Codable, Hashable, CaseIterable {
    case cactus, succulentPink, succulentGreen, pothos, monstera, sunflower, unknown

    var palette: PlantPalette {
        switch self {
        case .cactus:        .cactus
        case .succulentPink: .succulentPink
        case .succulentGreen:.succulentGreen
        case .pothos:        .pothos
        case .monstera:      .monstera
        case .sunflower:     .sunflower
        case .unknown:       .unknown
        }
    }
}

// MARK: - Plant accent palettes (per species — from data.js)
struct PlantPalette: Equatable, Hashable {
    let accent: Color
    let deep: Color
    let bubble: Color
    let soft: Color
    let pot: Color

    static let cactus = PlantPalette(
        accent: Color(hex: "#0B7A37"), deep: Color(hex: "#0B5E2C"),
        bubble: Color(hex: "#E7F1E4"), soft: Color(hex: "#DCEBDB"),
        pot: Color(hex: "#C98A3C")
    )
    static let succulentPink = PlantPalette(
        accent: Color(hex: "#C25B7A"), deep: Color(hex: "#9E3E5C"),
        bubble: Color(hex: "#F7E6EC"), soft: Color(hex: "#F2D9E1"),
        pot: Color(hex: "#C98A3C")
    )
    static let succulentGreen = PlantPalette(
        accent: Color(hex: "#3F9E7A"), deep: Color(hex: "#2C7659"),
        bubble: Color(hex: "#E2F1EA"), soft: Color(hex: "#D6ECE0"),
        pot: Color(hex: "#C98A3C")
    )
    static let pothos = PlantPalette(
        accent: Color(hex: "#5A9E2F"), deep: Color(hex: "#437821"),
        bubble: Color(hex: "#EAF3DD"), soft: Color(hex: "#E0EFCF"),
        pot: Color(hex: "#C98A3C")
    )
    static let monstera = PlantPalette(
        accent: Color(hex: "#1F7A6E"), deep: Color(hex: "#145A50"),
        bubble: Color(hex: "#DCEFEC"), soft: Color(hex: "#CFE8E3"),
        pot: Color(hex: "#C98A3C")
    )
    static let sunflower = PlantPalette(
        accent: Color(hex: "#C9971E"), deep: Color(hex: "#A2790F"),
        bubble: Color(hex: "#FBEFCF"), soft: Color(hex: "#F7E6B8"),
        pot: Color(hex: "#C98A3C")
    )
    static let unknown = PlantPalette(
        accent: Color(hex: "#6E7B62"), deep: Color(hex: "#4E5945"),
        bubble: Color(hex: "#ECEFE4"), soft: Color(hex: "#E2E7D6"),
        pot: Color(hex: "#C98A3C")
    )
}
