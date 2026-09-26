//
//  CardEntity.swift
//  CardFlow
//

import Foundation
import SwiftData

@Model
final class CardEntity {

    @Attribute(.unique) var id: Int
    var name: String
    var statusRawValue: String
    var designRawValue: String
    var last4: String
    var expirationDate: String
    var balanceMinorUnits: Int64
    var currencyCode: String
    var isPrimary: Bool
    var sortOrder: Int

    init(
        id: Int,
        name: String,
        statusRawValue: String,
        designRawValue: String,
        last4: String,
        expirationDate: String,
        balanceMinorUnits: Int64,
        currencyCode: String,
        isPrimary: Bool,
        sortOrder: Int
    ) {
        self.id = id
        self.name = name
        self.statusRawValue = statusRawValue
        self.designRawValue = designRawValue
        self.last4 = last4
        self.expirationDate = expirationDate
        self.balanceMinorUnits = balanceMinorUnits
        self.currencyCode = currencyCode
        self.isPrimary = isPrimary
        self.sortOrder = sortOrder
    }
}
