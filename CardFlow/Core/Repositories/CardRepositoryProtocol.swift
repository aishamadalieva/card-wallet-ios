//
//  CardRepositoryProtocol.swift
//  CardFlow
//

import Foundation

protocol CardRepositoryProtocol {
    func fetchCards() async throws -> [Card]
    func fetchCardDetails(for cardID: Card.ID) async throws -> CardDetails
    func addCard(_ request: AddCardRequest) async throws -> Card
    func updateStatus(_ status: CardStatus, for cardID: Card.ID) async throws
    func makePrimary(_ cardID: Card.ID) async throws
    func removeCard(_ cardID: Card.ID) async throws
}
