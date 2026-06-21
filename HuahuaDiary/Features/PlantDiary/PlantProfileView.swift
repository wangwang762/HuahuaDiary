//
//  PlantProfileView.swift
//  HuahuaDiary
//
//  性格设置 — 修改植物昵称、口头禅、标签等
//

import SwiftUI

struct PlantProfileView: View {
    let plant: Plant

    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss

    // 编辑缓冲
    @State private var name: String
    @State private var voice: String
    @State private var opener: String
    @State private var custom: String
    @State private var activeTagNames: Set<String>

    /// 全部标签（on + off 合并）
    private var allTags: [String] { plant.tagsOn + plant.tagsOff }

    private var hasChanges: Bool {
        name != plant.name ||
        voice != plant.voice ||
        opener != plant.opener ||
        custom != plant.custom ||
        activeTagNames != Set(plant.tagsOn)
    }

    init(plant: Plant) {
        self.plant = plant
        _name = State(initialValue: plant.name)
        _voice = State(initialValue: plant.voice)
        _opener = State(initialValue: plant.opener)
        _custom = State(initialValue: plant.custom)
        _activeTagNames = State(initialValue: Set(plant.tagsOn))
    }

    // UIKit 状态栏高度
    private var statusBarHeight: CGFloat {
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
            .statusBarManager?.statusBarFrame.height ?? 54
    }
    private let navBarHeight: CGFloat = 52

    var body: some View {
        ZStack(alignment: .top) {
            // 背景
            LinearGradient(
                stops: [
                    .init(color: plant.palette.soft.opacity(0.45), location: 0),
                    .init(color: HHColor.paper, location: 0.22)
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            // 内容
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Color.clear.frame(height: statusBarHeight + navBarHeight)

                    // 植物头像
                    PlantAvatarView(plant: plant, size: 64)
                        .padding(.top, 12)

                    // 名字
                    fieldSection(title: "昵称") {
                        singleLineField($name, placeholder: "给它起个名字")
                    }

                    // 口头禅
                    fieldSection(title: "口头禅") {
                        multiLineField($voice, placeholder: "它最常说的一句话…")
                    }

                    // 开场白
                    fieldSection(title: "开场白") {
                        multiLineField($opener, placeholder: "打开 App 时它说的第一句话…")
                    }

                    // 性格标签
                    fieldSection(title: "性格标签") {
                        tagGrid
                    }

                    // 养护备忘
                    fieldSection(title: "养护备忘") {
                        multiLineField($custom, placeholder: "它的特别习惯、注意事项…")
                    }

                    Color.clear.frame(height: 48)
                }
                .padding(.horizontal, 20)
            }

            // NavBar
            VStack(spacing: 0) {
                Color.clear.frame(height: statusBarHeight)
                navBar
            }
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - NavBar

    private var navBar: some View {
        HStack {
            Button { dismiss() } label: {
                HStack(spacing: 2) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                    Text("返回")
                        .font(HHFont.journal(15))
                }
                .foregroundStyle(HHColor.inkSoft)
            }
            .buttonStyle(.plain)

            Spacer()

            Text("性格设置")
                .font(HHFont.journal(16, weight: .semibold))
                .foregroundStyle(HHColor.ink)

            Spacer()

            Button {
                saveChanges()
            } label: {
                Text("保存")
                    .font(HHFont.ui(15, weight: .semibold))
                    .foregroundStyle(hasChanges ? plant.palette.deep : HHColor.inkFaint)
            }
            .buttonStyle(.plain)
            .disabled(!hasChanges)
        }
        .padding(.horizontal, 16)
        .frame(height: navBarHeight)
    }

    // MARK: - 通用 Section 容器

    @ViewBuilder
    private func fieldSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(HHFont.ui(12, weight: .bold))
                .foregroundStyle(plant.palette.deep.opacity(0.75))
                .padding(.leading, 2)

            content()
        }
        .padding(.top, 22)
    }

    // MARK: - 单行文本框

    private func singleLineField(_ binding: Binding<String>, placeholder: String) -> some View {
        TextField(placeholder, text: binding)
            .font(HHFont.journal(16))
            .foregroundStyle(HHColor.ink)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(fieldBackground)
    }

    // MARK: - 多行文本框

    private func multiLineField(_ binding: Binding<String>, placeholder: String) -> some View {
        ZStack(alignment: .topLeading) {
            if binding.wrappedValue.isEmpty {
                Text(placeholder)
                    .font(HHFont.journal(15))
                    .foregroundStyle(HHColor.inkFaint)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .allowsHitTesting(false)
            }
            TextEditor(text: binding)
                .font(HHFont.journal(15))
                .foregroundStyle(HHColor.ink)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 80)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
        }
        .background(fieldBackground)
    }

    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: HHRadius.lg, style: .continuous)
            .fill(HHColor.paperCard)
            .overlay(
                RoundedRectangle(cornerRadius: HHRadius.lg, style: .continuous)
                    .strokeBorder(HHColor.hairline, lineWidth: 1)
            )
    }

    // MARK: - 标签网格

    private var tagGrid: some View {
        FlowLayout(spacing: 8) {
            ForEach(allTags, id: \.self) { tag in
                let isOn = activeTagNames.contains(tag)
                Button {
                    if isOn { activeTagNames.remove(tag) }
                    else     { activeTagNames.insert(tag) }
                } label: {
                    Text(tag)
                        .font(HHFont.ui(13, weight: isOn ? .semibold : .regular))
                        .foregroundStyle(isOn ? plant.palette.deep : HHColor.inkFaint)
                        .padding(.horizontal, 13)
                        .padding(.vertical, 7)
                        .background(
                            Capsule()
                                .fill(isOn ? plant.palette.bubble : HHColor.paperCard)
                                .overlay(
                                    Capsule().strokeBorder(
                                        isOn ? plant.palette.accent.opacity(0.5) : HHColor.hairline,
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

    // MARK: - 保存

    private func saveChanges() {
        guard let idx = app.plants.firstIndex(where: { $0.id == plant.id }) else { return }
        app.plants[idx].name = name
        app.plants[idx].voice = voice
        app.plants[idx].opener = opener
        app.plants[idx].custom = custom

        let newOnTags = allTags.filter { activeTagNames.contains($0) }
        let newOffTags = allTags.filter { !activeTagNames.contains($0) }
        app.plants[idx].tagsOn = newOnTags
        app.plants[idx].tagsOff = newOffTags

        app.save()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        dismiss()
    }
}

// MARK: - 自动换行布局 (Flow Layout)

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
                rowWidth = 0
                rowHeight = 0
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
                x = bounds.minX
                rowHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PlantProfileView(plant: MockData.ciji)
            .environment(AppState())
    }
}
