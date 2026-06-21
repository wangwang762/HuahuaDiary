//
//  CaptureView.swift
//  HuahuaDiary
//
//  带花看诊 / 给植物拍照 — 五步流程
//  shoot → analyzing → identify → good / abnormal
//

import SwiftUI

// MARK: - Step state

private enum CaptureStep {
    case shoot          // 初始：拍照提示
    case analyzing      // 分析中：扫描动画
    case identify       // 确认身份（intake 模式）
    case good           // 状态好：情绪记录
    case abnormal       // 状态异常：转花大夫
}

// MARK: - Main view

struct CaptureView: View {
    let plant: Plant
    let isIntake: Bool

    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss

    @State private var step: CaptureStep = .shoot
    @State private var scanOffset: CGFloat = 0

    private var needsDoctor: Bool { plant.statusTone == .warn }

    // 候选同类植物（identify 步骤用）
    private var candidates: [Plant] {
        app.plants.filter { $0.id != plant.id || app.plants.count == 1 }
    }

    /// UIKit 拿到的真实状态栏高度，不受 SwiftUI safe area 污染影响
    private var statusBarHeight: CGFloat {
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
            .statusBarManager?.statusBarFrame.height ?? 54
    }

    private let navBarContentHeight: CGFloat = 52

    var body: some View {
        ZStack(alignment: .top) {
            // 渐变背景：从屏幕绝对顶部铺满
            LinearGradient(
                stops: [
                    .init(color: plant.palette.soft.opacity(0.7), location: 0),
                    .init(color: HHColor.paper, location: 0.32)
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            // 内容区：顶部留出 navBar 高度
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Color.clear.frame(height: statusBarHeight + navBarContentHeight)

                    photoFrame
                        .padding(.top, 10)

                    Group {
                        switch step {
                        case .shoot:     shootStep
                        case .analyzing: analyzingStep
                        case .identify:  identifyStep
                        case .good:      goodStep
                        case .abnormal:  abnormalStep
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                    .animation(HHMotion.smooth, value: step)
                    .padding(.top, 26)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }

            // NavBar：固定在状态栏下方
            VStack(spacing: 0) {
                Color.clear.frame(height: statusBarHeight)
                navBar
            }
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - 自定义导航栏

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

            Text(isIntake ? "带花来看诊" : "记录 \(plant.name)")
                .font(HHFont.journal(16, weight: .semibold))
                .foregroundStyle(HHColor.ink)

            Spacer()

            Color.clear.frame(width: 60)
        }
        .padding(.horizontal, 16)
        .frame(height: navBarContentHeight)
        .background(Color.clear)
    }

    // MARK: - 宝丽来相框

    private var photoFrame: some View {
        ZStack {
            // 白色相框
            VStack(spacing: 0) {
                Image(plant.photoAssetName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 210, height: 250)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))

                Text(isIntake ? "今天 · 6月8日" : "第 \(plant.days) 天 · 6月8日")
                    .font(HHFont.journal(18))
                    .foregroundStyle(HHColor.inkSoft)
                    .padding(.top, 4)
            }
            .padding(8)
            .background(Color.white)
            .shadow(color: .black.opacity(0.14), radius: 12, x: 0, y: 6)
            .rotationEffect(.degrees(-1.5))

            // 扫描线（analyzing 状态）
            if step == .analyzing {
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 210, height: 250)
                    .foregroundStyle(Color.clear)
                    .overlay(alignment: .top) {
                        LinearGradient(
                            colors: [Color.clear, plant.palette.accent, Color.clear],
                            startPoint: .leading, endPoint: .trailing
                        )
                        .frame(height: 3)
                        .shadow(color: plant.palette.accent, radius: 6, x: 0, y: 0)
                        .offset(y: scanOffset)
                        .clipped()
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .onAppear {
                        withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: true)) {
                            scanOffset = 250
                        }
                    }
                    .rotationEffect(.degrees(-1.5))
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Shoot step

    private var shootStep: some View {
        VStack(spacing: 22) {
            Text(isIntake
                 ? "拍一张它现在的样子，\n花花先认认它是谁、瞧瞧哪儿不舒服。"
                 : "拍一张\(plant.name)此刻的照片，\n花花会看看它今天的状态。")
                .font(HHFont.journal(15))
                .foregroundStyle(HHColor.inkSoft)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            primaryButton(
                label: isIntake ? "让花花认认它" : "让花花看看",
                icon: "leaf.fill"
            ) {
                startAnalyzing()
            }
        }
    }

    // MARK: - Analyzing step

    private var analyzingStep: some View {
        VStack(spacing: 14) {
            TypingDots(color: plant.palette.accent)

            Text(isIntake ? "正在认一认这盆花…" : "正在看看 \(plant.name) 的样子…")
                .font(HHFont.journal(16))
                .foregroundStyle(HHColor.inkSoft)

            Text(isIntake
                 ? "先认出它是谁，再看看哪儿不舒服"
                 : "看看叶子、土壤，判断是记录还是要诊断")
                .font(HHFont.ui(12.5))
                .foregroundStyle(HHColor.inkFaint)
        }
    }

    // MARK: - Identify step（intake 专用：选是哪盆）

    private var identifyStep: some View {
        VStack(spacing: 0) {
            HStack(spacing: 7) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(HHColor.greenDeep)
                Text("花花认出来了 · 这像是「多肉植物」")
                    .font(HHFont.ui(13, weight: .semibold))
                    .foregroundStyle(HHColor.greenDeep)
            }
            .padding(.bottom, 6)

            Text(app.plants.count >= 2
                 ? "你有 \(app.plants.count) 盆长得很像，\n这是哪一盆呢？"
                 : "这是你的 \(app.plants.first?.name ?? "") 吗？")
                .font(HHFont.journal(15.5))
                .foregroundStyle(HHColor.ink)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            VStack(spacing: 10) {
                ForEach(app.plants) { p in
                    NavigationLink(value: DoctorRoute.doctorChat(plantId: p.id)) {
                        HStack(spacing: 12) {
                            PlantAvatarView(plant: p, size: 44)
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(alignment: .firstTextBaseline, spacing: 6) {
                                    Text(p.name)
                                        .font(HHFont.display(16, weight: .bold))
                                        .foregroundStyle(HHColor.ink)
                                    Text(p.species)
                                        .font(HHFont.ui(10.5))
                                        .foregroundStyle(HHColor.inkFaint)
                                }
                                Text(p.status)
                                    .font(HHFont.ui(11.5))
                                    .foregroundStyle(p.statusTone == .warn ? HHColor.terra : HHColor.inkFaint)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundStyle(HHColor.inkFaint)
                        }
                        .padding(.horizontal, 13)
                        .padding(.vertical, 11)
                        .background(
                            RoundedRectangle(cornerRadius: HHRadius.lg, style: .continuous)
                                .fill(HHColor.paperCard)
                                .overlay(
                                    RoundedRectangle(cornerRadius: HHRadius.lg, style: .continuous)
                                        .strokeBorder(HHColor.hairline, lineWidth: 1)
                                )
                        )
                        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                }

                // 新朋友选项
                NavigationLink(value: DoctorRoute.doctorChat(plantId: "unknown")) {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(HHColor.greenDeep.opacity(0.12))
                            .frame(width: 44, height: 44)
                            .overlay(
                                Image(systemName: "plus")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(HHColor.greenDeep)
                            )
                        VStack(alignment: .leading, spacing: 3) {
                            Text(app.plants.isEmpty ? "是的，新朋友" : "都不是，是新朋友")
                                .font(HHFont.display(16, weight: .bold))
                                .foregroundStyle(HHColor.greenDeep)
                            Text("先看诊，结束后帮它建一份档案")
                                .font(HHFont.ui(11.5))
                                .foregroundStyle(HHColor.inkSoft)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundStyle(HHColor.greenDeep)
                    }
                    .padding(.horizontal, 13)
                    .padding(.vertical, 11)
                    .background(
                        RoundedRectangle(cornerRadius: HHRadius.lg, style: .continuous)
                            .fill(HHColor.greenDeep.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: HHRadius.lg, style: .continuous)
                                    .strokeBorder(HHColor.greenDeep.opacity(0.4), lineWidth: 1.5, antialiased: true)
                            )
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 16)

            // 重拍
            Button("重拍一张") {
                withAnimation(HHMotion.smooth) { step = .shoot; scanOffset = 0 }
            }
            .font(HHFont.ui(14))
            .foregroundStyle(HHColor.inkFaint)
            .padding(.top, 14)
        }
    }

    // MARK: - Good step

    private var goodStep: some View {
        VStack(spacing: 0) {
            HStack(spacing: 7) {
                Circle()
                    .fill(plant.palette.accent)
                    .frame(width: 22, height: 22)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                    )
                Text("状态不错，记一笔")
                    .font(HHFont.journal(16, weight: .semibold))
                    .foregroundStyle(plant.palette.deep)
            }
            .padding(.bottom, 14)

            // 日记卡
            VStack(alignment: .leading, spacing: 12) {
                Text("今天给\(plant.name)拍了张照，状态正好。")
                    .font(HHFont.journal(16.5))
                    .foregroundStyle(HHColor.ink)
                    .lineSpacing(4)

                HStack(alignment: .top, spacing: 8) {
                    PlantAvatarView(plant: plant, size: 30)
                    Text(plant.voice)
                        .font(HHFont.journal(14.5))
                        .foregroundStyle(HHColor.ink)
                        .lineSpacing(3)
                        .padding(.horizontal, 13)
                        .padding(.vertical, 9)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(plant.palette.bubble)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .strokeBorder(plant.palette.accent.opacity(0.13), lineWidth: 1)
                                )
                        )
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: HHRadius.xxl, style: .continuous)
                    .fill(HHColor.paperCard.opacity(0.86))
                    .overlay(
                        RoundedRectangle(cornerRadius: HHRadius.xxl, style: .continuous)
                            .strokeBorder(HHColor.hairline, lineWidth: 1)
                    )
            )
            .paperCardShadow()

            primaryButton(label: "存入日记", icon: "book.closed.fill") {
                dismiss()
            }
            .padding(.top, 20)

            Button("重拍一张") {
                withAnimation(HHMotion.smooth) { step = .shoot; scanOffset = 0 }
            }
            .font(HHFont.ui(14))
            .foregroundStyle(HHColor.inkFaint)
            .padding(.top, 12)
        }
    }

