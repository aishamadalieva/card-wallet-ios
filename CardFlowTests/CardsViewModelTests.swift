import Testing
@testable import CardFlow

@MainActor
@Suite("Cards view model")
struct CardsViewModelTests {

    @Test("Loading cards publishes repository data")
    func loadCardsSucceeds() async {
        let repository = TestCardRepository()
        let viewModel = CardsViewModel(repository: repository)

        await viewModel.loadCards()

        #expect(viewModel.cards == TestCardRepository.sampleCards)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLoading == false)
    }

    @Test("Loading cards exposes a recoverable error")
    func loadCardsFails() async {
        let repository = TestCardRepository()
        repository.failingOperations.insert(.fetchCards)
        let viewModel = CardsViewModel(repository: repository)

        await viewModel.loadCards()

        #expect(viewModel.cards.isEmpty)
        #expect(viewModel.errorMessage == "Failed to load cards.")
        #expect(viewModel.isLoading == false)
    }

    @Test("Loading details publishes only the selected card details")
    func loadSelectedCardDetails() async {
        let repository = TestCardRepository()
        let viewModel = CardsViewModel(repository: repository)
        viewModel.selectedCardID = 1

        await viewModel.loadCardDetails(for: 1)

        #expect(viewModel.selectedCardDetails == TestCardRepository.sampleDetails[1])
        #expect(viewModel.cardDetailsErrorMessage == nil)
        #expect(viewModel.isLoadingCardDetails == false)
    }

    @Test("A failed status update keeps the current status")
    func failedStatusUpdateDoesNotMutateCard() async {
        let repository = TestCardRepository()
        repository.failingOperations.insert(.updateStatus)
        let viewModel = CardsViewModel(repository: repository)
        await viewModel.loadCards()

        await viewModel.toggleFrozenState(for: 1)

        #expect(viewModel.cards.first?.status == .active)
        #expect(viewModel.showsCardActionError)
    }

    @Test("A failed removal restores cards and selection")
    func failedRemovalRollsBack() async {
        let repository = TestCardRepository()
        repository.failingOperations.insert(.remove)
        let viewModel = CardsViewModel(repository: repository)
        await viewModel.loadCards()
        viewModel.selectedCardID = 1
        await viewModel.loadCardDetails(for: 1)

        viewModel.removeCard(1)
        #expect(viewModel.cards.count == 1)
        #expect(viewModel.selectedCardID == nil)

        await viewModel.persistRemoval(of: 1)

        #expect(viewModel.cards == TestCardRepository.sampleCards)
        #expect(viewModel.selectedCardID == 1)
        #expect(viewModel.selectedCardDetails == TestCardRepository.sampleDetails[1])
        #expect(viewModel.showsCardActionError)
    }
}
