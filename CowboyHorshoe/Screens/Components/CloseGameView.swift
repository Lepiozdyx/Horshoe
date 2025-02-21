//
//  CloseGameView.swift
//  CowboyHorshoe
//
//  Created by Alex on 21.02.2025.
//

import SwiftUI

struct CloseGameView: View {
    
    let action: () -> ()
    
    var body: some View {
        HStack {
            Spacer()
            Button {
                SettingsManager.shared.playClick()
                action()
            } label: {
                Image(.xMark)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50)
            }
        }
    }
}
