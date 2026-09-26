//
//  CardsViewModel.swift
//  CardFlow
//

import Foundation
import Observation

@MainActor
@Observable
final class CardsViewModel {

    private let repository: CardRepositoryProtocol
    private var pendingActionCardIDs: Set<Card.ID> = []
    private var removalRollbacks: [Card.ID: RemovalRollback] = [:]

    private(set) var cards: [Card] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var selectedCardDetails: CardDetails?
    private(set) var isLoadingCardDetails = false
    private(set) var cardDetailsErrorMessage: String?

    enum LayoutStyle {
        case stack
        case list
    }

    var selectedCardID: Card.ID?
    var layoutStyle: LayoutStyle = .stack
    var showsAddCard = false
    var didAddCard = false
    var showsCardAddedToast = false
    var showsCardRemovedToast = false
    var showsCardActionError = false

    private(set) var cardAddedToastMessage = "Card added"
    private(set) var cardRemovedToastMessage = "Card removed"
    private(set) var cardActionErrorMessage = "The card couldn’t be updated. Try again."

    init(repository: CardRepositoryProtocol) {
        self.repository = repository
    }

    func loadCards() async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            cards = try await repository.fetchCards()
        } catch is CancellationError {
            return
        } catch {
            errorMessage = "Failed to load cards."
        }
    }

    func loadCardDetails(for cardID: Card.ID) async {
        selectedCardDetails = nil
        cardDetailsErrorMessage = nil
        isLoadingCardDetails = true

        defer {
            if selectedCardID == cardID {
                isLoadingCardDetails = false
            }
        }

        do {
            let details = try await repository.fetchCardDetails(for: cardID)
            try Task.checkCancellation()

            guard selectedCardID == cardID else {
                return
            }

            selectedCardDetails = details
        } catch is CancellationError {
            return
        } catch {
            guard selectedCardID == cardID else {
                return
            }

            cardDetailsErrorMessage = "Failed to load card details."
        }
    }

    func clearCardDetails() {
        selectedCardDetails = nil
        cardDetailsErrorMessage = nil
        isLoadingCardDetails = false
    }

    func didAddCard(_ card: Card) {
        cardAddedToastMessage = "\(card.name) card added"

        if let primaryIndex = cards.firstIndex(where: \.isPrimary) {
            cards.insert(card, at: primaryIndex)
        } else {
            cards.append(card)
        }
    }

    func toggleFrozenState(for cardID: Card.ID) async {
        guard let index = cards.firstIndex(where: { $0.id == cardID }),
              cards[index].status != .expired,
              pendingActionCardIDs.insert(cardID).inserted else {
            return
        }

        defer {
            pendingActionCardIDs.remove(cardID)
        }

        let newStatus: CardStatus = cards[index].status == .frozen ? .active : .frozen

        do {
            try await repository.updateStatus(newStatus, for: cardID)
            if let updatedIndex = cards.firstIndex(where: { $0.id == cardID }) {
                cards[updatedIndex].status = newStatus
            }
        } catch is CancellationError {
            return
        } catch {
            presentActionError("The card status couldn’t be updated. Try again.")
        }
    }

    func makePrimary(_ cardID: Card.ID) async {
        guard let index = cards.firstIndex(where: { $0.id == cardID }),
              !cards[index].isPrimary,
              cards[index].status == .active,
              pendingActionCardIDs.insert(cardID).inserted else {
            return
        }

        defer {
            pendingActionCardIDs.remove(cardID)
        }

        do {
            try await repository.makePrimary(cardID)

            for cardIndex in cards.indices {
                cards[cardIndex].isPrimary = false
            }

            guard let updatedIndex = cards.firstIndex(where: { $0.id == cardID }) else {
                return
            }

            var card = cards.remove(at: updatedIndex)
            card.isPrimary = true
            cards.append(card)
        } catch is CancellationError {
            return
        } catch {
            presentActionError("The default card couldn’t be changed. Try again.")
        }
    }

    func removeCard(_ cardID: Card.ID) {
        guard let index = cards.firstIndex(where: { $0.id == cardID }) else {
            return
        }

        guard pendingActionCardIDs.insert(cardID).inserted else {
            return
        }

        removalRollbacks[cardID] = RemovalRollback(
            cards: cards,
            selectedCardID: selectedCardID,
            selectedCardDetails: selectedCardDetails,
            cardDetailsErrorMessage: cardDetailsErrorMessage
        )
        cardRemovedToastMessage = "\(cards[index].name) card removed"

        if selectedCardID == cardID {
            selectedCardID = nil
            clearCardDetails()
        }

        let removedCard = cards.remove(at: index)

        if removedCard.isPrimary, !cards.isEmpty {
            cards[cards.index(before: cards.endIndex)].isPrimary = true
        }
    }

    func persistRemoval(of cardID: Card.ID) async {
        guard pendingActionCardIDs.contains(cardID),
              let rollback = removalRollbacks[cardID] else {
            return
        }

        defer {
            pendingActionCardIDs.remove(cardID)
            removalRollbacks[cardID] = nil
        }

        do {
            try await repository.removeCard(cardID)
        } catch is CancellationError {
            restoreRemoval(rollback)
        } catch {
            restoreRemoval(rollback)
            presentActionError("The card couldn’t be removed. Try again.")
        }
    }

    private func restoreRemoval(_ rollback: RemovalRollback) {
        cards = rollback.cards
        selectedCardID = rollback.selectedCardID
        selectedCardDetails = rollback.selectedCardDetails
        cardDetailsErrorMessage = rollback.cardDetailsErrorMessage
    }

    private func presentActionError(_ message: String) {
        cardActionErrorMessage = message
        showsCardActionError = true
    }

    private struct RemovalRollback {
        let cards: [Card]
        let selectedCardID: Card.ID?
        let selectedCardDetails: CardDetails?
        let cardDetailsErrorMessage: String?
    }
}
