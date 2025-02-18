//
//  ContentView.swift

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView(isMenu: true)
                
                VStack {
                    HStack {
                        ScoreboardView(value: 0)
                        Spacer()
                    }
                    
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
                        NavigationLink(destination: {}) {
                            MenuButtonView(name: .shop)
                        }
                    }
                    
                    Spacer()
                    
                    HStack {
                        // LevelsView()
                        NavigationLink(destination: {}) {
                            MenuButtonView(name: .level)
                        }
                        Spacer()
                        
                        // GameView()
                        NavigationLink(destination: {}) {
                            Image(.start)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 150)
                        }
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
