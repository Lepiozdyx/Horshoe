//
//  BackgroundView.swift
//  CowboyHorshoe
//
//  Created by Alex on 17.02.2025.
//

import SwiftUI

struct BackgroundView: View {
    var imageName: ImageResource = .bg
    var isMenu: Bool = false
    
    var body: some View {
        Image(imageName)
            .resizable()
            .ignoresSafeArea()
            .overlay {
                if isMenu {
                    Image(.logo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300)
                }
            }
    }
}

#Preview {
    BackgroundView(imageName: .bg, isMenu: true)
}
