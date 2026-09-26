//
//  ToastConfiguration.swift
//  CardFlow
//

import SwiftUI

enum ToastPlacement {
    case top
    case bottom
}

enum ToastTone {
    case success
    case error
}

struct ToastConfiguration {
    let displayDuration: TimeInterval
    let animation: Animation
    let usesHaptics: Bool

    static let standard = ToastConfiguration(
        displayDuration: 2,
        animation: .easeOut(duration: 0.22),
        usesHaptics: true
    )
}
