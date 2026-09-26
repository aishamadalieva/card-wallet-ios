import Testing
@testable import CardFlow

@MainActor
@Suite("Add card view model")
struct AddCardViewModelTests {

    @Test("Input is formatted and capped while typing")
    func inputFormatting() {
        let viewModel = AddCardViewModel(repository: TestCardRepository()) { _ in }

        viewModel.updateCardNumber("4242424242424242")
        viewModel.updateExpirationDate("1230")
        viewModel.updateSecurityCode("12a345")

        #expect(viewModel.cardNumber == "4242 4242 4242 4242")
        #expect(viewModel.expirationDate == "12/30")
        #expect(viewModel.securityCode == "1234")
        #expect(viewModel.canAdd)
    }

    @Test("Adding a valid card invokes the completion")
    func addCardSucceeds() async {
        let repository = TestCardRepository()
        var receivedCard: Card?
        let viewModel = AddCardViewModel(repository: repository) {
            receivedCard = $0
        }
        enterValidCard(in: viewModel)

        let didAdd = await viewModel.addCard()

        #expect(didAdd)
        #expect(receivedCard == repository.addedCard)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isAdding == false)
    }

    @Test("Repository failure keeps the form and presents an error")
    func addCardFails() async {
        let repository = TestCardRepository()
        repository.failingOperations.insert(.add)
        let viewModel = AddCardViewModel(repository: repository) { _ in }
        enterValidCard(in: viewModel)

        let didAdd = await viewModel.addCard()

        #expect(didAdd == false)
        #expect(viewModel.errorMessage == "The card couldn’t be added. Please try again.")
        #expect(viewModel.cardNumber == "4242 4242 4242 4242")
        #expect(viewModel.isAdding == false)
    }

    private func enterValidCard(in viewModel: AddCardViewModel) {
        viewModel.updateCardNumber("4242424242424242")
        viewModel.updateExpirationDate("1299")
        viewModel.updateSecurityCode("123")
    }
}
