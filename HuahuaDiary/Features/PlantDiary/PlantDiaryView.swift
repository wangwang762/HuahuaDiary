//
//  PlantDiaryView.swift
//  HuahuaDiary
//
//  植物档案 + 日记时间线页面（点封面卡进入）
//

import SwiftUI

// MARK: - Main view

struct PlantDiaryView: View {
    let plant: Plant
    /// true = 底部弹窗模式（不显示导航栏 back 按钮）
    var isSheetMode: Bool = false
/// 弹窗模式下由父层传入的「跳到花大夫」回调
    var onDiagnoseOverride: (() -> Void)? = nil

    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss

    @State private var filter: TimelineFilter = .all
    @State private var careOpen = false
    @State private var scrollOffset: CGFloat = 0

    // 名片高度约 170pt，超过后显示紧凑标题栏
    private var showMiniHeader: Bool { isSheetMode && scrollOffset > 155 }

    enum TimelineFilter { case all, record, diagnosis }

    private var shown: [DiaryEntry] {
        switch filter {
        case .all:       plant.diary
        case .record:    plant.diary.filter { $0.kind != .diagnosis }
        case .diagnosis: plant.diary.filter { $0.kind == .diagnosis }
        }
    }
    private var recCount: Int { plant.diary.filter { $0.kind != .diagnosis }.count }
    private var dxCount:  Int { plant.diary.filter { $0.kind == .diagnosis }.count }

    var body: some View {
        ZStack(alignment: .top) {
            scrollContent
            if showMiniHeader {
                miniHeader
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.18), value: showMiniHeader)
    }

    // MARK: 滚动主体
    private var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                if !isSheetMode {
                    navRow.padding(.horizontal, 16).padding(.top, 4)
                }

                plantIntroCard
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                SelfCareCard(plant: plant, open: $careOpen)
                    .padding(.horizontal, 20)
                    .padding(.top, 14)

                captureButton
                    .padding(.horizontal, 20)
                    .padding(.top, 14)

                timelineHeader
                    .padding(.horizontal, 22)
                    .padding(.top, 22)

                filterRow
                    .padding(.horizontal, 22)
                    .padding(.top, 10)

