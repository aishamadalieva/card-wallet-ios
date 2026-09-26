//
//  StoreMetadataEntity.swift
//  CardFlow
//

import Foundation
import SwiftData

@Model
final class StoreMetadataEntity {

    @Attribute(.unique) var key: String

    init(key: String) {
        self.key = key
    }
}
