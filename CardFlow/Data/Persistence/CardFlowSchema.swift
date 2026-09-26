//
//  CardFlowSchema.swift
//  CardFlow
//

import SwiftData

enum CardFlowSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [CardEntity.self, StoreMetadataEntity.self]
    }
}

enum CardFlowMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [CardFlowSchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}

enum PersistenceContainerFactory {
    static func make(isStoredInMemoryOnly: Bool = false) throws -> ModelContainer {
        let schema = Schema(versionedSchema: CardFlowSchemaV1.self)
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: isStoredInMemoryOnly
        )

        return try ModelContainer(
            for: schema,
            migrationPlan: CardFlowMigrationPlan.self,
            configurations: [configuration]
        )
    }
}
