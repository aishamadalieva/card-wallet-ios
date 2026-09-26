import Foundation
@testable import CardFlow

@MainActor
final class TestCardRepository: CardRepositoryProtocol {

    enum Operation: Hashable {
        case fetchCards
        case fetchDetails
        case add
        case updateStatus
        case makePrimary
        case remove
    }

    var failingOperations: Set<Operation> = []
    var cards: [Card] = TestCardRepository.sampleCards
    var details: [Card.ID: CardDetails] = TestCardRepository.sampleDetails
    var addedCard = Card(
        id: 3,
        name: "Pearl",
        status: .active,
        design: .pearl,
        isPrimary: false
    )

    func fetchCards() async throws -> [Card] {
        try throwIfNeeded(.fetchCards)
        return cards
    }

    func fetchCardDetails(for cardID: Card.ID) async throws -> CardDetails {
        try throwIfNeeded(.fetchDetails)

        guard let details = details[cardID] else {
            throw TestError.cardNotFound
        }

        return details
    }

    func addCard(_ request: AddCardRequest) async throws -> Card {
        try throwIfNeeded(.add)
        cards.insert(addedCard, at: max(cards.count - 1, 0))
        return addedCard
    }

    func updateStatus(_ status: CardStatus, for cardID: Card.ID) async throws {
        try throwIfNeeded(.updateStatus)

        guard let index = cards.firstIndex(where: { $0.id == cardID }) else {
            throw TestError.cardNotFound
        }

        cards[index].status = status
    }

    func makePrimary(_ cardID: Card.ID) async throws {
        try throwIfNeeded(.makePrimary)

        guard let index = cards.firstIndex(where: { $0.id == cardID }) else {
            throw TestError.cardNotFound
        }

        for cardIndex in cards.indices {
            cards[cardIndex].isPrimary = false
        }

        var card = cards.remove(at: index)
        card.isPrimary = true
        cards.append(card)
    }

    func removeCard(_ cardID: Card.ID) async throws {
        try throwIfNeeded(.remove)

        guard let index = cards.firstIndex(where: { $0.id == cardID }) else {
            throw TestError.cardNotFound
        }

        cards.remove(at: index)
        details[cardID] = nil
    }

    private func throwIfNeeded(_ operation: Operation) throws {
        if failingOperations.contains(operation) {
            throw TestError.forcedFailure
        }
    }

    static let sampleCards = [
        Card(
            id: 1,
            name: "Apex",
            status: .active,
            design: .apex,
            isPrimary: false
        ),
        Card(
            id: 2,
            name: "Nova",
            status: .active,
            design: .nova,
            isPrimary: true
        )
    ]

    static let sampleDetails = [
        1: CardDetails(
            cardID: 1,
            last4: "4242",
            expirationDate: "12/30",
            balance: 100,
            currencyCode: "USD"
        ),
        2: CardDetails(
            cardID: 2,
            last4: "6502",
            expirationDate: "09/31",
            balance: 250,
            currencyCode: "USD"
        )
    ]

    enum TestError: Error {
        case cardNotFound
        case forcedFailure
    }
}
