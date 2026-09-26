//
//  CardDetailsLoadingView.swift
//  CardFlow
//

import SwiftUI

struct CardDetailsLoadingView: View {

    let isPrimary: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            balancePlaceholder
            detailsPlaceholder
            actionsPlaceholder
        }
        .padding(.bottom, 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Loading card details")
    }

    private var balancePlaceholder: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                placeholder(width: 120, height: 14)
                placeholder(width: 150, height: 28)
            }

            Spacer()

            placeholder(width: 72, height: 22)
        }
        .padding(.horizontal, 4)
    }

    private var detailsPlaceholder: some View {
        VStack(spacing: 0) {
            placeholderRow(labelWidth: 110, valueWidth: 72)
            Divider()
            placeholderRow(labelWidth: 64, valueWidth: 48)

            if isPrimary {
                Divider()
                placeholderRow(labelWidth: 100, valueWidth: 28)
            }
        }
        .padding(.horizontal, 16)
        .background(sectionBackground)
    }

    private var actionsPlaceholder: some View {
        VStack(alignment: .leading, spacing: 12) {
            placeholder(width: 68, height: 18)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                actionPlaceholder(width: 104)
                Divider()

                if !isPrimary {
                    actionPlaceholder(width: 150)
                    Divider()
                }

                actionPlaceholder(width: 112)
            }
            .padding(.horizontal, 16)
            .background(sectionBackground)
        }
    }

    private func placeholderRow(labelWidth: CGFloat, valueWidth: CGFloat) -> some View {
        HStack {
            placeholder(width: labelWidth, height: 16)
            Spacer()
            placeholder(width: valueWidth, height: 16)
        }
        .frame(minHeight: 52)
    }

    private func actionPlaceholder(width: CGFloat) -> some View {
        HStack(spacing: 12) {
            placeholder(width: 22, height: 22)
            placeholder(width: width, height: 17)
        }
        .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
    }

    private func placeholder(width: CGFloat, height: CGFloat) -> some View {
        Capsule()
            .fill(Color(uiColor: .tertiarySystemFill))
            .shimmering()
            .frame(width: width, height: height)
    }

    private var sectionBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color(uiColor: .secondarySystemBackground))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color(uiColor: .separator).opacity(0.25), lineWidth: 0.5)
            }
    }
}
