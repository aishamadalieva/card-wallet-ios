//
//  SwiftDataCardStore.swift
//  CardFlow
//

import Foundation
import SwiftData

@ModelActor
actor SwiftDataCardStore {

    func fetchCards() throws -> [Card] {
        try seedIfNeeded()
        return try fetchCardEntities().map(CardEntityMapper.mapCard)
    }

    func fetchCardDetails(for cardID: Card.ID) throws -> CardDetails {
        try seedIfNeeded()
        return CardEntityMapper.mapDetails(try cardEntity(for: cardID))
    }

    func addCard(
        leadingDigit: Int,
        last4: String,
        expirationDate: String,
        currencyCode: String
    ) throws -> Card {
        try seedIfNeeded()

        let entities = try fetchCardEntities()
        let nextID = (entities.map(\.id).max() ?? 0) + 1
        let configuration = cardConfiguration(for: leadingDigit)
        let primaryCard = entities.first(where: \.isPrimary)
        let insertionOrder = primaryCard?.sortOrder ?? entities.count

        for entity in entities where entity.sortOrder >= insertionOrder {
            entity.sortOrder += 1
        }

        let entity = CardEntity(
            id: nextID,
            name: configuration.name,
            statusRawValue: CardStatus.active.rawValue,
            designRawValue: configuration.design.rawValue,
            last4: last4,
            expirationDate: expirationDate,
            balanceMinorUnits: 0,
            currencyCode: currencyCode,
            isPrimary: entities.isEmpty,
            sortOrder: insertionOrder
        )
        modelContext.insert(entity)
        try saveChanges()

        return try CardEntityMapper.mapCard(entity)
    }

    func updateStatus(_ status: CardStatus, for cardID: Card.ID) throws {
        try seedIfNeeded()
        let entity = try cardEntity(for: cardID)
        entity.statusRawValue = status.rawValue
        try saveChanges()
    }

    func makePrimary(_ cardID: Card.ID) throws {
        try seedIfNeeded()
        var entities = try fetchCardEntities()

        guard let selectedIndex = entities.firstIndex(where: { $0.id == cardID }) else {
            throw CardRepositoryError.cardNotFound
        }

        let selectedCard = entities.remove(at: selectedIndex)
        entities.append(selectedCard)

        for (index, entity) in entities.enumerated() {
            entity.isPrimary = entity.id == cardID
            entity.sortOrder = index
        }

        try saveChanges()
    }

    func removeCard(_ cardID: Card.ID) throws {
        try seedIfNeeded()
        var entities = try fetchCardEntities()

        guard let removedIndex = entities.firstIndex(where: { $0.id == cardID }) else {
            throw CardRepositoryError.cardNotFound
        }

        let removedCard = entities.remove(at: removedIndex)
        modelContext.delete(removedCard)

        if removedCard.isPrimary, let replacement = entities.last {
            replacement.isPrimary = true
        }

        for (index, entity) in entities.enumerated() {
            entity.sortOrder = index
        }

        try saveChanges()
    }

    private func seedIfNeeded() throws {
        let metadataDescriptor = FetchDescriptor<StoreMetadataEntity>(
            predicate: #Predicate { $0.key == "initialCardsSeeded" }
        )

        guard try modelContext.fetchCount(metadataDescriptor) == 0 else {
            return
        }

        if try modelContext.fetchCount(FetchDescriptor<CardEntity>()) == 0 {
            for entity in Self.seedCards {
                modelContext.insert(entity)
            }
        }

        modelContext.insert(StoreMetadataEntity(key: "initialCardsSeeded"))
        try saveChanges()
    }

    private func fetchCardEntities() throws -> [CardEntity] {
        var descriptor = FetchDescriptor<CardEntity>(
            sortBy: [SortDescriptor(\.sortOrder)]
        )
        descriptor.includePendingChanges = true
        return try modelContext.fetch(descriptor)
    }

    private func cardEntity(for cardID: Card.ID) throws -> CardEntity {
        let descriptor = FetchDescriptor<CardEntity>(
            predicate: #Predicate { $0.id == cardID }
        )

        guard let entity = try modelContext.fetch(descriptor).first else {
            throw CardRepositoryError.cardNotFound
        }

        return entity
    }

    private func saveChanges() throws {
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            throw error
        }
    }

    private func cardConfiguration(for leadingDigit: Int) -> (name: String, design: CardDesign) {
        switch leadingDigit {
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

    private static var seedCards: [CardEntity] {
        [
            CardEntity(
                id: 1,
                name: "Apex",
                statusRawValue: CardStatus.active.rawValue,
                designRawValue: CardDesign.apex.rawValue,
                last4: "4821",
                expirationDate: "09/29",
                balanceMinorUnits: 482_040,
                currencyCode: "USD",
                isPrimary: false,
                sortOrder: 0
            ),
            CardEntity(
                id: 2,
                name: "Flux",
                statusRawValue: CardStatus.active.rawValue,
                designRawValue: CardDesign.flux.rawValue,
                last4: "1934",
                expirationDate: "04/30",
                balanceMinorUnits: 127_580,
                currencyCode: "USD",
                isPrimary: false,
                sortOrder: 1
            ),
            CardEntity(
                id: 4,
                name: "Pearl",
                statusRawValue: CardStatus.active.rawValue,
                designRawValue: CardDesign.pearl.rawValue,
                last4: "0804",
                expirationDate: "11/28",
                balanceMinorUnits: 55_025,
                currencyCode: "USD",
                isPrimary: false,
                sortOrder: 2
            ),
            CardEntity(
                id: 5,
                name: "Vertex",
                statusRawValue: CardStatus.active.rawValue,
                designRawValue: CardDesign.vertex.rawValue,
                last4: "4418",
                expirationDate: "07/31",
                balanceMinorUnits: 824_010,
                currencyCode: "USD",
                isPrimary: false,
                sortOrder: 3
            ),
            CardEntity(
                id: 7,
                name: "Split",
                statusRawValue: CardStatus.active.rawValue,
                designRawValue: CardDesign.split.rawValue,
                last4: "3117",
                expirationDate: "02/30",
                balanceMinorUnits: 74_020,
                currencyCode: "USD",
                isPrimary: false,
                sortOrder: 4
            ),
            CardEntity(
                id: 8,
                name: "Nova",
                statusRawValue: CardStatus.active.rawValue,
                designRawValue: CardDesign.nova.rawValue,
                last4: "6502",
                expirationDate: "12/29",
                balanceMinorUnits: 146_000,
                currencyCode: "USD",
                isPrimary: true,
                sortOrder: 5
            )
        ]
    }
}
