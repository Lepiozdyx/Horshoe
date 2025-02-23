//
//  ContentView.swift

import SwiftUI

struct ContentView: View {
    
    @StateObject private var scoreManager = ScoreManager.shared
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var settings = SettingsManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView(isMenu: true)
                
                VStack {
                    ScoreboardView(value: scoreManager.score)

                    HStack(spacing: 30) {
                        // SettingsView
                        NavigationLink(destination: SettingsView()) {
                            MenuButtonView(name: .settings)
                        }
                        
                        // RulesView
                        NavigationLink(destination: RulesView()) {
                            MenuButtonView(name: .rules)
                        }
                        
                        // ShopView
                        NavigationLink(destination: ShopView()) {
                            MenuButtonView(name: .shop)
                        }
                    }
                    .padding(.top)
                    
                    Spacer()
                    
                    // GameView
                    NavigationLink(destination: GameView()) {
                        Image(.start)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 200)
                    }
                }
                .padding()
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            settings.playBackgroundMusic()
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                settings.playBackgroundMusic()
            case .background, .inactive:
                settings.stopBackgroundMusic()
            @unknown default:
                break
            }
        }
    }
}

#Preview {
    ContentView()
}
