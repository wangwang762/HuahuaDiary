//
//  DoctorChatView.swift
//  HuahuaDiary
//
//  花大夫问诊对话页
//  · 顶部标题栏（医生头像 + 名字 + 就诊状态）
//  · 绿色分析上下文条
//  · 对话气泡（花大夫左 / 用户右）
//  · 快捷回复 pills
//  · 结束问诊 → 诊断总结卡
//

import SwiftUI

// MARK: - 消息模型

private struct ChatMsg: Identifiable {
    let id = UUID()
    let role: Role
    let text: String

    enum Role { case doctor, user }
}

// MARK: - 模拟回复库（无网络时 fallback）

private func mockDoctorReply(to msg: String, plant: Plant) -> String {
    let lower = msg.lowercased()
    if lower.contains("浇") && lower.contains("多少") {
        return "根据\(plant.name)现在的状态，建议这次补水约 60ml，沿盆缘缓慢浇入，让水从底部排出就好。之后等土完全干透再浇——用手指插入土 2cm 感受一下，干了再说。"
    }
    if lower.contains("多久") || lower.contains("频率") || lower.contains("几天") {
        return "夏天大约 10–14 天浇一次，冬天可以拉长到 20 天以上。\(plant.name)这类品种宁干勿湿，比起忘浇水，浇多了才是大问题。"
    }
    if lower.contains("叶") && (lower.contains("皱") || lower.contains("蔫") || lower.contains("软")) {
        return "叶片发皱、变软，最常见的原因是缺水——但注意，浇多烂根也会有这个表现。先检查一下根部：取出来看看根是白的还是发黑发软的，是黑就要剪掉烂根再晾干重种。"
    }
    if lower.contains("换盆") {
        return "\(plant.name)换盆最好选春天，根系长满了、从底部排水孔钻出来就是该换了。换盆后一周别浇水，让根缓缓。"
    }
    if lower.contains("光") || lower.contains("晒") || lower.contains("放") {
        return "散射光最合适，避免正午直射——玻璃会聚焦加热，容易晒伤。窗边北向或有遮光的朝东位置都不错。"
    }
    if lower.contains("谢谢") || lower.contains("好的") || lower.contains("知道了") {
        return "好，照这个养法来。如果下周还有变化，随时带它过来——我等着。（拍拍植物）你行的。"
    }
    return "你说的这个情况，建议先控制一下浇水频率，同时保持通风。\(plant.name)底子不错，给它点时间调整，应该会好起来的。有问题随时追问我。"
}

// MARK: - 主视图

struct DoctorChatView: View {
    let plant: Plant

    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss

    @State private var messages: [ChatMsg] = []
    @State private var draft = ""
    @State private var isTyping = false
    @State private var showQuicks = true
    @State private var finished = false
    @State private var scrollProxy: ScrollViewProxy? = nil

    private let opener = "你好！照片我看了，先说结论——叶片有点轻微失水的迹象，颜色也偏暗了一些，不过整体问题不大。你可以问我具体怎么浇、多久浇一次，或者告诉我你平时怎么养它，我来帮你判断。"

    private let quicks = ["浇多少水合适？", "多久浇一次？", "叶片发皱怎么办", "需要换盆吗"]

