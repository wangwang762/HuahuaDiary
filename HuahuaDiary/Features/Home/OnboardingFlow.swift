//
//  OnboardingFlow.swift
//  HuahuaDiary
//
//  植物建档流程 — 选品种 → 起名字 → 选标签 → 完成
//

import SwiftUI

// MARK: - 建档步骤

private enum OnboardStep: Int, CaseIterable {
    case species    // 选品种
    case name       // 起名字
    case tags       // 选性格标签
    case done       // 完成
}

// MARK: - 主视图

struct OnboardingFlow: View {
    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss

    @State private var step: OnboardStep = .species
    @State private var selectedShape: PlantShape = .succulent
    @State private var selectedPalette: PaletteKind = .succulentGreen
    @State private var plantName: String = ""
    @State private var activeTags: Set<String> = []
    @State private var finished = false

    // 所有候选标签
    private let allTags = ["软萌", "傲娇", "话唠", "安静", "元气", "治愈",
                            "怕冷", "随和", "黏人", "独立", "慢热", "毒舌"]

    // 每种形状默认 palette
    private let shapePalettes: [PlantShape: PaletteKind] = [
        .cactus:    .cactus,
        .succulent: .succulentGreen,
        .pothos:    .pothos,
        .monstera:  .monstera,
        .sunflower: .sunflower
    ]

