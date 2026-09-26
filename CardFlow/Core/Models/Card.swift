//
//  Card.swift
//  CardFlow
//
//  Created by Aisha Madalieva on 07/09/26.
//

import Foundation

struct Card: Identifiable, Equatable, Sendable {
    let id: Int
    let name: String
    var status: CardStatus
    let design: CardDesign
    var isPrimary: Bool
}

enum CardDesign: String, Equatable, Sendable {
    case apex
    case flux
    case pearl
    case vertex
    case split
    case nova
}

enum CardStatus: String, Equatable, Sendable {
    case active
    case frozen
    case expired
}
