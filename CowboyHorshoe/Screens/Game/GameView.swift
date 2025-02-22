//
//  GameView.swift

import SwiftUI
import SpriteKit

struct GameView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var coordinator = GameCoordinator()
    @State private var scene: GameScene?
    
    var body: some View {
        ZStack {
            if let currentScene = scene {
                SpriteView(scene: currentScene)
                    .ignoresSafeArea()
                
                VStack {
                    CloseGameView {
                        coordinator.cleanup()
                        dismiss()
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    Spacer()
                    
                    ControlPanelView(scene: currentScene)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .overlay {
            if coordinator.showEndGame {
                EndgameView(
                    isVictory: coordinator.isVictory,
                    goToMenuAction: {
                        coordinator.cleanup()
                        dismiss()
                    },
                    tryAgainAction: coordinator.resetLevel,
                    nextLvlAction: coordinator.nextLevel
                )
            }
        }
        .onAppear {
            scene = coordinator.setupNewScene(size: UIScreen.main.bounds.size)
        }
        .onDisappear {
            coordinator.cleanup()
        }
    }
}

#Preview {
    GameView()
}