    private var hasAiReplied: Bool { messages.contains(where: { $0.role == .doctor }) }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: "#F3EFE6").ignoresSafeArea()

            VStack(spacing: 0) {
                // ── 分析上下文条 ──
                contextBar

                // ── 消息列表 ──
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            // opener
                            DoctorBubble(text: opener)
                                .padding(.top, 12)

                            // 对话
                            ForEach(messages) { m in
                                if m.role == .doctor {
                                    DoctorBubble(text: m.text)
                                } else {
                                    UserBubble(text: m.text)
                                }
                            }

                            // 打字动效
                            if isTyping {
                                DoctorTyping()
                            }

                            // 结束问诊按钮（首次 AI 回复后显示）
                            if hasAiReplied && !isTyping && !finished {
                                Button {
                                    endConsult()
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 13, weight: .bold))
                                        Text("结束问诊 · 记入日记")
                                            .font(HHFont.journal(13, weight: .semibold))
                                    }
                                    .foregroundStyle(HHColor.greenDeep)
                                    .padding(.horizontal, 16)
                                    .frame(height: 36)
                                    .background(
                                        Capsule()
                                            .fill(Color(hex: "#E7F1E4"))
                                            .overlay(
                                                Capsule()
                                                    .strokeBorder(HHColor.green, lineWidth: 1.5)
                                            )
                                    )
                                }
                                .buttonStyle(.plain)
                                .pressScale(0.96)
                                .padding(.vertical, 6)
                                .padding(.bottom, 12)
                            }

                            // 诊断总结卡
                            if finished {
                                DiagnosisSummaryCard(plantName: plant.name) {
                                    // 返回首页
                                    app.doctorPath.removeAll()
                                }
                                .padding(.vertical, 6)
                                .padding(.bottom, 12)
                            }

                            Color.clear.frame(height: 1).id("bottom")
                        }
                        .padding(.horizontal, 16)
                    }
                    .onAppear { scrollProxy = proxy }
                    .onChange(of: messages.count) { _, _ in
                        withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
                    }
                    .onChange(of: isTyping) { _, v in
                        if v { withAnimation { proxy.scrollTo("bottom", anchor: .bottom) } }
                    }
                    .onChange(of: finished) { _, _ in
                        withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
                    }
                }

                Divider()
                    .opacity(0.4)

                // ── 快捷回复 ──
                if showQuicks && !finished {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(quicks, id: \.self) { q in
                                Button { send(q) } label: {
                                    Text(q)
                                        .font(HHFont.journal(14))
                                        .foregroundStyle(HHColor.inkSoft)
                                        .padding(.horizontal, 15)
                                        .padding(.vertical, 9)
                                        .background(
                                            Capsule()
                                                .fill(Color.white.opacity(0.7))
                                                .overlay(
                                                    Capsule().strokeBorder(HHColor.hairline, lineWidth: 1)
                                                )
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }
                }

                // ── 输入框 ──
                if !finished {
                    inputBar
                }
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) { header }
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - 顶栏

    private var header: some View {
        HStack(spacing: 10) {
            Button { dismiss() } label: {
                HStack(spacing: 2) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                    Text("返回")
                        .font(HHFont.journal(15))
                }
                .foregroundStyle(HHColor.inkSoft)
            }
            .buttonStyle(.plain)

            DoctorAvatarView(size: 36)

            VStack(alignment: .leading, spacing: 1) {
                Text("花大夫")
                    .font(HHFont.journal(16, weight: .bold))
                    .foregroundStyle(HHColor.ink)
                Text("第三方养护专家 · 正在看 \(plant.name)")
                    .font(HHFont.ui(11.5))
                    .foregroundStyle(HHColor.greenDeep)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Color(hex: "#F3EFE6")
                .background(.ultraThinMaterial)
        )
        .overlay(alignment: .bottom) { Hairline() }
    }

    // MARK: - 上下文条

    private var contextBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "camera.fill")
                .font(.system(size: 14, weight: .semibold))
            Text("正在分析 · 你上传的\(plant.name)（\(plant.species)）照片")
                .font(HHFont.ui(12.5, weight: .semibold))
        }
        .foregroundStyle(HHColor.greenDeep)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(Color(hex: "#E7EEDF"))
    }

    // MARK: - 输入框

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("继续追问花大夫…", text: $draft)
                .font(HHFont.ui(15))
                .foregroundStyle(HHColor.ink)
                .padding(.horizontal, 18)
                .frame(height: 46)
                .background(
                    Capsule()
                        .fill(Color.white)
                        .overlay(Capsule().strokeBorder(HHColor.hairline, lineWidth: 1))
                )
                .onSubmit { send() }

            Button { send() } label: {
                Image(systemName: "arrow.up")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(
                        Circle().fill(
                            LinearGradient(
                                colors: [HHColor.green, HHColor.greenDeep],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                    )
            }
            .buttonStyle(.plain)
            .pressScale(0.92)
            .disabled(draft.trimmingCharacters(in: .whitespaces).isEmpty || isTyping)
            .opacity(draft.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .padding(.bottom, max(0, (UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.bottom ?? 0) - 4))
        .background(
            Color(hex: "#F3EFE6").opacity(0.9)
                .background(.ultraThinMaterial)
        )
        .overlay(alignment: .top) { Hairline() }
    }

    // MARK: - 发送

    private func send(_ text: String? = nil) {
        let msg = (text ?? draft).trimmingCharacters(in: .whitespaces)
        guard !msg.isEmpty, !isTyping else { return }
        draft = ""
        showQuicks = false
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        withAnimation(HHMotion.smooth) {
            messages.append(ChatMsg(role: .user, text: msg))
            isTyping = true
        }

        // 模拟 AI 延迟
        let delay = Double.random(in: 1.2...2.2)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let reply = mockDoctorReply(to: msg, plant: plant)
            withAnimation(HHMotion.smooth) {
                isTyping = false
                messages.append(ChatMsg(role: .doctor, text: reply))
            }
        }
    }

    // MARK: - 结束问诊

    private func endConsult() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation(HHMotion.smooth) { finished = true }
    }
}