    // MARK: - Abnormal step

    private var abnormalStep: some View {
        VStack(spacing: 0) {
            HStack(spacing: 7) {
                Circle()
                    .fill(HHColor.terra)
                    .frame(width: 22, height: 22)
                    .overlay(
                        HHIcon(name: .bell, size: 11, color: .white, strokeWidth: 2)
                    )
                Text("好像有点不对劲")
                    .font(HHFont.journal(16, weight: .semibold))
                    .foregroundStyle(HHColor.terra)
            }
            .padding(.bottom, 14)

            // 警示卡
            VStack(alignment: .leading, spacing: 12) {
                Text("花花注意到\(plant.name)的叶片有点蔫、颜色偏暗，可能需要看看。要不要让花大夫诊断一下？")
                    .font(HHFont.journal(15.5))
                    .foregroundStyle(HHColor.ink)
                    .lineSpacing(4)

                HStack(alignment: .top, spacing: 8) {
                    PlantAvatarView(plant: plant, size: 30)
                    Text(plant.voice)
                        .font(HHFont.journal(14.5))
                        .foregroundStyle(HHColor.ink)
                        .lineSpacing(3)
                        .padding(.horizontal, 13)
                        .padding(.vertical, 9)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(plant.palette.bubble)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .strokeBorder(plant.palette.accent.opacity(0.13), lineWidth: 1)
                                )
                        )
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: HHRadius.xxl, style: .continuous)
                    .fill(HHColor.paperCard.opacity(0.86))
                    .overlay(
                        RoundedRectangle(cornerRadius: HHRadius.xxl, style: .continuous)
                            .strokeBorder(HHColor.terra.opacity(0.30), lineWidth: 1)
                    )
            )
            .paperCardShadow()

