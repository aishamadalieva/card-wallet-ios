import SwiftData
import Testing
@testable import CardFlow

@MainActor
@Suite("SwiftData card repository")
struct SwiftDataCardRepositoryTests {

    @Test("Initial cards are seeded once with one default card")
    func seedDataIsStable() async throws {
        let (repository, _) = try makeRepository()

        let firstFetch = try await repository.fetchCards()
        let secondFetch = try await repository.fetchCards()

        #expect(firstFetch.count == 6)
        #expect(secondFetch == firstFetch)
        #expect(firstFetch.filter(\.isPrimary).count == 1)
        #expect(firstFetch.last?.isPrimary == true)
    }

    @Test("Adding a card persists safe display details")
    func addCardPersistsDisplayDetails() async throws {
        let (repository, _) = try makeRepository()
        let request = try #require(
            AddCardRequest(
                cardNumber: "4242 4242 4242 4242",
                expirationDate: "12/99",
                securityCode: "123"
            )
        )

        let card = try await repository.addCard(request)
        let cards = try await repository.fetchCards()
        let details = try await repository.fetchCardDetails(for: card.id)

        #expect(card.design == .pearl)
        #expect(cards.count == 7)
        #expect(cards[cards.count - 2].id == card.id)
        #expect(details.last4 == "4242")
        #expect(details.expirationDate == "12/99")
        #expect(details.balance == 0)
    }

    @Test("Status updates persist")
    func statusUpdatePersists() async throws {
        let (repository, _) = try makeRepository()
        let initialCards = try await repository.fetchCards()
        let cardID = try #require(initialCards.first?.id)

        try await repository.updateStatus(.frozen, for: cardID)
        let updatedCards = try await repository.fetchCards()
        let card = try #require(updatedCards.first { $0.id == cardID })

        #expect(card.status == .frozen)
    }

    @Test("Changing the default card updates order and uniqueness")
    func makePrimaryPersists() async throws {
        let (repository, _) = try makeRepository()
        let initialCards = try await repository.fetchCards()
        let cardID = try #require(initialCards.first?.id)

        try await repository.makePrimary(cardID)
        let cards = try await repository.fetchCards()

        #expect(cards.last?.id == cardID)
        #expect(cards.filter(\.isPrimary).map(\.id) == [cardID])
    }

    @Test("Removing the default card selects the last remaining card")
    func removingPrimaryCardSelectsReplacement() async throws {
        let (repository, _) = try makeRepository()
        let initialCards = try await repository.fetchCards()
        let primaryID = try #require(initialCards.last?.id)

        try await repository.removeCard(primaryID)
        let cards = try await repository.fetchCards()

        #expect(cards.contains { $0.id == primaryID } == false)
        #expect(cards.last?.isPrimary == true)
        #expect(cards.filter(\.isPrimary).count == 1)
    }

    @Test("Removing every card does not trigger reseeding")
    func emptyStoreDoesNotReseed() async throws {
        let (repository, container) = try makeRepository()

        for card in try await repository.fetchCards() {
            try await repository.removeCard(card.id)
        }

        let secondRepository = SwiftDataCardRepository(modelContainer: container)
        let remainingCards = try await secondRepository.fetchCards()
        #expect(remainingCards.isEmpty)
    }

    private func makeRepository() throws -> (SwiftDataCardRepository, ModelContainer) {
        let container = try PersistenceContainerFactory.make(isStoredInMemoryOnly: true)
        return (SwiftDataCardRepository(modelContainer: container), container)
    }
}
