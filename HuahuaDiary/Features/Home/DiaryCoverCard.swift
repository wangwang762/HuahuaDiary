//
//  DiaryCoverCard.swift
//  HuahuaDiary
//
//  Equal-height plant cover card for the Home grid.
//

import SwiftUI

struct DiaryCoverCard: View {
    let plant: Plant
    var onOpen: () -> Void

    private var latest: DiaryEntry? { plant.diary.first }

    private var coverParts: [JournalSegment] {
        if let q = latest?.quote, !q.isEmpty { return q }
        return [.plain(latest?.voice ?? "刚记下了一笔。")]
    }

    private var warn: Bool { plant.statusTone == .warn }

    var body: some View {
        Button(action: onOpen) {
            VStack(alignment: .leading, spacing: 0) {
                photoSection
                    .padding(.bottom, 10)

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(plant.name)
                        .font(HHFont.display(18, weight: .bold))
                        .foregroundStyle(HHColor.ink)
                    Text(plant.species)
                        .font(HHFont.ui(10.5))
                        .foregroundStyle(HHColor.inkFaint)
                        .lineLimit(1)
                }

                JournalText(segments: coverParts, size: 13, lineSpacing: 3, color: HHColor.inkSoft)
                    .lineLimit(2)
                    .frame(maxHeight: 40, alignment: .top)
                    .padding(.top, 7)

                Spacer(minLength: 11)

                Hairline().padding(.bottom, 9)

                HStack {
                    HStack(spacing: 4) {
                        HHIcon(name: .book, size: 12, color: plant.palette.deep, strokeWidth: 1.7)
                        Text("\(plant.diary.count)")
                            .font(HHFont.num(12, weight: .semibold))
                            .foregroundStyle(HHColor.inkSoft)
                        Text("篇日记")
                            .font(HHFont.ui(11))
                            .foregroundStyle(HHColor.inkSoft)
                    }
                    Spacer()
                    Text(plant.status)
                        .font(HHFont.ui(10.5, weight: .semibold))
                        .foregroundStyle(warn ? HHColor.terra : plant.palette.deep)
                        .lineLimit(1)
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, minHeight: 248, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: HHRadius.xl, style: .continuous)
                    .fill(HHColor.paperCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: HHRadius.xl, style: .continuous)
                            .strokeBorder(HHColor.hairline, lineWidth: 1)
                    )
            )
            .paperCardShadow()
        }
        .buttonStyle(.plain)
        .pressScale(0.97)
    }

    // MARK: - Photo section (tinted bg + plant photo)
    private var photoSection: some View {
        ZStack(alignment: .topTrailing) {
            ZStack(alignment: .bottom) {
                // 植物主题色渐变底
                LinearGradient(
                    stops: [
                        .init(color: Color(hex: "#FBF7EF"), location: 0.0),
                        .init(color: plant.palette.soft.opacity(0.4), location: 0.78),
                        .init(color: plant.palette.soft.opacity(0.66), location: 1.0)
                    ],
                    startPoint: .top, endPoint: .bottom
                )

                // 卡通透明 PNG，底部对齐
                Image(plant.cutoutAssetName)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(plant.coverScale, anchor: .bottom)
                    .frame(maxHeight: 104)
            }
            .frame(height: 108)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            if warn { WarnChip().padding(8) }
        }
    }

    // Different sway energy per species — matches CSS notes (cactus stiff, pothos rocky).
    private var swayAmp: Double {
        switch plant.shape {
        case .cactus: 1.4
        case .succulent: 2.0
        case .pothos: 4.0
        case .monstera: 2.5
        case .sunflower: 3.0
        }
    }
    private var swayDelay: Double {
        Double(abs(plant.id.hashValue) % 7) * 0.18
    }
}

// MARK: - Adopt-new empty slot (same size as cover cards)
struct AdoptNewCard: View {
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Circle()
                    .strokeBorder(HHColor.hairline, lineWidth: 1.5)
                    .frame(width: 40, height: 40)
                    .overlay(
                        HHIcon(name: .plus, size: 20, color: HHColor.inkFaint, strokeWidth: 1.5)
                    )
                Text("领养新花")
                    .font(HHFont.journal(12.5))
                    .foregroundStyle(HHColor.inkFaint)
                Text("开一本新日记")
                    .font(HHFont.journal(12.5))
                    .foregroundStyle(HHColor.inkFaint)
            }
            .frame(maxWidth: .infinity, minHeight: 248)
            .background(
                RoundedRectangle(cornerRadius: HHRadius.xl, style: .continuous)
                    .strokeBorder(HHColor.hairline, style: StrokeStyle(lineWidth: 1.5, dash: [6, 5]))
                    .background(
                        RoundedRectangle(cornerRadius: HHRadius.xl, style: .continuous)
                            .fill(Color.white.opacity(0.25))
                    )
            )
        }
        .buttonStyle(.plain)
        .pressScale(0.98)
    }
}