            // 去看花大夫
            NavigationLink(value: DoctorRoute.doctorChat(plantId: plant.id)) {
                HStack(spacing: 8) {
                    HHIcon(name: .doctor, size: 20, color: .white, strokeWidth: 1.8)
                    Text("去问花大夫")
                        .font(HHFont.ui(16, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "#357355"), Color(hex: "#234B36")],
                        startPoint: .top, endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: HHRadius.pill, style: .continuous))
                )
                .shadow(color: Color(hex: "#234B36").opacity(0.3), radius: 12, x: 0, y: 6)
            }
            .buttonStyle(.plain)
            .pressScale(0.97)
            .padding(.top, 20)

            Button("先不诊断，只记录一下") {
                dismiss()
            }
            .font(HHFont.ui(14))
            .foregroundStyle(HHColor.inkFaint)
            .padding(.top, 12)
        }
    }

    // MARK: - Helpers

    private func startAnalyzing() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation(HHMotion.smooth) { step = .analyzing }
        let delay: Double = isIntake ? 1.9 : (needsDoctor ? 1.7 : 1.9)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(HHMotion.smooth) {
                if isIntake {
                    step = .identify
                } else {
                    step = needsDoctor ? .abnormal : .good
                }
                scanOffset = 0
            }
        }
    }

    @ViewBuilder
    private func primaryButton(label: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 9) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                Text(label)
                    .font(HHFont.ui(16, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                LinearGradient(
                    colors: [plant.palette.accent, plant.palette.deep],
                    startPoint: .top, endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: HHRadius.pill, style: .continuous))
            )
            .shadow(color: plant.palette.accent.opacity(0.3), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
        .pressScale(0.97)
    }
}

// MARK: - Typing dots (共用)

struct TypingDots: View {
    var color: Color = HHColor.inkFaint

    @State private var phase = 0
    @State private var timer: Timer?

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3) { i in
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                    .scaleEffect(phase == i ? 1.3 : 0.85)
                    .opacity(phase == i ? 1 : 0.45)
                    .animation(.easeInOut(duration: 0.4), value: phase)
            }
        }
        .onAppear {
            timer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
                phase = (phase + 1) % 3
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CaptureView(plant: MockData.ciji, isIntake: true)
            .environment(AppState())
    }
}
