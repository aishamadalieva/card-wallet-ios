//
//  SwiftDataCardRepository.swift
//  CardFlow
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataCardRepository: CardRepositoryProtocol {

    private let store: SwiftDataCardStore

    init(modelContainer: ModelContainer) {
        store = SwiftDataCardStore(modelContainer: modelContainer)
    }

    func fetchCards() async throws -> [Card] {
        try await store.fetchCards()
    }

    func fetchCardDetails(for cardID: Card.ID) async throws -> CardDetails {
        try await store.fetchCardDetails(for: cardID)
    }

    func addCard(_ request: AddCardRequest) async throws -> Card {
        try await store.addCard(
            leadingDigit: request.cardNumber.first?.wholeNumberValue ?? 0,
            last4: request.last4,
            expirationDate: request.formattedExpirationDate,
            currencyCode: Locale.current.currency?.identifier ?? "USD"
        )
    }

    func updateStatus(_ status: CardStatus, for cardID: Card.ID) async throws {
        try await store.updateStatus(status, for: cardID)
    }

    func makePrimary(_ cardID: Card.ID) async throws {
        try await store.makePrimary(cardID)
    }

    func removeCard(_ cardID: Card.ID) async throws {
        try await store.removeCard(cardID)
    }
}
