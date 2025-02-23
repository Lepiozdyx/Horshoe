//
//  RulesView.swift

import SwiftUI

struct RulesView: View {
    
    let text = """
In this game, your goal is to accurately place the horseshoes on separate stakes. Control your character, pick up horseshoes, and skillfully throw them onto the available stakes! Once every horseshoe is successfully placed, the game moves to the next level with new challenges.
"""
   let text2 = """
The cowboy can throw the horseshoe while on the same axis vertically or horizontally, in all four directions away from himself. The throw can be made even over an obstacle and not on the same square with the horseshoe. The horseshoe reaching the last square of the playing field is considered to be in touch - the game ends.
"""
    let text3 = """
 For each successfully completed level you get “horseshoes” that can be spent in the in-game saloon to buy new characters!
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
                            
                            Text(text2)
                                .font(.system(size: 18, weight: .heavy, design: .monospaced))
                            
                            HStack(spacing: 20) {
                                Image(.cowboy)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: 40)
                                
                                Image(.cowgirl)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: 40)
                            }
                            
                            Text(text3)
                                .font(.system(size: 18, weight: .heavy, design: .monospaced))
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
                .frame(maxWidth: 70)
                .overlay {
                    Image(.hand)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 40)
                }
            
            Image(.frame4)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 70)
                .overlay {
                    Image(.figure2)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 50)
                }
            
            Image(.frame4)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 70)
                .overlay {
                    Image(.figure3)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 35)
                }
        }
    }
}
