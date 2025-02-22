//
//  GameCoordinator.swift
//  CowboyHorshoe
//
//  Created by Alex on 22.02.2025.
//

import SwiftUI
import SpriteKit

@MainActor
final class GameCoordinator: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var showEndGame = false
    @Published private(set) var isVictory = false
    
    // MARK: - Private Properties
    private var viewModel: GameViewModel
    private var scoreManager: ScoreManager
    private weak var scene: GameScene?
    
    // MARK: - Initialization
    init(viewModel: GameViewModel = GameViewModel()) {
        let scoreManager = ScoreManager.shared // Получаем reference в init контексте
        self.viewModel = viewModel
        self.scoreManager = scoreManager
        self.viewModel = viewModel
        self.scoreManager = scoreManager
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
        // Очищаем сцену
        scene?.removeAllChildren()
        scene?.removeFromParent()
        scene = nil
        
        // Сбрасываем состояния
        showEndGame = false
        isVictory = false
        
        // Сбрасываем игровое состояние
        viewModel.resetGame()
    }
    
    // MARK: - Game Flow Control
    func resetLevel() {
        showEndGame = false
        viewModel.resetGame()
        scene?.resetScene()
    }
    
    func nextLevel() {
        showEndGame = false
        // TODO: Implement next level logic
        resetLevel()
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
            scoreManager.addScore(10)
        }
        showEndGame = true
    }
}
