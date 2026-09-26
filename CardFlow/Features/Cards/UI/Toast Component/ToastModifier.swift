//
//  ToastModifier.swift
//  CardFlow
//

import SwiftUI

struct ToastPresenter: ViewModifier {
    @Binding var isPresented: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let message: String
    let tone: ToastTone
    let placement: ToastPlacement
    let configuration: ToastConfiguration

    func body(content: Content) -> some View {
        content
            .overlay(alignment: alignment) {
                if isPresented {
                    ToastView(message: message, tone: tone)
                        .padding(paddingEdge, 24)
                        .transition(toastTransition)
                        .allowsHitTesting(false)
                }
            }
            .animation(reduceMotion ? nil : configuration.animation, value: isPresented)
            .task(id: isPresented) {
                guard isPresented else { return }

                AccessibilityNotification.Announcement(message).post()
                let duration = max(configuration.displayDuration, 0)

                guard duration > 0 else {
                    isPresented = false
                    return
                }

                do {
                    try await Task.sleep(for: .seconds(duration))
                    try Task.checkCancellation()
                    isPresented = false
                } catch {
                    return
                }
            }
            .sensoryFeedback(.selection, trigger: isPresented) { _, newValue in
                configuration.usesHaptics && newValue
            }
    }

    private var alignment: Alignment {
        placement == .top ? .top : .bottom
    }

    private var paddingEdge: Edge.Set {
        placement == .top ? .top : .bottom
    }

    private var toastTransition: AnyTransition {
        guard !reduceMotion else { return .opacity }

        let edge: Edge = placement == .top ? .top : .bottom
        return .move(edge: edge).combined(with: .opacity)
    }
}
