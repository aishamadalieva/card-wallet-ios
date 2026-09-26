//
//  CardFlowApp.swift
//  CardFlow
//
//  Created by Aisha Madalieva on 06/09/26.
//

import SwiftUI

@main
struct CardFlowApp: App {

    private let assemblyResult: Result<DIAssembly, Error>

    init() {
        assemblyResult = Result {
            try DIAssembly()
        }
    }

    var body: some Scene {
        WindowGroup {
            switch assemblyResult {
            case .success(let assembly):
                assembly.cardsFeatureAssembly.assembleScreen()
            case .failure:
                ContentUnavailableView(
                    "Unable to Open Cards",
                    systemImage: "exclamationmark.triangle",
                    description: Text("Card data couldn’t be opened. Restart the app and try again.")
                )
            }
        }
    }
}
