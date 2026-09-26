//
//  CardEntityMapper.swift
//  CardFlow
//

import Foundation

enum CardEntityMapper {

    nonisolated static func mapCard(_ entity: CardEntity) throws -> Card {
        guard let status = CardStatus(rawValue: entity.statusRawValue),
              let design = CardDesign(rawValue: entity.designRawValue) else {
            throw CardRepositoryError.invalidStoredData
        }

        return Card(
            id: entity.id,
            name: entity.name,
            status: status,
            design: design,
            isPrimary: entity.isPrimary
        )
    }

    nonisolated static func mapDetails(_ entity: CardEntity) -> CardDetails {
        CardDetails(
            cardID: entity.id,
            last4: entity.last4,
            expirationDate: entity.expirationDate,
            balance: Decimal(entity.balanceMinorUnits) / 100,
            currencyCode: entity.currencyCode
        )
    }
}

enum CardRepositoryError: Error {
    case cardNotFound
    case invalidStoredData
}
