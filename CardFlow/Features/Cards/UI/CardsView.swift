//
//  CardsView.swift
//  CardFlow
//

import SwiftUI

struct CardsView: View {

    private let assembly: CardsFeatureAssemblyProtocol
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - ViewModel
    @State private var viewModel: CardsViewModel
    @State private var showsCardDetailsLoading = false

    init(viewModel: CardsViewModel, assembly: CardsFeatureAssemblyProtocol) {
        _viewModel = State(initialValue: viewModel)
        self.assembly = assembly
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            content
            .navigationTitle(viewModel.selectedCardID == nil ? "Cards" : "")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                if !viewModel.cards.isEmpty {
                    toolbarContent
                }
            }
            .task {
                await viewModel.loadCards()
            }
            .task(id: viewModel.selectedCardID) {
                showsCardDetailsLoading = false

                guard let selectedCardID = viewModel.selectedCardID else {
                    viewModel.clearCardDetails()
                    return
                }

                showsCardDetailsLoading = true
                async let loadDetails: Void = viewModel.loadCardDetails(for: selectedCardID)

                try? await Task.sleep(for: .milliseconds(500))
                await loadDetails

                guard !Task.isCancelled,
                      viewModel.selectedCardID == selectedCardID else {
                    return
                }

                showsCardDetailsLoading = false
            }
        }
        .toast(viewModel.cardAddedToastMessage, isPresented: $viewModel.showsCardAddedToast)
        .toast(viewModel.cardRemovedToastMessage, isPresented: $viewModel.showsCardRemovedToast)
        .alert(
            "Unable to Update Card",
            isPresented: $viewModel.showsCardActionError
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.cardActionErrorMessage)
        }
        .onChange(of: viewModel.showsAddCard) { _, isPresented in
            if isPresented {
                viewModel.showsCardAddedToast = false
                viewModel.showsCardRemovedToast = false
                viewModel.didAddCard = false
            }
        }
        .sheet(isPresented: $viewModel.showsAddCard, onDismiss: {
            if viewModel.didAddCard {
                viewModel.showsCardRemovedToast = false
                viewModel.showsCardAddedToast = true
                viewModel.didAddCard = false
            }
        }) {
            assembly.assembleAddCardScreen { card in
                viewModel.didAddCard(card)
                viewModel.didAddCard = true
            }
        }
    }

    // MARK: - Privates
    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.cards.isEmpty {
            CardsLoadingView()
        } else if let errorMessage = viewModel.errorMessage,
                  viewModel.cards.isEmpty {
            errorView(message: errorMessage)
        } else if viewModel.cards.isEmpty {
            emptyView
        } else {
            loadedContent
        }
    }

    private var loadedContent: some View {
        ScrollView(.vertical) {
            VStack(spacing: 24) {
                CardStackView(
                    cards: viewModel.cards,
                    selectedCardID: $viewModel.selectedCardID,
                    layoutStyle: viewModel.layoutStyle
                )
                .frame(
                    height: viewModel.selectedCardID == nil ? nil : 220,
                    alignment: .top
                )

                if let selectedCard {
                    cardDetailsContent(for: selectedCard)
                        .transition(.identity)
                }
            }
        }
        .scrollIndicators(.hidden)
        .safeAreaPadding(16)
    }

    private var emptyView: some View {
        ContentUnavailableView {
            Label("No Cards Yet", systemImage: "creditcard")
        } description: {
            Text("Add a payment card to manage it and choose a default card.")
        } actions: {
            Button("Add Card", systemImage: "plus") {
                viewModel.showsAddCard = true
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private func errorView(message: String) -> some View {
        ContentUnavailableView {
            Label("Unable to Load Cards", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Try Again") {
                Task {
                    await viewModel.loadCards()
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var selectedCard: Card? {
        viewModel.cards.first { $0.id == viewModel.selectedCardID }
    }

    @ViewBuilder
    private func cardDetailsContent(for card: Card) -> some View {
        if showsCardDetailsLoading || viewModel.isLoadingCardDetails {
            CardDetailsLoadingView(
                isPrimary: card.isPrimary
            )
        } else if let errorMessage = viewModel.cardDetailsErrorMessage {
            ContentUnavailableView {
                Label("Unable to Load Details", systemImage: "exclamationmark.triangle")
            } description: {
                Text(errorMessage)
            } actions: {
                Button("Try Again") {
                    Task {
                        await viewModel.loadCardDetails(for: card.id)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        } else if let details = viewModel.selectedCardDetails,
                  details.cardID == card.id {
            CardDetailsView(
                card: card,
                details: details,
                isPrimary: card.isPrimary,
                onToggleFrozen: {
                    Task {
                        await viewModel.toggleFrozenState(for: card.id)
                    }
                },
                onMakePrimary: {
                    Task {
                        await viewModel.makePrimary(card.id)
                    }
                },
                onRemove: {
                    removeCard(card.id)
                }
            )
        }
    }

    private func removeCard(_ cardID: Card.ID) {
        withAnimation(
            reduceMotion ? nil : .snappy(duration: 0.45, extraBounce: 0.05),
            completionCriteria: .logicallyComplete
        ) {
            viewModel.removeCard(cardID)
        } completion: {
            viewModel.showsCardAddedToast = false
            viewModel.showsCardRemovedToast = true
        }

        Task {
            await viewModel.persistRemoval(of: cardID)
        }
    }

    private var toolbarContent: some ToolbarContent {
        CardsToolbarContent(
            selectedCardID: $viewModel.selectedCardID,
            layoutStyle: $viewModel.layoutStyle,
            onAddCard: {
                viewModel.showsAddCard = true
            }
        )
    }
}
