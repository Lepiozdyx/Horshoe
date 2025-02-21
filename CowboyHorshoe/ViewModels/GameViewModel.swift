//
// GameViewModel.swift

import Foundation

class GameViewModel: ObservableObject {
    // MARK: - Types
    
    enum Direction {
        case up, down, left, right
    }
    
    struct ThrowResult {
        let newPositions: [(x: Int, y: Int)]
        let isOut: Bool
        let placedHorseshoes: Set<Int>
    }
    
    private enum MovementDirection {
        case horizontal(dx: Int)
        case vertical(dy: Int)
    }
    
    // MARK: - Public Properties
    
    let gridSize: Int
    
    @Published private(set) var playerPosition: (x: Int, y: Int)
    @Published private(set) var horseshoePositions: [(x: Int, y: Int)]
    @Published private(set) var isGameLost = false
    
    let pillarPositions: [(x: Int, y: Int)]
    let obstaclePositions: [(x: Int, y: Int)]
    let emptyTilePositions: [(x: Int, y: Int)]
    
    // MARK: - Private Properties
    
    private var placedHorseshoeIndices: Set<Int> = []
    private let initialPlayerPosition: (x: Int, y: Int)
    private let initialHorseshoePositions: [(x: Int, y: Int)]
    
    // MARK: - Initialization
    
    init(gridSize: Int = 6,
         playerStart: (x: Int, y: Int) = (0, 0),
         horseshoes: [(x: Int, y: Int)] = [(2, 2), (3, 4)],
         pillars: [(x: Int, y: Int)] = [(0, 2), (5, 2)],
         obstacles: [(x: Int, y: Int)] = [(4, 1), (5, 4)],
         emptyTiles: [(x: Int, y: Int)] = [(0, 1), (0, 4)]) {
        self.gridSize = gridSize
        self.playerPosition = playerStart
        self.horseshoePositions = horseshoes
        self.pillarPositions = pillars
        self.obstaclePositions = obstacles
        self.emptyTilePositions = emptyTiles
        
        self.initialPlayerPosition = playerStart
        self.initialHorseshoePositions = horseshoes
    }
    
    // MARK: - Public Methods
    
    func movePlayer(direction: Direction) {
        var newPosition = playerPosition
        
        switch direction {
        case .up:    newPosition.y += 1
        case .down:  newPosition.y -= 1
        case .left:  newPosition.x -= 1
        case .right: newPosition.x += 1
        }
        
        guard isValidPositionForPlayer(newPosition) else { return }
        playerPosition = newPosition
    }
    
    func performThrow() -> ThrowResult {
        let initialPositions = horseshoePositions
        var isOutThisThrow = false
        var currentPlacedIndices = placedHorseshoeIndices
        
        for i in 0..<horseshoePositions.count where !placedHorseshoeIndices.contains(i) {
            let horseshoePos = horseshoePositions[i]
            let initialPos = initialPositions[i]
            
            guard let direction = getMovementDirection(from: horseshoePos) else { continue }
            
            let newPosition = calculateNewPosition(from: horseshoePos, in: direction)
            horseshoePositions[i] = newPosition
            
            if isOnPillar(position: newPosition) {
                currentPlacedIndices.insert(i)
                print("🎯 Подкова \(i) попала на столб в позиции \(newPosition)")
                print("📊 Всего подков на столбах: \(currentPlacedIndices.count) из \(pillarPositions.count) необходимых")
            }
            
            // Проверяем аут - теперь подкова уходит в аут при попадании на пустую ячейку
            if (isEdge(newPosition) || isEmptyTile(position: newPosition)) && !isOnPillar(position: newPosition) {
                isOutThisThrow = true
                isGameLost = true
                print("❌ Подкова \(i) ушла в аут! Начальная позиция: \(initialPos), конечная: \(newPosition)")
            }
        }
        
        placedHorseshoeIndices = currentPlacedIndices
        
        if isVictory() {
            print("🏆 ПОБЕДА! Все столбы (\(pillarPositions.count)) заняты подковами")
        }
        
        return ThrowResult(
            newPositions: horseshoePositions,
            isOut: isOutThisThrow,
            placedHorseshoes: currentPlacedIndices
        )
    }
    
    func isVictory() -> Bool {
        pillarPositions.allSatisfy { pillar in
            placedHorseshoeIndices.contains { index in
                let pos = horseshoePositions[index]
                return pos.x == pillar.x && pos.y == pillar.y
            }
        }
    }
    
    func isHorseshoePlaced(at index: Int) -> Bool {
        placedHorseshoeIndices.contains(index)
    }
    
    func resetGame() {
        isGameLost = false
        placedHorseshoeIndices.removeAll()
        playerPosition = initialPlayerPosition
        horseshoePositions = initialHorseshoePositions
    }
    
    // MARK: - Private Methods
    
    private func isHorseshoeAt(position: (x: Int, y: Int)) -> Bool {
        horseshoePositions.contains { $0.x == position.x && $0.y == position.y }
    }
    
    private func isValidPositionForPlayer(_ pos: (x: Int, y: Int)) -> Bool {
        isValidPosition(pos) &&
        !hasObstacle(at: pos) &&
        !isOnPillar(position: pos) &&
        !isHorseshoeAt(position: pos) &&
        !isEmptyTile(position: pos)
    }
    
    private func isValidPosition(_ pos: (x: Int, y: Int)) -> Bool {
        pos.x >= 0 && pos.x < gridSize && pos.y >= 0 && pos.y < gridSize
    }
    
    private func getMovementDirection(from position: (x: Int, y: Int)) -> MovementDirection? {
        if playerPosition.x == position.x {
            let dy = playerPosition.y > position.y ? -1 : 1
            return .vertical(dy: dy)
        } else if playerPosition.y == position.y {
            let dx = playerPosition.x > position.x ? -1 : 1
            return .horizontal(dx: dx)
        }
        return nil
    }
    
    private func calculateNewPosition(from start: (x: Int, y: Int),
                                    in direction: MovementDirection) -> (x: Int, y: Int) {
        var current = start
        
        switch direction {
        case .horizontal(let dx):
            while true {
                let nextX = current.x + dx
                let nextPos = (nextX, current.y)
                guard isValidPosition(nextPos) else { break }
                guard !hasObstacle(at: nextPos) else { break }
                
                current.x = nextX
                if isOnPillar(position: current) { break }
                // Если следующая позиция - пустая ячейка, подкова может пролететь через неё
                if isEmptyTile(position: current) { break }
            }
            
        case .vertical(let dy):
            while true {
                let nextY = current.y + dy
                let nextPos = (current.x, nextY)
                guard isValidPosition(nextPos) else { break }
                guard !hasObstacle(at: nextPos) else { break }
                
                current.y = nextY
                if isOnPillar(position: current) { break }
                // Если следующая позиция - пустая ячейка, подкова может пролететь через неё
                if isEmptyTile(position: current) { break }
            }
        }
        
        return current
    }
    
    private func hasObstacle(at position: (x: Int, y: Int)) -> Bool {
        obstaclePositions.contains { $0.x == position.x && $0.y == position.y }
    }
    
    private func isOnPillar(position: (x: Int, y: Int)) -> Bool {
        pillarPositions.contains { $0.x == position.x && $0.y == position.y }
    }
    
    private func isEmptyTile(position: (x: Int, y: Int)) -> Bool {
        emptyTilePositions.contains { $0.x == position.x && $0.y == position.y }
    }
    
    private func isEdge(_ pos: (x: Int, y: Int)) -> Bool {
        pos.x == 0 || pos.x == gridSize - 1 || pos.y == 0 || pos.y == gridSize - 1
    }
}
