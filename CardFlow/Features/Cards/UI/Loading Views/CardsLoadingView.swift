//
//  CardsLoadingView.swift
//  CardFlow
//

import SwiftUI

struct CardsLoadingView: View {

    var body: some View {
        VStack(spacing: -150) {
            ForEach(0..<4, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(uiColor: .tertiarySystemFill))
                    .frame(height: 220)
                    .shimmering()
            }
        }
        .safeAreaPadding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Loading cards")
    }
}
