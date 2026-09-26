//
//  MockCardRepository.swift
//  CardFlow
//

import Foundation

final class MockCardRepository: CardRepositoryProtocol {

    enum Mode {
        case success
        case cardsError
        case detailsError
        case addCardError
        case empty
    }

    let mode: Mode
    private var cards: [Card]
    private var cardDetails: [Card.ID: CardDetails]
    private var nextCardID: Card.ID

    init(mode: Mode = .success) {
        self.mode = mode
        cards = Self.initialCards
        cardDetails = Self.initialCardDetails
        nextCardID = (Self.initialCards.map(\.id).max() ?? 0) + 1
    }

    func fetchCards() async throws -> [Card] {
        try await Task.sleep(for: .milliseconds(500))

        switch mode {
        case .cardsError:
            throw MockError.simulatedFailure
        case .empty:
            return []
        default:
            return cards
        }
    }

    func fetchCardDetails(for cardID: Card.ID) async throws -> CardDetails {
        try await Task.sleep(for: .milliseconds(500))

        if case .detailsError = mode {
            throw MockError.simulatedFailure
        }

        guard let details = cardDetails[cardID] else {
            throw MockError.cardNotFound
        }

        return details
    }

    func addCard(_ request: AddCardRequest) async throws -> Card {
        try await Task.sleep(for: .milliseconds(500))

        if case .addCardError = mode {
            throw MockError.simulatedFailure
        }

        let id = nextCardID
        nextCardID += 1

        let configuration = cardConfiguration(for: request.cardNumber)
        let card = Card(
            id: id,
            name: configuration.name,
            status: .active,
            design: configuration.design,
            isPrimary: cards.isEmpty
        )

        if let primaryIndex = cards.firstIndex(where: \.isPrimary) {
            cards.insert(card, at: primaryIndex)
        } else {
            cards.append(card)
        }

        cardDetails[id] = CardDetails(
            cardID: id,
            last4: request.last4,
            expirationDate: request.formattedExpirationDate,
            balance: 0,
            currencyCode: Locale.current.currency?.identifier ?? "USD"
        )

        return card
    }

    func updateStatus(_ status: CardStatus, for cardID: Card.ID) async throws {
        guard let index = cards.firstIndex(where: { $0.id == cardID }) else {
            throw MockError.cardNotFound
        }

        cards[index].status = status
    }

    func makePrimary(_ cardID: Card.ID) async throws {
        guard let index = cards.firstIndex(where: { $0.id == cardID }) else {
            throw MockError.cardNotFound
        }

        for cardIndex in cards.indices {
            cards[cardIndex].isPrimary = false
        }

        var card = cards.remove(at: index)
        card.isPrimary = true
        cards.append(card)
    }

    func removeCard(_ cardID: Card.ID) async throws {
        guard let index = cards.firstIndex(where: { $0.id == cardID }) else {
            throw MockError.cardNotFound
        }

        let removedCard = cards.remove(at: index)
        cardDetails[cardID] = nil

        if removedCard.isPrimary, !cards.isEmpty {
            cards[cards.index(before: cards.endIndex)].isPrimary = true
        }
    }

    private func cardConfiguration(for cardNumber: String) -> (name: String, design: CardDesign) {
        switch cardNumber.first?.wholeNumberValue ?? 0 {
        case 0, 1:
            ("Apex", .apex)
        case 2, 3:
            ("Flux", .flux)
        case 4:
            ("Pearl", .pearl)
        case 5, 6:
            ("Vertex", .vertex)
        case 7, 8:
            ("Split", .split)
        default:
            ("Nova", .nova)
        }
    }

    private static let initialCards: [Card] = [
        Card(id: 1, name: "Apex", status: .active, design: .apex, isPrimary: false),
        Card(id: 2, name: "Flux", status: .active, design: .flux, isPrimary: false),
        Card(id: 4, name: "Pearl", status: .active, design: .pearl, isPrimary: false),
        Card(id: 5, name: "Vertex", status: .active, design: .vertex, isPrimary: false),
        Card(id: 7, name: "Split", status: .active, design: .split, isPrimary: false),
        Card(id: 8, name: "Nova", status: .active, design: .nova, isPrimary: true)
    ]

    private static let initialCardDetails: [Card.ID: CardDetails] = [
        1: CardDetails(cardID: 1, last4: "4821", expirationDate: "09/29", balance: 4_820.40, currencyCode: "USD"),
        2: CardDetails(cardID: 2, last4: "1934", expirationDate: "04/30", balance: 1_275.80, currencyCode: "USD"),
        4: CardDetails(cardID: 4, last4: "0804", expirationDate: "11/28", balance: 550.25, currencyCode: "USD"),
        5: CardDetails(cardID: 5, last4: "4418", expirationDate: "07/31", balance: 8_240.10, currencyCode: "USD"),
        7: CardDetails(cardID: 7, last4: "3117", expirationDate: "02/30", balance: 740.20, currencyCode: "USD"),
        8: CardDetails(cardID: 8, last4: "6502", expirationDate: "12/29", balance: 1_460.00, currencyCode: "USD")
    ]

    private enum MockError: Error {
        case simulatedFailure
        case cardNotFound
    }
}
