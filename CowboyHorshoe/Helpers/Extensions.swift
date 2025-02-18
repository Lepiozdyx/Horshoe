//
//  Extensions.swift
//  CowboyHorshoe
//
//  Created by Alex on 17.02.2025.
//

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