                DiaryTimeline(plant: plant, entries: shown) {
                    if let override = onDiagnoseOverride {
                        override()
                    } else {
                        withAnimation(HHMotion.snap) { app.currentTab = .doctor }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 120)
            }
        }
        .onScrollGeometryChange(for: CGFloat.self) { $0.contentOffset.y } action: { _, y in
            scrollOffset = y
        }
        .background(
            LinearGradient(
                stops: [
                    .init(color: plant.palette.soft.opacity(0.4), location: 0),
                    .init(color: HHColor.paper, location: 0.22)
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .ignoresSafeArea(edges: .bottom)
        .toolbar(.hidden, for: .navigationBar)
        .scrollClipDisabled(!isSheetMode)
    }

    // MARK: 紧凑标题栏（弹窗模式滚动后置顶）
    private var miniHeader: some View {
        HStack(spacing: 11) {
            PlantAvatarView(plant: plant, size: 34)

            VStack(alignment: .leading, spacing: 1) {
                Text(plant.name)
                    .font(HHFont.display(16, weight: .bold))
                    .foregroundStyle(HHColor.ink)
                Text(plant.species)
                    .font(HHFont.ui(11))
                    .foregroundStyle(HHColor.inkFaint)
            }

            Spacer()

            Text("认识第 \(plant.days) 天")
                .font(HHFont.num(12))
                .foregroundStyle(HHColor.inkFaint)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule().fill(plant.palette.bubble)
                )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .overlay(alignment: .bottom) { Hairline() }
    }

    // MARK: Nav row
    private var navRow: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                HStack(spacing: 2) {
                    HHIcon(name: .chevronRight, size: 26, color: HHColor.inkSoft, strokeWidth: 1.8)
                        .rotationEffect(.degrees(180))
                    Text("日记本")
                        .font(HHFont.journal(15))
                        .foregroundStyle(HHColor.inkSoft)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                // TODO: 生成成长小报
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 13, weight: .semibold))
                    Text("成长小报")
                        .font(HHFont.ui(13, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 13)
                .padding(.vertical, 7)
                .background(
                    Capsule()
                        .fill(plant.palette.deep)
                        .shadow(color: plant.palette.accent.opacity(0.3), radius: 8, x: 0, y: 4)
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: Plant intro card
    private var plantIntroCard: some View {
        HStack(alignment: .top, spacing: 14) {
            // 宝丽来相片
            PolaroidPhoto(plant: plant)

            // 右侧信息
            VStack(alignment: .leading, spacing: 0) {
                // 名字 + 种类 + 性格按钮
                HStack(alignment: .firstTextBaseline, spacing: 7) {
                    Text(plant.name)
                        .font(HHFont.display(25, weight: .bold))
                        .foregroundStyle(HHColor.ink)
                    Text(plant.species)
                        .font(HHFont.ui(12))
                        .foregroundStyle(HHColor.inkFaint)
                        .lineLimit(1)
                    Spacer()
                    NavigationLink(value: DiaryRoute.profile(plantId: plant.id)) {
                        HStack(spacing: 3) {
                            Image(systemName: "pencil")
                                .font(.system(size: 10))
                            Text("性格")
                                .font(HHFont.ui(11))
                        }
                        .foregroundStyle(HHColor.inkFaint)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .overlay(
                            Capsule().strokeBorder(HHColor.hairline, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }

                // 统计数字
                HStack(spacing: 14) {
                    StatColumn(n: plant.days, unit: "天", label: "认识", color: plant.palette.deep)
                    StatColumn(n: plant.diary.count, unit: "篇", label: "日记", color: plant.palette.deep)
                    StatColumn(n: plant.diary.filter { $0.photo != nil }.count + 1,
                               unit: "张", label: "拍照", color: plant.palette.deep)
                }
                .padding(.top, 9)

                // 性格标签
                FlowTags(tags: plant.tagsOn, bubble: plant.palette.bubble, deep: plant.palette.deep)
                    .padding(.top, 11)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: HHRadius.xl, style: .continuous)
                .fill(HHColor.paperCard.opacity(0.86))
                .overlay(
                    RoundedRectangle(cornerRadius: HHRadius.xl, style: .continuous)
                        .strokeBorder(HHColor.hairline, lineWidth: 1)
                )
        )
        .paperCardShadow()
    }

    // MARK: Capture button
    private var captureButton: some View {
        NavigationLink(value: DiaryRoute.capture(plantId: plant.id, intake: false)) {
            HStack(spacing: 9) {
                Image(systemName: "camera")
                    .font(.system(size: 19, weight: .semibold))
                Text("拍照记录今天")
                    .font(HHFont.ui(16.5, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                LinearGradient(
                    colors: [plant.palette.accent, plant.palette.deep],
                    startPoint: .top, endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: HHRadius.xl, style: .continuous))
                .shadow(color: plant.palette.accent.opacity(0.3), radius: 12, x: 0, y: 6)
            )
        }
        .buttonStyle(.plain)
        .pressScale(0.97)
    }

    // MARK: Timeline header
    private var timelineHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("和 \(plant.name) 的日记")
                .font(HHFont.journal(18, weight: .semibold))
                .foregroundStyle(HHColor.ink)
            Spacer()
            Text("共 \(plant.diary.count) 篇")
                .font(HHFont.ui(12.5))
                .foregroundStyle(HHColor.inkFaint)
        }
    }

    // MARK: Filter pills
    private var filterRow: some View {
        HStack(spacing: 8) {
            ForEach([
                (TimelineFilter.all, "全部", plant.diary.count),
                (.record, "记录", recCount),
                (.diagnosis, "诊断", dxCount)
            ], id: \.1) { (f, label, count) in
                let on = filter == f
                Button {
                    UISelectionFeedbackGenerator().selectionChanged()
                    withAnimation(HHMotion.snap) { filter = f }
                } label: {
                    HStack(spacing: 5) {
                        Text(label)
                            .font(HHFont.ui(13, weight: .semibold))
                            .foregroundStyle(on ? Color.white : HHColor.inkSoft)
                        Text("\(count)")
                            .font(HHFont.num(11.5, weight: .semibold))
                            .foregroundStyle(on ? Color.white.opacity(0.8) : HHColor.inkFaint)
                    }
                    .padding(.horizontal, 13)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(on ? AnyShapeStyle(plant.palette.deep) : AnyShapeStyle(Color.clear))
                            .overlay(
                                Capsule()
                                    .strokeBorder(on ? plant.palette.deep : HHColor.hairline, lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
    }
}

// MARK: - Sub-views

private struct PolaroidPhoto: View {
    let plant: Plant

    var body: some View {
        VStack(spacing: 2) {
            Image(plant.photoAssetName)
                .resizable()
                .scaledToFill()
                .frame(width: 94, height: 112)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
            Text("第 \(plant.days) 天")
                .font(HHFont.script(16))
                .foregroundStyle(HHColor.inkSoft)
        }
        .padding(6)
        .padding(.bottom, 2)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        .shadow(color: .black.opacity(0.14), radius: 6, x: 0, y: 2)
        .rotationEffect(.degrees(-2.5))
        .frame(width: 104)
        .alignmentGuide(.top) { $0[.top] }
    }
}

private struct StatColumn: View {
    let n: Int
    let unit: String
    let label: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(alignment: .lastTextBaseline, spacing: 1) {
                Text("\(n)")
                    .font(HHFont.num(18, weight: .bold))
                    .foregroundStyle(color)
                Text(unit)
                    .font(HHFont.ui(10.5))
                    .foregroundStyle(HHColor.inkFaint)
            }
            Text(label)
                .font(HHFont.ui(10.5))
                .foregroundStyle(HHColor.inkFaint)
        }
    }
}

private struct FlowTags: View {
    let tags: [String]
    let bubble: Color
    let deep: Color

    var body: some View {
        // Simple flow layout (wraps if needed)
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 50), spacing: 6)],
            alignment: .leading, spacing: 6
        ) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .font(HHFont.ui(11))
                    .foregroundStyle(deep)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 3)
                    .background(
                        Capsule().fill(bubble)
                    )
            }
        }
    }
}

