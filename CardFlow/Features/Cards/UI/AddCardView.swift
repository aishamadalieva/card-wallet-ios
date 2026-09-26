//
//  AddCardView.swift
//  CardFlow
//

import SwiftUI

struct AddCardView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @FocusState private var focusedField: Field?

    @State private var viewModel: AddCardViewModel

    init(viewModel: AddCardViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                cardInformation
                    .padding(16)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color(uiColor: .systemBackground))
            .safeAreaInset(edge: .bottom) {
                Text("Test cards only")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(16)
            }
            .navigationTitle("Add Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .interactiveDismissDisabled(viewModel.hasChanges || viewModel.isAdding)
            .alert(
                "Discard this card?",
                isPresented: $viewModel.showsDiscardConfirmation
            ) {
                Button("Discard", role: .destructive) {
                    dismiss()
                }
                Button("Keep Editing", role: .cancel) { }
            } message: {
                Text("The card information you entered will be lost.")
            }
            .alert("Unable to Add Card", isPresented: $viewModel.showsError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    private var cardInformation: some View {
        VStack(spacing: 12) {
            cardNumberField
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(fieldBackground)

            expirationAndSecurityLayout {
                expirationDateField
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(fieldBackground)

                securityCodeField
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(fieldBackground)
            }
        }
        .disabled(viewModel.isAdding)
    }

    private var expirationAndSecurityLayout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: 12))
            : AnyLayout(HStackLayout(alignment: .top, spacing: 12))
    }

    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color(uiColor: .secondarySystemBackground))
    }

    private var addButton: some View {
        Button {
            focusedField = nil
            Task {
                if await viewModel.addCard() {
                    dismiss()
                } else {
                    viewModel.showsError = viewModel.errorMessage != nil
                }
            }
        } label: {
            if viewModel.isAdding {
                ProgressView()
            } else {
                Text("Add")
            }
        }
        .accessibilityLabel(viewModel.isAdding ? "Adding card" : "Add card")
        .disabled(!viewModel.canAdd)
    }

    private var cardNumberField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Card number")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextField(
                "Card Number",
                text: cardNumberBinding,
                prompt: Text("4242 4242 4242 4242")
            )
            .keyboardType(.numberPad)
            .textContentType(.creditCardNumber)
            .focused($focusedField, equals: .cardNumber)
            .privacySensitive()

            if let cardNumberError = viewModel.cardNumberError(isEditing: focusedField == .cardNumber) {
                validationLabel(cardNumberError)
            }
        }
    }

    private var expirationDateField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Expires")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextField(
                "Expiration Date",
                text: expirationDateBinding,
                prompt: Text("MM/YY")
            )
            .keyboardType(.numberPad)
            .textContentType(.creditCardExpiration)
            .focused($focusedField, equals: .expirationDate)
            .privacySensitive()

            if let expirationDateError = viewModel.expirationDateError(isEditing: focusedField == .expirationDate) {
                validationLabel(expirationDateError)
            }
        }
    }

    private var securityCodeField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Security code")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            SecureField(
                "Security Code",
                text: securityCodeBinding,
                prompt: Text("CVV")
            )
            .keyboardType(.numberPad)
            .textContentType(.creditCardSecurityCode)
            .focused($focusedField, equals: .securityCode)
            .privacySensitive()

            if let securityCodeError = viewModel.securityCodeError(isEditing: focusedField == .securityCode) {
                validationLabel(securityCodeError)
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel", role: .cancel, action: cancel)
                .disabled(viewModel.isAdding)
        }

        ToolbarItem(placement: .confirmationAction) {
            addButton
        }

        ToolbarItemGroup(placement: .keyboard) {
            Spacer()

            Button("Done") {
                focusedField = nil
            }
        }
    }

    private func validationLabel(_ message: String) -> some View {
        Label(message, systemImage: "exclamationmark.circle.fill")
            .font(.caption)
            .foregroundStyle(.red)
            .accessibilityLabel("Error: \(message)")
    }

    private var cardNumberBinding: Binding<String> {
        Binding(
            get: { viewModel.cardNumber },
            set: viewModel.updateCardNumber
        )
    }

    private var expirationDateBinding: Binding<String> {
        Binding(
            get: { viewModel.expirationDate },
            set: viewModel.updateExpirationDate
        )
    }

    private var securityCodeBinding: Binding<String> {
        Binding(
            get: { viewModel.securityCode },
            set: viewModel.updateSecurityCode
        )
    }

    private func cancel() {
        focusedField = nil

        if viewModel.hasChanges {
            viewModel.showsDiscardConfirmation = true
        } else {
            dismiss()
        }
    }

    private enum Field {
        case cardNumber
        case expirationDate
        case securityCode
    }
}
