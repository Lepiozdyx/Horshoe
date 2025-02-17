//
//  RulesView.swift
//  CowboyHorshoe
//
//  Created by Alex on 17.02.2025.
//

import SwiftUI

struct RulesView: View {
    
    let text = """
In this game, your goal is to accurately place the horseshoes on separate stakes. Control your character, pick up horseshoes, and skillfully throw them onto the available stakes! Once every horseshoe is successfully placed, the game moves to the next level with new challenges. Precision and speed are the keys to victory!
"""
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            Image(.frame)
                .resizable()
                .frame(maxWidth: UIScreen.main.bounds.width * 0.9, maxHeight: UIScreen.main.bounds.height * 0.9)
                .overlay(alignment: .topTrailing) {
                    XmarkButtonView()
                        .offset(x: -15, y: 15)
                }
                .overlay {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack {
                            Text(text)
                                .font(.system(size: 18, weight: .heavy, design: .monospaced))
                            
                            GameElementsView()
                        }
                    }
                    .padding(.top, 50)
                    .padding(.horizontal)
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.8, maxHeight: UIScreen.main.bounds.height * 0.78)
                }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    RulesView()
}

// MARK: - GameElementsView
struct GameElementsView: View {
    var body: some View {
        HStack {
            Image(.frame4)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 80)
                .overlay {
                    Image(.hand)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 40)
                }
            
            Image(.frame4)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 80)
                .overlay {
                    Image(.figure2)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 60)
                }
            
            Image(.frame4)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 80)
                .overlay {
                    Image(.figure3)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 40)
                }
        }
    }
}