// MARK: - Self-care guide card

struct SelfCareCard: View {
    let plant: Plant
    @Binding var open: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header row: avatar + say
            HStack(alignment: .top, spacing: 11) {
                PlantAvatarView(plant: plant, size: 40)
                VStack(alignment: .leading, spacing: 5) {
                    Text("怎么养我 · \(plant.species)")
                        .font(HHFont.ui(10.5, weight: .semibold))
                        .tracking(2.4)
                        .textCase(.uppercase)
                        .foregroundStyle(plant.palette.deep)
                    Text(plant.selfCare.say)
                        .font(HHFont.journal(15))
                        .foregroundStyle(HHColor.ink)
                        .lineSpacing(4)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 15)

            if open {
                Hairline().padding(.horizontal, 16)
                VStack(spacing: 12) {
                    ForEach(plant.selfCare.tips) { tip in
                        CareTipRow(tip: tip, plant: plant)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 13)
            }

            Hairline()
            Button {
                withAnimation(HHMotion.smooth) { open.toggle() }
            } label: {
                HStack(spacing: 6) {
                    HHIcon(name: .leaf, size: 15, color: plant.palette.deep, strokeWidth: 1.7)
                    Text(open ? "收起养护指南" : "展开养护指南 · \(plant.selfCare.tips.count) 条")
                        .font(HHFont.ui(12.5, weight: .semibold))
                        .foregroundStyle(plant.palette.deep)
                    HHIcon(name: .chevronRight, size: 15, color: plant.palette.deep, strokeWidth: 1.7)
                        .rotationEffect(.degrees(open ? -90 : 90))
                        .animation(HHMotion.smooth, value: open)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
            }
            .buttonStyle(.plain)
        }
        .background(
            RoundedRectangle(cornerRadius: HHRadius.xl, style: .continuous)
                .fill(HHColor.paperCard.opacity(0.86))
                .overlay(
                    RoundedRectangle(cornerRadius: HHRadius.xl, style: .continuous)
                        .strokeBorder(HHColor.hairline, lineWidth: 1)
                )
        )
        .paperCardShadow()
        .clipShape(RoundedRectangle(cornerRadius: HHRadius.xl, style: .continuous))
    }
}

private struct CareTipRow: View {
    let tip: CareTip
    let plant: Plant

    var body: some View {
        HStack(alignment: .top, spacing: 11) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(plant.palette.soft.opacity(0.55))
                .frame(width: 28, height: 28)
                .overlay(
                    HHIcon(name: tipIcon, size: 15, color: plant.palette.deep, strokeWidth: 1.7)
                )
            VStack(alignment: .leading, spacing: 1) {
                Text(tip.label)
                    .font(HHFont.ui(12, weight: .bold))
                    .foregroundStyle(plant.palette.deep)
                Text(tip.text)
                    .font(HHFont.journal(13.5))
                    .foregroundStyle(HHColor.inkSoft)
                    .lineSpacing(3)
            }
        }
    }

    private var tipIcon: HHIconName {
        switch tip.icon {
        case .drop:   .cloudRain
        case .sun:    .sun
        case .leaf:   .leaf
        case .heart:  .bell
        }
    }
}

// MARK: - Plant avatar (small circle)

struct PlantAvatarView: View {
    let plant: Plant
    var size: CGFloat = 40

