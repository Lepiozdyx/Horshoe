//
//  ContentView.swift

import SwiftUI

struct ContentView: View {
    
    @StateObject private var scoreManager = ScoreManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView(isMenu: true)
                
                VStack {
                    ScoreboardView(value: scoreManager.score)

                    HStack(spacing: 30) {
                        // SettingsView()
                        NavigationLink(destination: SettingsView()) {
                            MenuButtonView(name: .settings)
                        }
                        
                        // RulesView()
                        NavigationLink(destination: RulesView()) {
                            MenuButtonView(name: .rules)
                        }
                        
                        // ShopView()
                        NavigationLink(destination: ShopView()) {
                            MenuButtonView(name: .shop)
                        }
                    }
                    .padding(.top)
                    
                    Spacer()
                    
                    // GameView()
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
    }
    
    // TODO: Handle music states
}

#Preview {
    ContentView()
}
