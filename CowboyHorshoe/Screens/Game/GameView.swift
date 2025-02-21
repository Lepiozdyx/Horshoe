//
//  GameView.swift

import SwiftUI
import SpriteKit

struct GameView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = GameViewModel()
    @State private var showEndGame = false
    @State private var isVictory = false
    @State private var scene: GameScene?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if let currentScene = scene {
                SpriteView(scene: currentScene)
                    .ignoresSafeArea()
                
                ControlPanelView(scene: currentScene)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                
                CloseGameView {
                    resetLvl()
                    goToMenu()
                }
                .padding()
            }
        }
        .navigationBarBackButtonHidden(true)
        .overlay {
            if showEndGame {
                EndgameView(
                    isVictory: isVictory,
                    goToMenuAction: goToMenu,
                    tryAgainAction: resetLvl,
                    nextLvlAction: nextLvl
                )
            }
        }
        .onAppear {
            setupNewScene()
        }
        .onDisappear {
            cleanupScene()
        }
    }
    
    private func setupNewScene() {
        let newScene = GameScene(size: UIScreen.main.bounds.size)
        newScene.scaleMode = .aspectFit
        newScene.viewModel = viewModel
        newScene.gameOverCallback = { isWin in
            isVictory = isWin
            showEndGame = true
        }
        scene = newScene
    }
    
    private func cleanupScene() {
        scene?.removeAllChildren()
        scene?.removeFromParent()
        scene = nil
    }
    
    private func goToMenu() {
        cleanupScene()
        dismiss()
    }
    
    private func resetLvl() {
        showEndGame = false
        viewModel.resetGame()
        scene?.resetScene()
    }
    
    private func nextLvl() {
        showEndGame = false
        // TODO: В будущем здесь будет логика перехода к следующему уровню
        // Пока просто сбрасываем текущий
        resetLvl()
    }
}

#Preview {
    GameView()
}

struct CloseGameView: View {
    let action: () -> ()
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    SettingsManager.shared.playClick()
                    action()
                } label: {
                    Image(.xMark)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50)
                }
            }
            Spacer()
        }
    }
}
