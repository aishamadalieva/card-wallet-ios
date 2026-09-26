//
//  CardDetails.swift
//  CardFlow
//

import Foundation

struct CardDetails: Equatable, Sendable {
    let cardID: Card.ID
    let last4: String
    let expirationDate: String
    let balance: Decimal
    let currencyCode: String
}
