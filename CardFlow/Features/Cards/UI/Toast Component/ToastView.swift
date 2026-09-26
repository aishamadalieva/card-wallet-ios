//
//  ToastView.swift
//  CardFlow
//

import SwiftUI

struct ToastView: View {
    let message: String
    let tone: ToastTone

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: iconName)
                .foregroundStyle(iconColor)

            Text(message)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
        }
        .font(.subheadline.weight(.semibold))
        .padding(.horizontal, 18)
        .padding(.vertical, 13)
        .background(.regularMaterial, in: .capsule)
        .overlay {
            Capsule()
                .stroke(.separator.opacity(0.2), lineWidth: 0.5)
        }
        .padding(.horizontal, 16)
        .accessibilityElement(children: .combine)
    }

    private var iconName: String {
        tone == .success ? "checkmark.circle.fill" : "exclamationmark.triangle.fill"
    }

    private var iconColor: Color {
        tone == .success ? .green : .red
    }
}
