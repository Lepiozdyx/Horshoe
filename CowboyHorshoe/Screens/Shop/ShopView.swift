//
//  ShopView.swift

import SwiftUI

struct ShopView: View {
    @StateObject private var skinManager = SkinManager.shared
    @StateObject private var scoreManager = ScoreManager.shared
    
    @State private var selectedCharacter: CharacterType = .cowboy
    @State private var selectedImageIndex: Int = 0
    @State private var showPurchaseAlert = false
    @State private var showInsufficientFundsAlert = false
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            
            ZStack {
                BackgroundView(imageName: .bg4)
                
                VStack(spacing: 0) {
                    HStack {
                        ScoreboardView(value: scoreManager.score)
                        Spacer()
                        XmarkButtonView()
                    }
                    
                    Spacer()
                    
                    if isLandscape {
                        HStack(alignment: .center) {
                            previewSection
                            gridSection
                        }
                    } else {
                        VStack {
                            previewSection
                            gridSection
                        }
                    }
                }
                .padding()
            }
            .navigationBarBackButtonHidden(true)
            .alert("The character was purchased!", isPresented: $showPurchaseAlert) {
                Button("OK", role: .cancel) { }
            }
            .alert("Not enough horseshoes!", isPresented: $showInsufficientFundsAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("To get this character, you need 50 horseshoes.")
            }
        }
    }
    
    private var previewSection: some View {
        ZStack {
            Image(.frame5)
                .resizable()
                .scaledToFit()
                .overlay(alignment: .top) {
                    characterTypeSelector
                }
                .overlay(alignment: .bottom) {
                    chooseButton
                }
            
            Image(selectedCharacter.images[selectedImageIndex])
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 160)
        }
    }
    
    private var gridSection: some View {
        ZStack {
            Image(.frame5)
                .resizable()
                .scaledToFit()
                .overlay(alignment: .bottom) {
                    priceTag
                }
                .overlay {
                    LazyVGrid(
                        columns: Array(
                            repeating: .init(.flexible()),
                            count: 2
                        ),
                        spacing: 2
                    ) {
                        ForEach(Array(selectedCharacter.images.enumerated()), id: \.element) { index, image in
                            Button {
                                handleSkinSelection(index)
                            } label: {
                                Image(.frame4)
                                    .resizable()
                                    .frame(width: 70, height: 70)
                                    .overlay {
                                        Image(image)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 25)
                                    }
                            }
                            .opacity(isButtonEnabled(index) ? 1 : 0.5)
                        }
                    }
                    .padding()
                    .frame(maxWidth: 200)
                }
        }
    }
    
    private var characterTypeSelector: some View {
        HStack(spacing: 20) {
            Button {
                selectedCharacter = .cowboy
                selectedImageIndex = 0
            } label: {
                Image(.man)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50)
            }
            
            Button {
                selectedCharacter = .cowgirl
                selectedImageIndex = 0
            } label: {
                Image(.woman)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50)
            }
        }
    }
    
    private var chooseButton: some View {
        Button {
            skinManager.selectSkin(
                type: selectedCharacter,
                imageIndex: selectedImageIndex
            )
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
    
    private var priceTag: some View {
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
