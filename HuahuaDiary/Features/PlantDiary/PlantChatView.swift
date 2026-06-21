//
//  PlantChatView.swift
//  HuahuaDiary
//
//  与植物对话 — 占位（AI 接入后完善）
//

import SwiftUI

struct PlantChatView: View {
    let plant: Plant

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .top) {
            HHColor.paper.ignoresSafeArea()
            VStack(spacing: 20) {
                Spacer()
                PlantAvatarView(plant: plant, size: 72)
                Text("和 \(plant.name) 说悄悄话")
                    .font(HHFont.journal(20, weight: .bold))
                    .foregroundStyle(HHColor.ink)
                Text("对话功能即将开放，敬请期待～")
                    .font(HHFont.ui(14))
                    .foregroundStyle(HHColor.inkFaint)
                Spacer()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .overlay(alignment: .topLeading) {
            Button { dismiss() } label: {
                HStack(spacing: 2) {
                    Image(systemName: "chevron.left").font(.system(size: 20, weight: .semibold))
                    Text("返回").font(HHFont.journal(15))
                }
                .foregroundStyle(HHColor.inkSoft)
            }
            .buttonStyle(.plain)
            .padding(.leading, 16)
            .padding(.top, 60)
        }
    }
}