    var body: some View {
        ZStack(alignment: .top) {
            // 背景
            LinearGradient(
                stops: [
                    .init(color: selectedPalette.palette.soft.opacity(0.55), location: 0),
                    .init(color: HHColor.paper, location: 0.30)
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
            .animation(HHMotion.smooth, value: selectedPalette)

            VStack(spacing: 0) {
                // 进度条
                progressBar
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                // 步骤内容
                Group {
                    switch step {
                    case .species: speciesStep
                    case .name:    nameStep
                    case .tags:    tagsStep
                    case .done:    doneStep
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal:   .move(edge: .leading).combined(with: .opacity)
                ))
                .animation(HHMotion.smooth, value: step)

                Spacer()

                // 底部按钮
                bottomButtons
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
            .padding(.top, 56)  // 状态栏下方

            // 关闭按钮
            closeButton
        }
        .ignoresSafeArea(edges: .top)
    }

    // MARK: - 进度条

    private var progressBar: some View {
        HStack(spacing: 6) {
            ForEach(0..<3) { i in
                Capsule()
                    .fill(i < step.rawValue
                          ? selectedPalette.palette.accent
                          : (i == step.rawValue
                             ? selectedPalette.palette.accent.opacity(0.5)
                             : HHColor.hairline))
                    .frame(height: 3)
                    .animation(HHMotion.smooth, value: step)
            }
        }
    }

    // MARK: - 关闭

    private var closeButton: some View {
        HStack {
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(HHColor.inkSoft)
                    .padding(10)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.top, 52)
    }

    // MARK: - Step 1: 选品种

    private var speciesStep: some View {
        VStack(spacing: 0) {
            stepTitle("它是什么植物？", subtitle: "选一个最接近的类型")

            VStack(spacing: 10) {
                ForEach(PlantShape.allCases, id: \.self) { shape in
                    let kind = shapePalettes[shape] ?? .succulentGreen
                    Button {
                        selectedShape = shape
                        selectedPalette = kind
                    } label: {
                        HStack(spacing: 14) {
                            Circle()
                                .fill(kind.palette.bubble)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Text(shapeEmoji(shape))
                                        .font(.system(size: 22))
                                )
                            Text(shape.displayName)
                                .font(HHFont.display(16, weight: .semibold))
                                .foregroundStyle(HHColor.ink)
                            Spacer()
                            if selectedShape == shape {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(kind.palette.accent)
                                    .font(.system(size: 20))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 13)
                        .background(
                            RoundedRectangle(cornerRadius: HHRadius.lg, style: .continuous)
                                .fill(selectedShape == shape
                                      ? kind.palette.bubble
                                      : HHColor.paperCard)
                                .overlay(
                                    RoundedRectangle(cornerRadius: HHRadius.lg, style: .continuous)
                                        .strokeBorder(
                                            selectedShape == shape ? kind.palette.accent.opacity(0.5) : HHColor.hairline,
                                            lineWidth: 1.5
                                        )
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .animation(HHMotion.smooth, value: selectedShape)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
        }
    }

    // MARK: - Step 2: 起名字

    private var nameStep: some View {
        VStack(spacing: 0) {
            stepTitle("给它起个名字", subtitle: "叫什么都行，你说了算")

            VStack(spacing: 8) {
                TextField("比如：小绿、团子…", text: $plantName)
                    .font(HHFont.journal(22))
                    .foregroundStyle(HHColor.ink)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: HHRadius.xl, style: .continuous)
                            .fill(HHColor.paperCard)
                            .overlay(
                                RoundedRectangle(cornerRadius: HHRadius.xl, style: .continuous)
                                    .strokeBorder(
                                        plantName.isEmpty ? HHColor.hairline : selectedPalette.palette.accent.opacity(0.5),
                                        lineWidth: 1.5
                                    )
                            )
                    )
                    .padding(.horizontal, 24)

                Text("名字可以之后在性格设置里随时改")
                    .font(HHFont.ui(12))
                    .foregroundStyle(HHColor.inkFaint)
            }
            .padding(.top, 20)
        }
        .onAppear {
            if plantName.isEmpty { plantName = selectedShape.displayName }
        }
    }

    // MARK: - Step 3: 选标签

    private var tagsStep: some View {
        VStack(spacing: 0) {
            stepTitle("它的性格？", subtitle: "可以多选，之后也能改")

            FlowTagSelector(
                tags: allTags,
                selected: $activeTags,
                palette: selectedPalette.palette
            )
            .padding(.horizontal, 24)
            .padding(.top, 20)
        }
    }

    // MARK: - Step 4: 完成

    private var doneStep: some View {
        VStack(spacing: 20) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [selectedPalette.palette.accent, selectedPalette.palette.deep],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(width: 72, height: 72)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.white)
                )
                .shadow(color: selectedPalette.palette.accent.opacity(0.3), radius: 16, x: 0, y: 8)

            Text("\(plantName.isEmpty ? "新植物" : plantName) 已建档！")
                .font(HHFont.journal(22, weight: .bold))
                .foregroundStyle(HHColor.ink)

            Text("在日记本里找到它，开始记录你们的故事。")
                .font(HHFont.journal(15))
                .foregroundStyle(HHColor.inkSoft)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 32)
        .padding(.top, 40)
        .onAppear { createPlant() }
    }

    // MARK: - 底部按钮

    private var bottomButtons: some View {
        Group {
            if step == .done {
                Button {
                    dismiss()
                } label: {
                    Text("去看看它")
                        .font(HHFont.ui(17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            LinearGradient(
                                colors: [selectedPalette.palette.accent, selectedPalette.palette.deep],
                                startPoint: .top, endPoint: .bottom
                            )
                            .clipShape(RoundedRectangle(cornerRadius: HHRadius.pill, style: .continuous))
                        )
                        .shadow(color: selectedPalette.palette.accent.opacity(0.28), radius: 12, x: 0, y: 6)
                }
                .buttonStyle(.plain)
                .pressScale(0.97)
            } else {
                HStack(spacing: 12) {
                    if step.rawValue > 0 {
                        Button {
                            withAnimation(HHMotion.smooth) {
                                step = OnboardStep(rawValue: step.rawValue - 1) ?? .species
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(HHColor.inkSoft)
                                .frame(width: 54, height: 54)
                                .background(
                                    RoundedRectangle(cornerRadius: HHRadius.xl, style: .continuous)
                                        .fill(HHColor.paperCard)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: HHRadius.xl, style: .continuous)
                                                .strokeBorder(HHColor.hairline, lineWidth: 1)
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                    }

                    Button {
                        withAnimation(HHMotion.smooth) {
                            step = OnboardStep(rawValue: step.rawValue + 1) ?? .done
                        }
                    } label: {
                        Text(step == .tags ? "完成建档" : "下一步")
                            .font(HHFont.ui(17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                LinearGradient(
                                    colors: [selectedPalette.palette.accent, selectedPalette.palette.deep],
                                    startPoint: .top, endPoint: .bottom
                                )
                                .clipShape(RoundedRectangle(cornerRadius: HHRadius.pill, style: .continuous))
                            )
                            .shadow(color: selectedPalette.palette.accent.opacity(0.28), radius: 12, x: 0, y: 6)
                            .opacity(step == .name && plantName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
                    }
                    .buttonStyle(.plain)
                    .pressScale(0.97)
                    .disabled(step == .name && plantName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    // MARK: - 标题组件

    private func stepTitle(_ title: String, subtitle: String) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(HHFont.journal(24, weight: .bold))
                .foregroundStyle(HHColor.ink)
            Text(subtitle)
                .font(HHFont.ui(14))
                .foregroundStyle(HHColor.inkFaint)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.top, 24)
    }

    // MARK: - 品种 emoji

    private func shapeEmoji(_ shape: PlantShape) -> String {
        switch shape {
        case .cactus:    "🌵"
        case .succulent: "🪴"
        case .pothos:    "🍃"
        case .monstera:  "🌿"
        case .sunflower: "🌻"
        }
    }

    // MARK: - 创建植物

    private func createPlant() {
        guard !finished else { return }
        finished = true

        let trimmedName = plantName.trimmingCharacters(in: .whitespaces)
        let finalName = trimmedName.isEmpty ? selectedShape.displayName : trimmedName
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        let bornDate = formatter.string(from: today)

        let onTags = Array(activeTags)
        let offTags = allTags.filter { !activeTags.contains($0) }

        let bornEntry = DiaryEntry(
            id: UUID().uuidString,
            kind: .record,
            day: "认识第 1 天",
            date: {
                let f = DateFormatter(); f.dateFormat = "M月d日"; return f.string(from: today)
            }(),
            weather: "☀️ 晴",
            mood: "初遇",
            type: .born,
            photo: nil,
            quote: [.plain("第一次见面，正式建了一份档案。")],
            voice: "你好！很高兴认识你～",
            stars: 5
        )

        let newPlant = Plant(
            id: UUID().uuidString,
            name: finalName,
            species: selectedShape.displayName,
            shape: selectedShape,
            paletteKind: selectedPalette,
            tagsOn: onTags,
            tagsOff: offTags,
            custom: "",
            style: "",
            voice: "你好！很高兴认识你～",
            opener: "你好！很高兴认识你～",
            days: 1,
            mood: "初遇",
            stars: 5,
            status: "刚来不久",
            statusTone: .good,
            photoId: "",
            born: bornDate,
            diary: [bornEntry],
            selfCare: SelfCare(say: "我刚到这里，还在适应～", tips: []),
            isNew: true
        )
        app.upsert(newPlant)
    }
}

// MARK: - 流式标签选择器

private struct FlowTagSelector: View {
    let tags: [String]
    @Binding var selected: Set<String>
    let palette: PlantPalette

    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(tags, id: \.self) { tag in
                let isOn = selected.contains(tag)
                Button {
                    if isOn { selected.remove(tag) } else { selected.insert(tag) }
                } label: {
                    Text(tag)
                        .font(HHFont.ui(14, weight: isOn ? .semibold : .regular))
                        .foregroundStyle(isOn ? palette.deep : HHColor.inkSoft)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 9)
                        .background(
                            Capsule()
                                .fill(isOn ? palette.bubble : HHColor.paperCard)
                                .overlay(
                                    Capsule().strokeBorder(
                                        isOn ? palette.accent.opacity(0.5) : HHColor.hairline,
                                        lineWidth: 1
                                    )
                                )
                        )
                }
                .buttonStyle(.plain)
                .animation(HHMotion.smooth, value: isOn)
            }
        }
    }
}

// MARK: - 自动换行布局

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? 0
        var height: CGFloat = 0
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if rowWidth + size.width > maxWidth && rowWidth > 0 {
                height += rowHeight + spacing
                rowWidth = 0; rowHeight = 0
            }
            rowWidth += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        height += rowHeight
        return CGSize(width: maxWidth, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX && x > bounds.minX {
                y += rowHeight + spacing
                x = bounds.minX; rowHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingFlow()
        .environment(AppState())
}
