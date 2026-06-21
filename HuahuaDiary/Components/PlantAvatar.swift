//
//  PlantAvatar.swift
//  HuahuaDiary
//
//  Circular avatar with a plant sprite on its soul-color tint.
//  Mirrors components.jsx PlantAvatar.
//

import SwiftUI

struct PlantAvatar: View {
    let plant: Plant
    var size: CGFloat = 38

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tinted radial background
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.white, plant.palette.soft],
                        center: UnitPoint(x: 0.3, y: 0.22),
                        startRadius: 0,
                        endRadius: size * 0.9
                    )
                )
                .overlay(
                    Circle().strokeBorder(plant.palette.accent.opacity(0.20), lineWidth: 1)
                )

            // Sprite tucked at the bottom of the circle
            PlantSprite(
                shape: plant.shape,
                color: plant.palette.deep,
                pot: plant.palette.pot,
                height: size * 0.66
            )
            .padding(.bottom, size * 0.04)
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}
