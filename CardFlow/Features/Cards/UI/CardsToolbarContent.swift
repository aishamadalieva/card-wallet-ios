//
//  CardsToolbarContent.swift
//  CardFlow
//


import SwiftUI

struct CardsToolbarContent: ToolbarContent {

    @Binding var selectedCardID: Int?
    @Binding var layoutStyle: CardsViewModel.LayoutStyle
    let onAddCard: () -> Void

    var body: some ToolbarContent {
        if selectedCardID != nil {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    withAnimation(.snappy(duration: 0.45, extraBounce: 0.05)) {
                        selectedCardID = nil
                    }
                } label: {
                    Image(systemName: "xmark")
                }
            }

        } else {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: onAddCard) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add card")
            }

            ToolbarItem(placement: .topBarTrailing) {
                layoutMenu
            }
        }
    }

    private var layoutMenu: some View {
        Menu {
            Picker("Layout", selection: $layoutStyle) {
                Label("Stack", systemImage: "rectangle.stack")
                    .tag(CardsViewModel.LayoutStyle.stack)

                Label("List", systemImage: "list.bullet")
                    .tag(CardsViewModel.LayoutStyle.list)
            }
        } label: {
            Image(systemName: "ellipsis")
        }
    }
}
