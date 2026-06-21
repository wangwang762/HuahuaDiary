//
//  PaperCanvas.swift
//  HuahuaDiary
//
//  The cream-paper canvas filling the screen, with a faint paper grain.
//  Matches CSS .canvas + .canvas::before grain.
//

import SwiftUI

struct PaperCanvas: View {
    var body: some View {
        ZStack {
            HHColor.canvasGradient
                .ignoresSafeArea()
            PaperGrain()
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
    }
}

private struct PaperGrain: View {
    var body: some View {
        Canvas { ctx, size in
            let cols = Int(size.width / 7)
            let rows = Int(size.height / 7)
            for r in 0..<rows {
                for c in 0..<cols {
                    // Two interleaved grain points per cell — barely-visible specks.
                    let x = CGFloat(c) * 7 + CGFloat((c * 13 + r * 7) % 5)
                    let y = CGFloat(r) * 7 + CGFloat((c * 5 + r * 11) % 5)
                    let alpha = Double((c &+ r * 17) % 10) / 100.0 + 0.05
                    ctx.fill(
                        Path(ellipseIn: CGRect(x: x, y: y, width: 0.7, height: 0.7)),
                        with: .color(Color.white.opacity(alpha * 0.35))
                    )
                }
            }
        }
        .opacity(0.5)
    }
}
