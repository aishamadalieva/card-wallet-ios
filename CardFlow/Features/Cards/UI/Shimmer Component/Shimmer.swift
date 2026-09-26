//
//  Shimmer.swift
//  CardFlow
//

import SwiftUI

struct ShimmerModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let cycleDuration: TimeInterval = 1.8

    func body(content: Content) -> some View {
        content
            .overlay {
                if !reduceMotion {
                    TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
                        GeometryReader { geometry in
                            highlight(
                                size: geometry.size,
                                progress: progress(at: context.date)
                            )
                        }
                    }
                    .mask(content)
                    .allowsHitTesting(false)
                }
            }
    }

    private func highlight(size: CGSize, progress: Double) -> some View {
        LinearGradient(
            colors: [
                .clear,
                .white.opacity(0.08),
                .white.opacity(0.32),
                .white.opacity(0.08),
                .clear
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(width: max(size.width * 0.7, 80), height: size.height * 1.5)
        .rotationEffect(.degrees(8))
        .offset(
            x: (-size.width * 0.85) + (size.width * 1.7 * progress),
            y: -size.height * 0.25
        )
    }

    private func progress(at date: Date) -> Double {
        date.timeIntervalSinceReferenceDate
            .truncatingRemainder(dividingBy: cycleDuration) / cycleDuration
    }
}

extension View {
    func shimmering() -> some View {
        modifier(ShimmerModifier())
    }
}
