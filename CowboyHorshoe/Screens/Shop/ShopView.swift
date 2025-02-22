//
//  ShopView.swift
//  CowboyHorshoe
//
//  Created by Alex on 22.02.2025.
//

import SwiftUI

struct ShopView: View {
    @StateObject private var skinManager = SkinManager.shared
    @StateObject private var scoreManager = ScoreManager.shared
    @State private var selectedCharacter: CharacterType = .cowboy
    @State private var selectedImageIndex: Int = 0
    @State private var showPurchaseAlert = false
    @State private var showInsufficientFundsAlert = false
    
    var body: some View {
        ZStack {
            BackgroundView(imageName: .bg4)
            
            VStack {
                HStack {
                    ScoreboardView(value: scoreManager.score)
                    Spacer()
                    XmarkButtonView()
                }
                Spacer()
                
                VStack {
                    ZStack {
                        Image(.frame5)
                            .resizable()
                            .scaledToFit()
                            .frame(width: UIScreen.main.bounds.width * 0.8)
                            .overlay(alignment: .top) {
                                HStack(spacing: 20) {
                                    Button {
                                        selectedCharacter = .cowboy
                                        selectedImageIndex = 0
                                    } label: {
                                        Image(.man)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50)
                                            .opacity(selectedCharacter == .cowboy ? 1 : 0.5)
                                    }
                                    
                                    Button {
                                        selectedCharacter = .cowgirl
                                        selectedImageIndex = 0
                                    } label: {
                                        Image(.woman)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50)
                                            .opacity(selectedCharacter == .cowgirl ? 1 : 0.5)
                                    }
                                }
                            }
                            .overlay(alignment: .bottom) {
                                Button {
                                    skinManager.selectSkin(type: selectedCharacter, imageIndex: selectedImageIndex)
                                } label: {
                                    ZStack {
                                        Image(.underlay2)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 120)
                                        
                                        Text("CHOOSE")
                                            .foregroundStyle(.yellow)
                                            .font(.system(size: 18, weight: .heavy, design: .serif))
                                    }
                                }
                                .disabled(!skinManager.isSkinPurchased(type: selectedCharacter, imageIndex: selectedImageIndex))
                                .opacity(skinManager.isSkinPurchased(type: selectedCharacter, imageIndex: selectedImageIndex) ? 1 : 0.5)
                            }
                        
                        Image(selectedCharacter.images[selectedImageIndex])
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80)
                    }
                    
                    Image(.frame5)
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width * 0.8)
                        .overlay(alignment: .bottom) {
                            Image(.underlay4)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 130)
                                .overlay {
                                    HStack {
                                        Image(.horseshoe)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20)
                                        
                                        Text("50")
                                            .foregroundStyle(.black)
                                            .font(.system(size: 22, weight: .heavy, design: .serif))
                                    }
                                    .offset(y: 5)
                                }
                        }
                        .overlay {
                            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2), spacing: 6) {
                                ForEach(Array(selectedCharacter.images.enumerated()), id: \.element) { index, image in
                                    Button {
                                        handleSkinSelection(index)
                                    } label: {
                                        Image(.frame4)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 70)
                                            .overlay {
                                                Image(image)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .padding()
                                            }
                                    }
                                    .opacity(isButtonEnabled(index) ? 1 : 0.5)
                                    .disabled(!isButtonEnabled(index))
                                }
                            }
                            .padding(60)
                        }
                }
            }
            .padding()
            .alert("Purchase Successful!", isPresented: $showPurchaseAlert) {
                Button("OK", role: .cancel) { }
            }
            .alert("Insufficient Funds", isPresented: $showInsufficientFundsAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("You need 50 horseshoes to purchase this skin.")
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func handleSkinSelection(_ index: Int) {
        if skinManager.isSkinPurchased(type: selectedCharacter, imageIndex: index) {
            selectedImageIndex = index
        } else if scoreManager.score >= 50 {
            if skinManager.purchaseSkin(type: selectedCharacter, imageIndex: index) {
                selectedImageIndex = index
                showPurchaseAlert = true
            }
        } else {
            showInsufficientFundsAlert = true
        }
    }
    
    private func isButtonEnabled(_ index: Int) -> Bool {
        index == 0 || skinManager.isSkinPurchased(type: selectedCharacter, imageIndex: index) || scoreManager.score >= 50
    }
}

#Preview {
    ShopView()
}
