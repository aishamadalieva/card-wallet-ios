//
//  DIAssembly.swift
//  CardFlow
//

import Foundation

@MainActor
protocol DIAssemblyProtocol {
    var cardRepository: CardRepositoryProtocol { get }
    var cardsFeatureAssembly: CardsFeatureAssemblyProtocol { get }
}

@MainActor
final class DIAssembly: DIAssemblyProtocol {

    // MARK: - Core
    let cardRepository: CardRepositoryProtocol

    init(cardRepository: CardRepositoryProtocol) {
        self.cardRepository = cardRepository
    }

    convenience init() throws {
        let modelContainer = try PersistenceContainerFactory.make()
        let repository = SwiftDataCardRepository(modelContainer: modelContainer)
        self.init(cardRepository: repository)
    }

    // MARK: - Features
    lazy var cardsFeatureAssembly: CardsFeatureAssemblyProtocol = {
        CardsFeatureAssembly(repository: cardRepository)
    }()
}
