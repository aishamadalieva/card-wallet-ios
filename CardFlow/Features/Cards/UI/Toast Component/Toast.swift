//
//  Toast.swift
//  CardFlow
//

import SwiftUI

extension View {
    func toast(
        _ message: String,
        isPresented: Binding<Bool>,
        tone: ToastTone = .success,
        placement: ToastPlacement = .bottom,
        configuration: ToastConfiguration = .standard
    ) -> some View {
        modifier(
            ToastPresenter(
                isPresented: isPresented,
                message: message,
                tone: tone,
                placement: placement,
                configuration: configuration
            )
        )
    }
}
