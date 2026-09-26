//
//  CardStackView.swift
//  CardFlow
//


import SwiftUI

struct CardStackView: View {

    let cards: [Card]
    @Binding var selectedCardID: Int?
    let layoutStyle: CardsViewModel.LayoutStyle

    var body: some View {
        VStack(spacing: layoutStyle == .stack ? -150 : 16) {
            ForEach(cards) { card in
                cardView(for: card)
            }
        }
        .coordinateSpace(name: "cardStack")
        .animation(.snappy(duration: 0.45), value: layoutStyle)
    }

    @ViewBuilder
    private func cardView(for card: Card) -> some View {
        let isSelected = card.id == selectedCardID
        let hasSelection = selectedCardID != nil
        let cardIndex = cards.firstIndex(where: { $0.id == card.id })
        let selectedIndex = cards.firstIndex(where: { $0.id == selectedCardID })
        let isBeforeSelection = (cardIndex ?? 0) < (selectedIndex ?? 0)

        PaymentCardView(card: card)
            .onTapGesture {
                guard selectedCardID == nil else { return }

                withAnimation(.snappy(duration: 0.45, extraBounce: 0.05)) {
                    selectedCardID = card.id
                }
            }
            .visualEffect { content, proxy in
                let rect = proxy.frame(in: .named("cardStack"))
                let unselectedOffset = isBeforeSelection ? -rect.maxY - 20 : rect.height * 2

                return content
                    .offset(y: isSelected ? -rect.minY : hasSelection ? unselectedOffset : 0)
                    .opacity(!hasSelection || isSelected ? 1 : 0)
            }
            .zIndex(isSelected ? 1 : 0)
            .allowsHitTesting(!hasSelection || isSelected)
    }
}
