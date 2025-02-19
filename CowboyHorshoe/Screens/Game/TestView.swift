//
//  TestView.swift
//  CowboyHorshoe
//
//  Created by Alex on 19.02.2025.
//

import SwiftUI

struct TestView: View {
    var body: some View {
        VStack(spacing: 0) {
            Image(.gameCube)
                .resizable()
                .scaledToFit()
                .frame(width: 80)
            
            Image(.gameCube)
                .resizable()
                .scaledToFit()
                .frame(width: 80)
        }
    }
}

#Preview {
    ZStack {
        BackgroundView(imageName: .bg2)
        TestView()
    }
}
