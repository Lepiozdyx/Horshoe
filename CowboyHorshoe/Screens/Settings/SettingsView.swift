//
//  SettingsView.swift

import SwiftUI

struct SettingsView: View {
    
    @StateObject private var settings = SettingsManager.shared
    
    var body: some View {
        ZStack {
            BackgroundView(imageName: .bg1)
            
            ZStack {
                Image(.underlay3)
                    .resizable()
                    .frame(maxWidth: 450, maxHeight: 450)
                    .overlay(alignment: .topTrailing) {
                        XmarkButtonView()
                    }
                    .padding()
                
                VStack(spacing: 30) {
                    HStack(alignment: .bottom) {
                        Image(.speaker)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50)
                        
                        Spacer()
                        
                        VStack {
                            HStack(spacing: 20) {
                                Image(.on)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30)
                                
                                Image(.off)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40)
                            }
                            
                            // Sounds
                            ToggleButtonView(isEnabled: settings.isSoundEnabled) {
                                settings.toggleSound()
                            }
                        }
                    }
                    
                    HStack(alignment: .bottom) {
                        Image(.music)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30)
                        
                        Spacer()
                        
                        // Music
                        ToggleButtonView(isEnabled: settings.isMusicEnabled) {
                            settings.toggleMusic()
                        }
                    }
                    
                    Button {
                        settings.rateApp()
                        settings.playClick()
                    } label: {
                        Image(.frame2)
                            .resizable()
                            .frame(width: 150, height: 60)
                            .overlay {
                                Image(.rateUs)
                                    .resizable()
                                    .scaledToFit()
                                    .padding(20)
                            }
                            .overlay(alignment: .trailing) {
                                Image(.thumbsUp)
                                    .resizable()
                                    .scaledToFit()
                                    .offset(x: 55, y: -10)
                            }
                            .overlay(alignment: .leading) {
                                Image(.thumbsUp)
                                    .resizable()
                                    .scaledToFit()
                                    .scaleEffect(x: -1)
                                    .offset(x: -55, y: -10)
                            }
                    }
                }
                .frame(maxWidth: 200)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    SettingsView()
}

// MARK: - ToggleButtonView
struct ToggleButtonView: View {
    
    var isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button {
            withAnimation {
                action()
            }
        } label: {
            Image(.frame2)
                .resizable()
                .frame(width: 110, height: 60)
                .overlay(alignment: isEnabled ? .leading : .trailing) {
                    Image(.frame3)
                        .resizable()
                        .frame(width: 35, height: 35)
                        .padding(.horizontal)
                }
        }
        .buttonStyle(.plain)
    }
}