    var body: some View {
        Image(plant.cutoutAssetName)
            .resizable()
            .scaledToFit()
            .frame(width: size * 0.75, height: size * 0.75)
            .frame(width: size, height: size)
            .background(plant.palette.soft.opacity(0.5))
            .clipShape(Circle())
    }
}

// MARK: - Diary timeline

struct DiaryTimeline: View {
    let plant: Plant
    let entries: [DiaryEntry]
    var onDiagnose: (() -> Void)?

    var body: some View {
        ZStack(alignment: .topLeading) {
            // 虚线轨道
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [plant.palette.soft, plant.palette.soft.opacity(0)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(width: 2)
                .padding(.leading, 14)
                .padding(.top, 26)

            VStack(spacing: 18) {
                ForEach(Array(entries.enumerated()), id: \.element.id) { i, entry in
                    NavigationLink(value: DiaryRoute.diaryEntry(plantId: plant.id, entryId: entry.id)) {
                        HStack(alignment: .top, spacing: 14) {
                            // 节点
                            TimelineNode(entry: entry, plant: plant)
                                .frame(width: 30)

                            // 卡片
                            if entry.kind == .diagnosis {
                                DiagnosisCard(entry: entry, plant: plant)
                            } else {
                                RecordCard(entry: entry, plant: plant, index: i,
                                           onDiagnose: onDiagnose)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct TimelineNode: View {
    let entry: DiaryEntry
    let plant: Plant

    var body: some View {
        ZStack {
            Circle()
                .fill(nodeBg)
                .frame(width: 30, height: 30)
            nodeIcon
        }
        .padding(.top, 6)
    }

    private var nodeBg: Color {
        switch entry.kind {
        case .diagnosis: plant.palette.deep
        case .record:
            switch entry.type {
            case .born:   plant.palette.accent
            default:      plant.palette.bubble
            }
        }
    }

    private var nodeIcon: some View {
        Group {
            switch entry.kind {
            case .diagnosis:
                HHIcon(name: .doctor, size: 14, color: .white, strokeWidth: 1.6)
            case .record:
                switch entry.type {
                case .born:
                    Image(systemName: "star.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(.white)
                case .water:
                    HHIcon(name: .cloudRain, size: 14, color: plant.palette.deep, strokeWidth: 1.6)
                case .photo:
                    Image(systemName: "camera")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(plant.palette.deep)
                default:
                    HHIcon(name: .leaf, size: 14, color: plant.palette.deep, strokeWidth: 1.6)
                }
            }
        }
    }
}

// MARK: - Diary entry cards

private struct RecordCard: View {
    let entry: DiaryEntry
    let plant: Plant
    let index: Int
    var onDiagnose: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 日期行
            HStack {
                HStack(spacing: 7) {
                    Text(entry.day)
                        .font(HHFont.ui(12.5, weight: .semibold))
                        .foregroundStyle(HHColor.inkSoft)
                    Text(entry.date)
                        .font(HHFont.num(12.5))
                        .foregroundStyle(HHColor.inkFaint)
                    Text("· \(entry.weather)")
                        .font(HHFont.ui(12.5))
                        .foregroundStyle(HHColor.inkFaint)
                }
                Spacer()
                Text(entry.mood)
                    .font(HHFont.ui(10.5))
                    .foregroundStyle(plant.palette.deep)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(plant.palette.bubble))
            }

            // 正文 + 照片
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 10) {
                    JournalText(segments: entry.quote, size: 16, lineSpacing: 4, color: HHColor.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // 植物气泡
                    HStack(alignment: .top, spacing: 7) {
                        PlantAvatarView(plant: plant, size: 26)
                        Text(entry.voice)
                            .font(HHFont.journal(14))
                            .foregroundStyle(HHColor.ink)
                            .lineSpacing(3)
                            .padding(.horizontal, 11)
                            .padding(.vertical, 7)
                            .background(
                                plant.palette.bubble
                                    .clipShape(
                                        .rect(
                                            topLeadingRadius: 3,
                                            bottomLeadingRadius: 12,
                                            bottomTrailingRadius: 12,
                                            topTrailingRadius: 12
                                        )
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(plant.palette.accent.opacity(0.13), lineWidth: 1)
                            )
                    }
                }

                // 照片（宝丽来风格）
                if entry.photo != nil {
                    TiltedPhoto(assetName: plant.photoAssetName, tilt: index % 2 == 0 ? 4 : -4)
                }
            }
            .padding(.top, 10)

            // 关注提示
            if let concern = entry.concern {
                ConcernBanner(text: concern, plant: plant, onTap: onDiagnose)
                    .padding(.top, 11)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: HHRadius.xl, style: .continuous)
                .fill(HHColor.paperCard.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: HHRadius.xl, style: .continuous)
                        .strokeBorder(HHColor.hairline, lineWidth: 1)
                )
        )
        .paperCardShadow()
    }
}

private struct DiagnosisCard: View {
    let entry: DiaryEntry
    let plant: Plant

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 头部
            HStack {
                HStack(spacing: 7) {
                    Text(entry.day)
                        .font(HHFont.ui(12.5, weight: .semibold))
                        .foregroundStyle(HHColor.inkSoft)
                    Text(entry.date)
                        .font(HHFont.num(12.5))
                        .foregroundStyle(HHColor.inkFaint)
                }
                Spacer()
                HStack(spacing: 4) {
                    HHIcon(name: .doctor, size: 11, color: .white, strokeWidth: 1.6)
                    Text("花大夫诊断")
                        .font(HHFont.ui(10.5, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 2)
                .background(Capsule().fill(plant.palette.deep))
            }

            // 症状/结论/护理
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    if let s = entry.symptom {
                        DiagRow(label: "症状", text: s, labelColor: HHColor.terra)
                    }
                    if let c = entry.conclusion {
                        DiagRow(label: "结论", text: c, labelColor: plant.palette.deep)
                    }
                    if let p = entry.plan {
                        DiagRow(label: "护理", text: p, labelColor: plant.palette.deep)
                    }
                }

                if entry.photo != nil {
                    TiltedPhoto(assetName: plant.photoAssetName, tilt: 3)
                        .frame(width: 70)
                }
            }
            .padding(.top, 11)

            // 植物回应
            HStack(alignment: .top, spacing: 7) {
                PlantAvatarView(plant: plant, size: 24)
                Text(entry.voice)
                    .font(HHFont.journal(13.5))
                    .foregroundStyle(HHColor.inkSoft)
                    .lineSpacing(3)
            }
            .padding(.top, 11)
            .padding(.top, 10)
            .overlay(alignment: .top) {
                Hairline()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .background(
            LinearGradient(
                colors: [Color(hex: "#F4F8F0"), HHColor.paperCard],
                startPoint: .top, endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: HHRadius.xl, style: .continuous))
        )
        .overlay(
            RoundedRectangle(cornerRadius: HHRadius.xl, style: .continuous)
                .strokeBorder(Color(hex: "#DBE5D2"), lineWidth: 1)
        )
        .paperCardShadow()
    }
}

private struct DiagRow: View {
    let label: String
    let text: String
    let labelColor: Color

    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            Text(label)
                .font(HHFont.ui(11.5, weight: .semibold))
                .foregroundStyle(labelColor)
                .fixedSize()
            Text(text)
                .font(HHFont.journal(13.5))
                .foregroundStyle(HHColor.inkSoft)
                .lineSpacing(3)
        }
    }
}

private struct TiltedPhoto: View {
    let assetName: String
    var tilt: Double = 4

    var body: some View {
        VStack(spacing: 4) {
            Image(assetName)
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 80)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 3))
        }
        .padding(5)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 3))
        .shadow(color: .black.opacity(0.14), radius: 4, x: 0, y: 2)
        .rotationEffect(.degrees(tilt))
        .alignmentGuide(.top) { $0[.top] }
    }
}

private struct ConcernBanner: View {
    let text: String
    let plant: Plant
    var onTap: (() -> Void)?

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: 9) {
                Circle()
                    .fill(HHColor.terra.opacity(0.18))
                    .frame(width: 22, height: 22)
                    .overlay(
                        HHIcon(name: .bell, size: 12, color: HHColor.terra, strokeWidth: 1.7)
                    )
                Text(text)
                    .font(HHFont.ui(12))
                    .foregroundStyle(HHColor.terra)
                    .lineSpacing(2)
                Spacer()
                HStack(spacing: 2) {
                    Text("找花大夫")
                        .font(HHFont.ui(12, weight: .bold))
                        .foregroundStyle(plant.palette.deep)
                    HHIcon(name: .chevronRight, size: 13, color: plant.palette.deep, strokeWidth: 1.8)
                }
            }
            .padding(.horizontal, 11)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: HHRadius.md, style: .continuous)
                    .fill(HHColor.terra.opacity(0.10))
                    .overlay(
                        RoundedRectangle(cornerRadius: HHRadius.md, style: .continuous)
                            .strokeBorder(HHColor.terra.opacity(0.28), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PlantDiaryView(plant: MockData.ciji)
    }
    .environment(AppState())
}