// MARK: - 医生气泡

private struct DoctorBubble: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            DoctorAvatarView(size: 36)
                .padding(.top, 2)

            Text(text)
                .font(HHFont.journal(15))
                .foregroundStyle(HHColor.ink)
                .lineSpacing(3)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.07), radius: 4, x: 0, y: 2)
                )
                .overlay(alignment: .topLeading) {
                    // 气泡尖角
                    Path { p in
                        p.move(to: CGPoint(x: 0, y: 6))
                        p.addLine(to: CGPoint(x: -6, y: 0))
                        p.addLine(to: CGPoint(x: 0, y: 14))
                    }
                    .fill(Color.white)
                }

            Spacer(minLength: 60)
        }
        .padding(.vertical, 5)
    }
}

// MARK: - 用户气泡

private struct UserBubble: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Spacer(minLength: 60)

            Text(text)
                .font(HHFont.ui(15))
                .foregroundStyle(.white)
                .lineSpacing(3)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [HHColor.green, HHColor.greenDeep],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .shadow(color: HHColor.greenDeep.opacity(0.25), radius: 6, x: 0, y: 3)
                )
        }
        .padding(.vertical, 5)
    }
}

// MARK: - 打字中动效

private struct DoctorTyping: View {
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            DoctorAvatarView(size: 36)
                .padding(.top, 2)

            HStack(spacing: 6) {
                TypingDots(color: HHColor.inkFaint)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.07), radius: 4, x: 0, y: 2)
            )

            Spacer()
        }
        .padding(.vertical, 5)
    }
}

// MARK: - 诊断总结卡

struct DiagnosisSummaryCard: View {
    let plantName: String
    let onView: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                // 绿色勾
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [HHColor.green, HHColor.greenDeep],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: 46, height: 46)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                    )
                    .shadow(color: HHColor.greenDeep.opacity(0.28), radius: 10, x: 0, y: 6)
                    .padding(.bottom, 12)

                Text("已记入\(plantName)的日记")
                    .font(HHFont.journal(17, weight: .bold))
                    .foregroundStyle(HHColor.ink)
                Text("本次问诊已整理成一篇养护记录")
                    .font(HHFont.ui(12.5))
                    .foregroundStyle(HHColor.inkFaint)
                    .padding(.top, 4)

                // 养护要点
                VStack(alignment: .leading, spacing: 3) {
                    Text("本次养护要点")
                        .font(HHFont.ui(11.5, weight: .bold))
                        .foregroundStyle(HHColor.greenDeep)
                        .opacity(0.8)
                    Text("散射光 · 多通风 · 土干透再浇")
                        .font(HHFont.journal(15, weight: .bold))
                        .foregroundStyle(HHColor.ink)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: HHRadius.lg, style: .continuous)
                        .fill(Color(hex: "#E7EEDF"))
                )
                .padding(.top, 14)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .frame(maxWidth: 320)
            .background(
                RoundedRectangle(cornerRadius: HHRadius.xxl, style: .continuous)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: HHRadius.xxl, style: .continuous)
                            .strokeBorder(Color(hex: "#E7EEDF"), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.09), radius: 18, x: 0, y: 6)
            )

            // 查看日记按钮
            Button(action: onView) {
                HStack(spacing: 7) {
                    Text("查看所有日记")
                        .font(HHFont.ui(14.5, weight: .semibold))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 22)
                .frame(height: 46)
                .background(
                    Capsule().fill(
                        LinearGradient(
                            colors: [HHColor.green, HHColor.greenDeep],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                )
            }
            .buttonStyle(.plain)
            .pressScale(0.97)
            .padding(.top, 14)
        }
        .frame(maxWidth: .infinity)
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        DoctorChatView(plant: MockData.ciji)
            .environment(AppState())
    }
}
