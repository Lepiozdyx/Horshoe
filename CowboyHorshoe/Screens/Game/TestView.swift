//
//  TestView.swift
//  CowboyHorshoe
//
//  Created by Alex on 19.02.2025.
//

import SwiftUI

struct TestView: View {
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                Image(.gameCube)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80)
                
                Image(.gameCube)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80)
            }
            
            HStack(spacing: 0) {
                Image(.gameCube)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80)
                
                Image(.gameCube)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80)
            }
            .offset(x: 0, y: 45)
        }
    }
}

#Preview {
    ZStack {
        BackgroundView(imageName: .bg2)
        TestView()
    }
}
