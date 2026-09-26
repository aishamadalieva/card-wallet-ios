//
//  AddCardViewModel.swift
//  CardFlow
//

import Foundation
import Observation

@MainActor
@Observable
final class AddCardViewModel {

    private let repository: CardRepositoryProtocol
    private let onAdded: (Card) -> Void

    private(set) var cardNumber = ""
    private(set) var expirationDate = ""
    private(set) var securityCode = ""

    private(set) var isAdding = false
    private(set) var errorMessage: String?

    var showsError = false
    var showsDiscardConfirmation = false

    init(repository: CardRepositoryProtocol, onAdded: @escaping (Card) -> Void) {
        self.repository = repository
        self.onAdded = onAdded
    }

    var canAdd: Bool {
        request != nil && !isAdding
    }

    var hasChanges: Bool {
        !cardNumber.isEmpty || !expirationDate.isEmpty || !securityCode.isEmpty
    }

    func updateCardNumber(_ value: String) {
        cardNumber = formattedCardNumber(value)
    }

    func updateExpirationDate(_ value: String) {
        expirationDate = formattedExpirationDate(value)
    }

    func updateSecurityCode(_ value: String) {
        securityCode = String(AddCardRequest.digits(in: value).prefix(4))
    }

    func cardNumberError(isEditing: Bool) -> String? {
        guard !cardNumber.isEmpty else { return nil }

        let number = AddCardRequest.digits(in: cardNumber)

        if number.count < 13 {
            return isEditing ? nil : "Enter the complete card number."
        }

        if AddCardRequest.isValidCardNumber(number) {
            return nil
        }

        return isEditing && number.count < 19 ? nil : "Enter a valid card number."
    }

    func expirationDateError(isEditing: Bool) -> String? {
        guard !expirationDate.isEmpty else { return nil }

        let expiration = AddCardRequest.digits(in: expirationDate)

        if expiration.count < 4 {
            return isEditing ? nil : "Enter the expiration date in MM/YY format."
        }

        guard let month = Int(expiration.prefix(2)),
              (1...12).contains(month) else {
            return "Enter a month from 01 to 12."
        }

        return AddCardRequest.isValidExpirationDate(expirationDate) ? nil : "This card has expired."
    }

    func securityCodeError(isEditing: Bool) -> String? {
        guard !securityCode.isEmpty else { return nil }

        if AddCardRequest.isValidSecurityCode(securityCode) {
            return nil
        }

        return isEditing ? nil : "Enter the 3- or 4-digit security code."
    }

    func addCard() async -> Bool {
        guard let request, !isAdding else { return false }

        isAdding = true
        errorMessage = nil

        defer {
            isAdding = false
        }

        do {
            let card = try await repository.addCard(request)
            onAdded(card)
            return true
        } catch is CancellationError {
            return false
        } catch {
            errorMessage = "The card couldn’t be added. Please try again."
            return false
        }
    }

    private var request: AddCardRequest? {
        AddCardRequest(
            cardNumber: cardNumber,
            expirationDate: expirationDate,
            securityCode: securityCode
        )
    }

    private func formattedCardNumber(_ value: String) -> String {
        let digits = AddCardRequest.digits(in: value).prefix(19)
        return stride(from: 0, to: digits.count, by: 4)
            .map { index in
                let start = digits.index(digits.startIndex, offsetBy: index)
                let end = digits.index(start, offsetBy: min(4, digits.distance(from: start, to: digits.endIndex)))
                return String(digits[start..<end])
            }
            .joined(separator: " ")
    }

    private func formattedExpirationDate(_ value: String) -> String {
        let digits = String(AddCardRequest.digits(in: value).prefix(4))

        guard digits.count > 2 else {
            return digits
        }

        return "\(digits.prefix(2))/\(digits.dropFirst(2))"
    }
}
