//
//  CardDetailsView.swift
//  CardFlow
//

import SwiftUI

struct CardDetailsView: View {

    let card: Card
    let details: CardDetails
    let isPrimary: Bool
    let onToggleFrozen: () -> Void
    let onMakePrimary: () -> Void
    let onRemove: () -> Void

    @State private var showsRemovalConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            balanceSection
            detailsSection
            actionsSection
        }
        .padding(.bottom, 8)
        .alert(
            "Remove \(card.name)?",
            isPresented: $showsRemovalConfirmation
        ) {
            Button("Remove Card", role: .destructive, action: onRemove)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This card will no longer appear in your cards.")
        }
    }

    private var balanceSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Available balance")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(details.balance, format: .currency(code: details.currencyCode))
                    .font(.title2.weight(.semibold))
                    .contentTransition(.numericText())
            }

            Spacer()

            Label(statusTitle, systemImage: statusImage)
                .font(.caption.weight(.semibold))
                .foregroundStyle(statusColor)
        }
        .padding(.horizontal, 4)
    }

    private var detailsSection: some View {
        VStack(spacing: 0) {
            detailRow("Card number", value: "•••• \(details.last4)")
            Divider()
            detailRow("Expires", value: details.expirationDate)

            if isPrimary {
                Divider()
                detailRow("Default card", value: "Yes")
            }
        }
        .padding(.horizontal, 16)
        .background(sectionBackground)
        .accessibilityElement(children: .contain)
    }

    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Actions")
                .font(.headline)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                if card.status != .expired {
                    actionButton(
                        card.status == .frozen ? "Unfreeze Card" : "Freeze Card",
                        systemImage: card.status == .frozen ? "sun.max" : "snowflake",
                        action: onToggleFrozen
                    )

                    Divider()

                    if !isPrimary && card.status == .active {
                        actionButton(
                            "Set as Default Card",
                            systemImage: "checkmark.circle",
                            action: onMakePrimary
                        )

                        Divider()
                    }
                }

                Button(role: .destructive) {
                    showsRemovalConfirmation = true
                } label: {
                    actionLabel("Remove Card", systemImage: "trash")
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .background(sectionBackground)
        }
    }

    private func actionButton(
        _ title: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            actionLabel(title, systemImage: systemImage)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
    }

    private func actionLabel(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
            .contentShape(.rect)
    }

    private func detailRow(_ title: String, value: String) -> some View {
        LabeledContent(title, value: value)
            .frame(minHeight: 52)
    }

    private var sectionBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color(uiColor: .secondarySystemBackground))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color(uiColor: .separator).opacity(0.25), lineWidth: 0.5)
            }
    }

    private var statusTitle: String {
        switch card.status {
        case .active:
            "Active"
        case .frozen:
            "Frozen"
        case .expired:
            "Expired"
        }
    }

    private var statusImage: String {
        switch card.status {
        case .active:
            "checkmark.circle.fill"
        case .frozen:
            "snowflake"
        case .expired:
            "exclamationmark.circle.fill"
        }
    }

    private var statusColor: Color {
        switch card.status {
        case .active:
            .green
        case .frozen:
            .blue
        case .expired:
            .red
        }
    }
}
