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
    
    @State private var orientation = UIDeviceOrientation.unknown
    
    private var isLandscape: Bool {
        orientation.isLandscape
    }
    
    var body: some View {
        ZStack {
            BackgroundView(imageName: .bg4)
            
            VStack {
                HStack {
                    ScoreboardView(value: scoreManager.score)
                    Spacer()
                    XmarkButtonView()
                }
                .padding(.horizontal)
                
                Spacer()
                
                if isLandscape {
                    HStack {
                        previewSection
                        gridSection
                    }
                    .padding(.horizontal)
                } else {
                    VStack {
                        previewSection
                        gridSection
                    }
                    .padding(.horizontal)
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
        .onRotate { newOrientation in
            orientation = newOrientation
        }
    }
    
    private var previewSection: some View {
        ZStack {
            Image(.frame5)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 450)
                .overlay(alignment: .top) {
                    characterTypeSelector
                }
                .overlay(alignment: .bottom) {
                    chooseButton
                }
            
            Image(selectedCharacter.images[selectedImageIndex])
                .resizable()
                .scaledToFit()
                .frame(width: 80)
        }
    }
    
    private var gridSection: some View {
        Image(.frame5)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: 450)
            .overlay(alignment: .bottom) {
                priceTag
            }
            .overlay {
                LazyVGrid(
                    columns: Array(repeating: .init(.flexible()), count: isLandscape ? 3 : 2),
                    spacing: 4
                ) {
                    ForEach(Array(selectedCharacter.images.enumerated()), id: \.element) { index, image in
                        Button {
                            handleSkinSelection(index)
                        } label: {
                            Image(.frame4)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 65)
                                .overlay {
                                    Image(image)
                                        .resizable()
                                        .scaledToFit()
                                        .padding()
                                }
                        }
                        .opacity(isButtonEnabled(index) ? 1 : 0.5)
                    }
                }
                .padding(60)
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

extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

#Preview {
    ShopView()
}
