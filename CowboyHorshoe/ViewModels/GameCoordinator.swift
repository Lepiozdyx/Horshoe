//
//  GameCoordinator.swift

import SwiftUI
import SpriteKit

@MainActor
final class GameCoordinator: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var showEndGame = false
    @Published private(set) var isVictory = false
    
    // MARK: - Private Properties
    private var viewModel: GameViewModel
    private weak var scene: GameScene?
    private let levelManager = LevelManager.shared
    
    // MARK: - Initialization
    init() {
        let config = levelManager.configuration(for: levelManager.currentLevel)
        self.viewModel = GameViewModel(configuration: config)
    }
    
    // MARK: - Scene Management
    func setupNewScene(size: CGSize) -> GameScene {
        let newScene = GameScene(size: size)
        newScene.scaleMode = .aspectFit
        newScene.viewModel = viewModel
        newScene.gameOverCallback = { [weak self] isWin in
            self?.handleGameOver(isWin: isWin)
        }
        scene = newScene
        return newScene
    }
    
    func cleanup() {
        scene?.removeAllChildren()
        scene?.removeFromParent()
        scene = nil
        showEndGame = false
        isVictory = false
        viewModel.resetGame()
    }
    
    // MARK: - Game Flow Control
    func resetLevel() {
        showEndGame = false
        viewModel.resetGame()
        scene?.resetScene()
    }
    
    func nextLevel() {
        levelManager.moveToNextLevel()
        showEndGame = false
        
        // Create new viewModel with next level configuration
        let config = levelManager.configuration(for: levelManager.currentLevel)
        viewModel = GameViewModel(configuration: config)
        
        // Reset scene with new viewModel
        scene?.viewModel = viewModel
        scene?.resetScene()
    }
    
    // MARK: - Game Actions
    func movePlayer(direction: GameViewModel.Direction) {
        scene?.movePlayer(direction: direction)
    }
    
    func performThrow() {
        scene?.performThrow()
    }
    
    // MARK: - Private Methods
    private func handleGameOver(isWin: Bool) {
        isVictory = isWin
        if isWin {
            ScoreManager.shared.addScore(10)
        }
        showEndGame = true
    }
}
