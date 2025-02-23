//
//  Extensions.swift

import SwiftUI

extension View {
    func playSound() -> some View {
        self.simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    Task { @MainActor in
                        SettingsManager.shared.playClick()
                    }
                }
        )
    }
}
