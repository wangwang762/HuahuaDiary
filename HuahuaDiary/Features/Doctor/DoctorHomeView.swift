//
//  DoctorHomeView.swift
//  HuahuaDiary
//
//  花大夫诊所 Tab — 接诊入口 + 病历墙
//

import SwiftUI

struct DoctorHomeView: View {
    @Environment(AppState.self) private var app

    @State private var statusFilter: ClinicStatus = .all

    private var shownCases: [ClinicCase] {
        statusFilter == .all
            ? app.clinicCases
            : app.clinicCases.filter { $0.status == statusFilter }
    }

    private func count(for s: ClinicStatus) -> Int {
        s == .all ? app.clinicCases.count
                  : app.clinicCases.filter { $0.status == s }.count
    }

    private var statusBarHeight: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.top ?? 54
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Color.clear.frame(height: statusBarHeight + 10)

                // ── 接诊模块 ──
                receptionCard
                    .padding(.horizontal, 20)

                // ── 病历墙标题 ──
                caseWallHeader
                    .padding(.horizontal, 22)
                    .padding(.top, 26)

                // ── 状态筛选 ──
                statusTabs
                    .padding(.top, 4)

                // ── 病历墙 ──
                CaseWall(cases: shownCases, plants: app.plants)
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 130)
            }
        }
        .background(
            LinearGradient(
                stops: [
                    .init(color: Color(hex: "#EAF1E6"), location: 0),
                    .init(color: HHColor.paper, location: 0.22)
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .ignoresSafeArea(edges: .top)
        .scrollClipDisabled()
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: Reception card
    private var receptionCard: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 13) {
                DoctorAvatarView(size: 50)
                VStack(alignment: .leading, spacing: 4) {
                    Text("花大夫诊所")
                        .font(HHFont.display(24, weight: .bold))
                        .foregroundStyle(HHColor.ink)
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color(hex: "#2C7A4B"))
                            .frame(width: 7, height: 7)
                            .overlay(
                                Circle()
                                    .strokeBorder(Color(hex: "#2C7A4B").opacity(0.25), lineWidth: 3)
                                    .frame(width: 13, height: 13)
                            )
                        Text("营业中")
                            .font(HHFont.ui(12.5, weight: .semibold))
                            .foregroundStyle(Color(hex: "#2C7A4B"))
                        Text("· 今日已接诊 \(app.clinicCases.filter { $0.seen == "今天" }.count)")
                            .font(HHFont.ui(12.5))
                            .foregroundStyle(HHColor.inkFaint)
                    }
                }
            }

            Text("看叶辨症，对症养护。把蔫了、黄了、没精神的花带来，我替你瞧瞧。")
                .font(HHFont.journal(13.5))
                .foregroundStyle(HHColor.inkSoft)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 13)

            NavigationLink(value: DoctorRoute.capture(plantId: "", intake: true)) {
                HStack(spacing: 9) {
                    Image(systemName: "camera")
                        .font(.system(size: 18, weight: .semibold))
                    Text("带一盆花来看诊")
                        .font(HHFont.ui(16, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        colors: [HHColor.green, HHColor.greenDeep],
                        startPoint: .top, endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: HHRadius.lg, style: .continuous))
                )
            }
            .buttonStyle(.plain)
            .pressScale(0.97)
            .padding(.top, 15)
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
    }

    // MARK: Case wall header
    private var caseWallHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text("病历墙")
                    .font(HHFont.display(19, weight: .bold))
                    .foregroundStyle(HHColor.ink)
                Spacer()
                Text("CASE FILES · \(app.clinicCases.count)")
                    .font(HHFont.ui(10.5, weight: .semibold))
                    .tracking(2.4)
                    .textCase(.uppercase)
                    .foregroundStyle(HHColor.inkFaint)
            }
            Text("瞧瞧上次都给哪些倒霉蛋看过诊，最近恢复得怎么样了。")
                .font(HHFont.ui(12))
                .foregroundStyle(HHColor.inkFaint)
        }
    }

    // MARK: Status tabs
    private var statusTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach([ClinicStatus.all, .recheck, .recovering, .healed, .dead], id: \.self) { s in
                    let on = statusFilter == s
                    Button {
                        UISelectionFeedbackGenerator().selectionChanged()
                        withAnimation(HHMotion.snap) { statusFilter = s }
                    } label: {
                        HStack(spacing: 6) {
                            if s != .all {
                                Circle()
                                    .fill(on ? Color.white.opacity(0.9) : s.color)
                                    .frame(width: 7, height: 7)
                            }
                            Text(s.label)
                                .font(HHFont.ui(13.5, weight: .semibold))
                                .foregroundStyle(on ? Color.white : HHColor.inkSoft)
                            Text("\(count(for: s))")
                                .font(HHFont.num(11.5, weight: .semibold))
                                .foregroundStyle(on ? Color.white.opacity(0.78) : HHColor.inkFaint)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(on ? AnyShapeStyle(HHColor.ink) : AnyShapeStyle(HHColor.paperCard))
                                .overlay(
                                    Capsule().strokeBorder(on ? HHColor.ink : HHColor.hairline, lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 2)
        }
    }
}

// MARK: - Case wall (cork board)

private struct CaseWall: View {
    let cases: [ClinicCase]
    let plants: [Plant]

    private func plant(for c: ClinicCase) -> Plant? {
        plants.first { $0.id == c.plantId }
    }

    var body: some View {
        ZStack {
            // 软木板纹理背景
            RoundedRectangle(cornerRadius: HHRadius.xxl, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#E5D6BC"), Color(hex: "#DCC8A8")],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .shadow(color: Color(hex: "#785A32", opacity: 0.18), radius: 10, x: 0, y: 2)

            // 点纹理（用 Canvas 模拟）
            Canvas { ctx, size in
                let colors: [Color] = [
                    Color(hex: "#785A32", opacity: 0.14),
                    Color(hex: "#5A4123", opacity: 0.12)
                ]
                for row in stride(from: 0, to: size.height, by: 9) {
                    for col in stride(from: 0, to: size.width, by: 9) {
                        let ci = (Int(row/9) + Int(col/9)) % 2
                        let r = CGRect(x: col, y: row, width: 1, height: 1)
                        ctx.fill(Path(ellipseIn: r), with: .color(colors[ci]))
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: HHRadius.xxl, style: .continuous))
            .allowsHitTesting(false)

            if cases.isEmpty {
                Text("这一类暂时没有病历～")
                    .font(HHFont.journal(13.5))
                    .foregroundStyle(HHColor.inkSoft)
                    .padding(40)
            } else {
                VStack(spacing: 18) {
                    ForEach(Array(cases.enumerated()), id: \.element.id) { i, c in
                        ClinicCaseCard(
                            clinicCase: c,
                            plant: plant(for: c),
                            tilt: i % 2 == 0 ? 1.4 : -1.4
                        )
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 20)
            }
        }
    }
}

// MARK: - Clinic case card

private struct ClinicCaseCard: View {
    let clinicCase: ClinicCase
    let plant: Plant?
    var tilt: Double = 1.4

    private var isDead: Bool { clinicCase.status == .dead }
    private var isHealed: Bool { clinicCase.status == .healed }
    private var name: String { clinicCase.patientName ?? plant?.name ?? "未知" }
    private var species: String { clinicCase.patientSpecies ?? plant?.species ?? "" }

    var body: some View {
        ZStack(alignment: .top) {
            // 图钉
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "#FF9A8A"), pinColor],
                        center: UnitPoint(x: 0.35, y: 0.3),
                        startRadius: 0, endRadius: 8
                    )
                )
                .frame(width: 14, height: 14)
                .shadow(color: .black.opacity(0.28), radius: 3, x: 0, y: 2)
                .zIndex(1)

            // 病历卡
            VStack(spacing: 0) {
                // 顶部标题条
                HStack {
                    HStack(spacing: 7) {
                        HHIcon(
                            name: isDead ? .leaf : .doctor,
                            size: 15,
                            color: isDead ? Color(hex: "#8A7B6B") : HHColor.greenDeep,
                            strokeWidth: 1.7
                        )
                        Text(clinicCase.no)
                            .font(HHFont.num(12.5, weight: .semibold))
                            .foregroundStyle(isDead ? Color(hex: "#8A7B6B") : HHColor.greenDeep)
                    }
                    Spacer()
                    Text("\(clinicCase.date) · \(clinicCase.seen)")
                        .font(HHFont.num(11.5))
                        .foregroundStyle(HHColor.inkFaint)
                }
                .padding(.horizontal, 13)
                .padding(.vertical, 8)
                .background(
                    isDead
                        ? Color(hex: "#6E6256", opacity: 0.14)
                        : Color(hex: "#E7EEDF")
                )
                .overlay(alignment: .bottom) {
                    Hairline().opacity(0.5)
                }

                // 主体内容
                VStack(alignment: .leading, spacing: 0) {
                    // 患者信息
                    HStack(spacing: 11) {
                        Group {
                            if let p = plant {
                                PlantAvatarView(plant: p, size: 42)
                                    .opacity(isDead ? 0.75 : 1)
                                    .saturation(isDead ? 0.2 : 1)
                            } else {
                                Circle()
                                    .fill(HHColor.paperCard)
                                    .frame(width: 42, height: 42)
                            }
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            HStack(alignment: .firstTextBaseline, spacing: 6) {
                                Text(name)
                                    .font(HHFont.display(17, weight: .bold))
                                    .foregroundStyle(HHColor.ink)
                                Text(species)
                                    .font(HHFont.ui(10.5))
                                    .foregroundStyle(HHColor.inkFaint)
                            }
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(clinicCase.status.color)
                                    .frame(width: 6, height: 6)
                                Text(clinicCase.status.label)
                                    .font(HHFont.ui(10, weight: .semibold))
                                    .foregroundStyle(clinicCase.status.color)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                Capsule().fill(clinicCase.status.background)
                            )
                        }
                    }

                    // 病历行
                    VStack(spacing: 7) {
                        ChartRow(label: "主诉", text: clinicCase.complaint)
                        ChartRow(label: "诊断", text: clinicCase.diagnosis, accent: true)
                        if !isDead {
                            ChartRow(label: "医嘱", text: clinicCase.rx)
                        }
                    }
                    .padding(.top, 12)

                    // 恢复进度条
                    if !isHealed && !isDead {
                        VStack(spacing: 4) {
                            HStack {
                                Text("恢复进度")
                                    .font(HHFont.ui(11))
                                    .foregroundStyle(HHColor.inkFaint)
                                Spacer()
                                Text("\(clinicCase.progress)%")
                                    .font(HHFont.num(11, weight: .semibold))
                                    .foregroundStyle(clinicCase.status.color)
                            }
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(Color.black.opacity(0.08))
                                    Capsule()
                                        .fill(clinicCase.status.color)
                                        .frame(width: geo.size.width * CGFloat(clinicCase.progress) / 100)
                                }
                            }
                            .frame(height: 6)
                        }
                        .padding(.top, 13)
                    }

                    // 死亡记录
                    if isDead {
                        VStack(spacing: 8) {
                            if let cause = clinicCase.cause {
                                HStack(alignment: .top, spacing: 8) {
                                    Text("死因")
                                        .font(HHFont.ui(10.5, weight: .bold))
                                        .foregroundStyle(Color(hex: "#8A7B6B"))
                                    Text(cause)
                                        .font(HHFont.journal(12.5))
                                        .foregroundStyle(HHColor.inkSoft)
                                        .lineSpacing(3)
                                }
                                .padding(.horizontal, 11)
                                .padding(.vertical, 9)
                                .background(
                                    RoundedRectangle(cornerRadius: HHRadius.sm, style: .continuous)
                                        .fill(Color(hex: "#6E6256", opacity: 0.10))
                                )
                            }
                            if let lesson = clinicCase.lesson {
                                HStack(alignment: .top, spacing: 8) {
                                    HHIcon(name: .leaf, size: 14, color: Color(hex: "#2C7A4B"), strokeWidth: 1.7)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("避坑经验")
                                            .font(HHFont.ui(10.5, weight: .bold))
                                            .foregroundStyle(Color(hex: "#2C7A4B"))
                                        Text(lesson)
                                            .font(HHFont.journal(12.5))
                                            .foregroundStyle(HHColor.ink)
                                            .lineSpacing(3)
                                    }
                                }
                                .padding(.horizontal, 11)
                                .padding(.vertical, 9)
                                .background(
                                    RoundedRectangle(cornerRadius: HHRadius.sm, style: .continuous)
                                        .fill(Color(hex: "#2C7A4B", opacity: 0.08))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: HHRadius.sm, style: .continuous)
                                                .strokeBorder(Color(hex: "#2C7A4B", opacity: 0.18), lineWidth: 1)
                                        )
                                )
                            }
                        }
                        .padding(.top, 12)
                    }

                    // 最新备注
                    if !isDead && !clinicCase.note.isEmpty {
                        HStack(alignment: .top, spacing: 7) {
                            Image(systemName: "clock")
                                .font(.system(size: 12))
                                .foregroundStyle(HHColor.inkFaint)
                                .padding(.top, 1)
                            Text(clinicCase.note)
                                .font(HHFont.journal(12.5))
                                .foregroundStyle(HHColor.inkSoft)
                                .lineSpacing(3)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: HHRadius.sm, style: .continuous)
                                .fill(Color.black.opacity(0.025))
                        )
                        .padding(.top, 12)
                    }

                    // ── 操作按钮 / 悼念文字 ──
                    if isDead {
                        Text(clinicCase.note)
                            .font(HHFont.journal(12))
                            .foregroundStyle(HHColor.inkFaint)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 12)
                    } else {
                        let isRecheck = clinicCase.status == .recheck
                        let btnLabel = isHealed ? "查看病历" : (isRecheck ? "拍照复诊" : "继续复查")
                        let btnColor = isHealed ? HHColor.inkSoft : clinicCase.status.color
                        let btnBg    = isHealed ? Color.clear : clinicCase.status.background
                        let btnBorder = isHealed ? HHColor.hairline : clinicCase.status.color.opacity(0.34)

                        Button { /* TODO */ } label: {
                            HStack(spacing: 6) {
                                Text(btnLabel)
                                    .font(HHFont.ui(13, weight: .semibold))
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundStyle(btnColor)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(
                                Capsule()
                                    .fill(btnBg)
                                    .overlay(
                                        Capsule().strokeBorder(btnBorder, lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                        .pressScale(0.97)
                        .padding(.top, 12)
                    }
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 13)
                // ── 痊愈 / 已离开 印章 ──
                .overlay(alignment: .topTrailing) {
                    if isHealed {
                        Text("已痊愈")
                            .font(HHFont.journal(14, weight: .bold))
                            .tracking(2)
                            .foregroundStyle(Color(hex: "#2C7A4B", opacity: 0.62))
                            .padding(.horizontal, 9)
                            .padding(.vertical, 3)
                            .overlay(
                                RoundedRectangle(cornerRadius: 7, style: .continuous)
                                    .strokeBorder(Color(hex: "#2C7A4B", opacity: 0.50), lineWidth: 2.5)
                            )
                            .rotationEffect(.degrees(-14))
                            .padding(.top, 18)
                            .padding(.trailing, 10)
                    } else if isDead {
                        Text("已离开")
                            .font(HHFont.journal(13, weight: .bold))
                            .tracking(2)
                            .foregroundStyle(Color(hex: "#6E6256", opacity: 0.60))
                            .padding(.horizontal, 9)
                            .padding(.vertical, 3)
                            .overlay(
                                RoundedRectangle(cornerRadius: 7, style: .continuous)
                                    .strokeBorder(Color(hex: "#6E6256", opacity: 0.45), lineWidth: 2.5)
                            )
                            .rotationEffect(.degrees(-12))
                            .padding(.top, 16)
                            .padding(.trailing, 10)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: HHRadius.lg, style: .continuous)
                    .fill(HHColor.paperCard)
                    .shadow(color: Color(hex: "#463219", opacity: 0.22), radius: 10, x: 0, y: 6)
            )
            .clipShape(RoundedRectangle(cornerRadius: HHRadius.lg, style: .continuous))
            .opacity(isDead ? 0.96 : 1)
            .saturation(isDead ? 0.72 : 1)
            .padding(.top, 9)
        }
        .rotationEffect(.degrees(tilt))
    }

    private var pinColor: Color {
        isDead ? Color(hex: "#8A7B6B")
               : (isHealed ? Color(hex: "#2C7A4B") : Color(hex: "#C8553C"))
    }
}

private struct ChartRow: View {
    let label: String
    let text: String
    var accent: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 9) {
            Text(label)
                .font(HHFont.ui(11, weight: .bold))
                .foregroundStyle(HHColor.inkFaint)
                .frame(width: 30, alignment: .leading)
                .fixedSize()
            Text(text)
                .font(HHFont.journal(13))
                .foregroundStyle(accent ? HHColor.greenDeep : HHColor.ink)
                .fontWeight(accent ? .semibold : .regular)
                .lineSpacing(3)
        }
    }
}

// MARK: - Doctor avatar (cute cartoon placeholder)

struct DoctorAvatarView: View {
    var size: CGFloat = 50

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "#E7F1E4"))
                .frame(width: size, height: size)
            VStack(spacing: 0) {
                // 简单的听诊器图标替代卡通医生
                HHIcon(name: .doctor, size: size * 0.5, color: HHColor.greenDeep, strokeWidth: 1.8)
            }
        }
        .overlay(
            Circle().strokeBorder(HHColor.greenDeep.opacity(0.2), lineWidth: 1.5)
        )
    }
}

// MARK: - Preview

#Preview {
    DoctorHomeView()
        .environment(AppState())
}
