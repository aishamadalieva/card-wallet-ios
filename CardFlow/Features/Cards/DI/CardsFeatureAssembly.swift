//
//  CardsFeatureAssembly.swift
//  CardFlow
//

import SwiftUI

@MainActor
protocol CardsFeatureAssemblyProtocol {
    func assembleScreen() -> CardsView
    func assembleAddCardScreen(onAdded: @escaping (Card) -> Void) -> AddCardView
}

@MainActor
final class CardsFeatureAssembly: CardsFeatureAssemblyProtocol {

    private let repository: CardRepositoryProtocol

    init(repository: CardRepositoryProtocol) {
        self.repository = repository
    }

    func assembleScreen() -> CardsView {
        let viewModel = CardsViewModel(repository: repository)
        let screen = CardsView(viewModel: viewModel, assembly: self)
        return screen
    }

    func assembleAddCardScreen(onAdded: @escaping (Card) -> Void) -> AddCardView {
        let viewModel = AddCardViewModel(repository: repository, onAdded: onAdded)
        let screen = AddCardView(viewModel: viewModel)
        return screen
    }
}
