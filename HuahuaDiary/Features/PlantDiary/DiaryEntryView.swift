//
//  DiaryEntryView.swift
//  HuahuaDiary
//
//  日记详情页 — 全屏展示一篇日记内容
//

import SwiftUI

struct DiaryEntryView: View {
    let plant: Plant
    let entry: DiaryEntry

    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss

    @State private var showDeleteConfirm = false

    /// UIKit 拿到的真实状态栏高度
    private var statusBarHeight: CGFloat {
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
            .statusBarManager?.statusBarFrame.height ?? 54
    }
    private let navBarHeight: CGFloat = 52

    var body: some View {
        ZStack(alignment: .top) {
            // 背景渐变
            LinearGradient(
                stops: [
                    .init(color: plant.palette.soft.opacity(0.5), location: 0),
                    .init(color: HHColor.paper, location: 0.28)
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            // 滚动内容
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // navBar 占位
                    Color.clear.frame(height: statusBarHeight + navBarHeight)

                    // 日期 / 天气 / 心情
                    metaRow
                        .padding(.horizontal, 24)
                        .padding(.top, 6)

                    // 照片（如果有）
                    if entry.photo != nil {
                        polaroidFrame
                            .padding(.top, 20)
                    }

                    // 正文
                    if !entry.quote.isEmpty {
                        JournalText(
                            segments: entry.quote,
                            size: 18,
                            lineSpacing: 6,
                            color: HHColor.ink
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                    }

                    // 植物气泡
                    plantBubble
                        .padding(.horizontal, 24)
                        .padding(.top, 18)

                    // 星星
                    starsRow
                        .padding(.top, 16)

                    // 诊断专属区（如果是 diagnosis 类型）
                    if entry.kind == .diagnosis {
                        diagnosisSection
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                    }

                    // 删除按钮
                    if entry.type != .born {
                        deleteButton
                            .padding(.top, 40)
                            .padding(.bottom, 60)
                    } else {
                        Color.clear.frame(height: 60)
                    }
                }
            }

            // NavBar 固定在顶部
            VStack(spacing: 0) {
                Color.clear.frame(height: statusBarHeight)
                navBar
            }
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .navigationBar)
        .confirmationDialog("删除这篇日记？", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("删除", role: .destructive) { deleteEntry() }
            Button("取消", role: .cancel) {}
        } message: {
            Text("删除后无法恢复。")
        }
    }

    // MARK: - NavBar

    private var navBar: some View {
        HStack {
            Button { dismiss() } label: {
                HStack(spacing: 2) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                    Text("日记")
                        .font(HHFont.journal(15))
                }
                .foregroundStyle(HHColor.inkSoft)
            }
            .buttonStyle(.plain)

            Spacer()

            Text("\(plant.name) · \(entry.date)")
                .font(HHFont.journal(15, weight: .semibold))
                .foregroundStyle(HHColor.ink)

            Spacer()

            Color.clear.frame(width: 60)
        }
        .padding(.horizontal, 16)
        .frame(height: navBarHeight)
    }

    // MARK: - 日期 / 天气 / 心情

    private var metaRow: some View {
        HStack(spacing: 8) {
            Text(entry.day)
                .font(HHFont.ui(13, weight: .semibold))
                .foregroundStyle(HHColor.inkSoft)

            Text(entry.date)
                .font(HHFont.num(13))
                .foregroundStyle(HHColor.inkFaint)

            Text("· \(entry.weather)")
                .font(HHFont.ui(13))
                .foregroundStyle(HHColor.inkFaint)

            Spacer()

            Text(entry.mood)
                .font(HHFont.ui(11))
                .foregroundStyle(plant.palette.deep)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Capsule().fill(plant.palette.bubble))
        }
    }

    // MARK: - 宝丽来相框

    private var polaroidFrame: some View {
        VStack(spacing: 0) {
            Image(plant.photoAssetName)
                .resizable()
                .scaledToFill()
                .frame(width: 220, height: 260)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))

            Text("\(plant.name) · \(entry.date)")
                .font(HHFont.journal(15))
                .foregroundStyle(HHColor.inkSoft)
                .padding(.top, 6)
        }
        .padding(10)
        .background(Color.white)
        .shadow(color: .black.opacity(0.12), radius: 14, x: 0, y: 6)
        .rotationEffect(.degrees(-1.5))
        .frame(maxWidth: .infinity)
    }

    // MARK: - 植物气泡

    private var plantBubble: some View {
        HStack(alignment: .top, spacing: 9) {
            PlantAvatarView(plant: plant, size: 32)

            Text(entry.voice)
                .font(HHFont.journal(15))
                .foregroundStyle(HHColor.ink)
                .lineSpacing(4)
                .padding(.horizontal, 13)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(plant.palette.bubble)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(plant.palette.accent.opacity(0.13), lineWidth: 1)
                        )
                )

            Spacer()
        }
    }

    // MARK: - 星星

    private var starsRow: some View {
        HStack(spacing: 4) {
            ForEach(1...5, id: \.self) { i in
                Image(systemName: i <= entry.stars ? "star.fill" : "star")
                    .font(.system(size: 14))
                    .foregroundStyle(i <= entry.stars ? plant.palette.accent : HHColor.inkFaint.opacity(0.4))
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: - 诊断区

    private var diagnosisSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let symptom = entry.symptom {
                diagRow(label: "症状", text: symptom, color: HHColor.terra)
            }
            if let conclusion = entry.conclusion {
                diagRow(label: "诊断", text: conclusion, color: plant.palette.deep)
            }
            if let plan = entry.plan {
                diagRow(label: "医嘱", text: plan, color: HHColor.greenDeep)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: HHRadius.xl, style: .continuous)
                .fill(HHColor.paperCard)
                .overlay(
                    RoundedRectangle(cornerRadius: HHRadius.xl, style: .continuous)
                        .strokeBorder(HHColor.hairline, lineWidth: 1)
                )
        )
    }

    private func diagRow(label: String, text: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(HHFont.ui(11, weight: .bold))
                .foregroundStyle(color.opacity(0.7))
            Text(text)
                .font(HHFont.journal(14.5))
                .foregroundStyle(HHColor.ink)
                .lineSpacing(3)
        }
    }

    // MARK: - 删除按钮

    private var deleteButton: some View {
        Button { showDeleteConfirm = true } label: {
            HStack(spacing: 6) {
                Image(systemName: "trash")
                    .font(.system(size: 13))
                Text("删除这篇日记")
                    .font(HHFont.ui(13))
            }
            .foregroundStyle(HHColor.inkFaint)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: - Delete logic

    private func deleteEntry() {
        guard let pIdx = app.plants.firstIndex(where: { $0.id == plant.id }) else { return }
        app.plants[pIdx].diary.removeAll { $0.id == entry.id }
        app.save()
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        DiaryEntryView(plant: MockData.ciji, entry: MockData.cijiDiary[0])
            .environment(AppState())
    }
}
