//
// GameViewModel.swift

import Foundation

class GameViewModel: ObservableObject {
    // MARK: - Types
    
    /// Направление движения игрока
    enum Direction {
        case up, down, left, right
    }
    
    /// Результат броска подковы
    struct ThrowResult {
        /// Новые позиции всех подков
        let newPositions: [(x: Int, y: Int)]
        /// Флаг ухода подковы в аут
        let isOut: Bool
        /// Индексы подков на столбах
        let placedHorseshoes: Set<Int>
    }
    
    private enum MovementDirection {
        case horizontal(dx: Int)
        case vertical(dy: Int)
    }
    
    // MARK: - Public Properties
    
    /// Размер игрового поля
    let gridSize: Int
    
    /// Текущая позиция игрока
    @Published private(set) var playerPosition: (x: Int, y: Int)
    
    /// Позиции подков
    @Published private(set) var horseshoePositions: [(x: Int, y: Int)]
    
    /// Флаг, показывающий что хотя бы одна подкова в ауте
    @Published private(set) var isGameLost = false
    
    /// Позиции столбов
    let pillarPositions: [(x: Int, y: Int)]
    
    /// Позиции препятствий
    let obstaclePositions: [(x: Int, y: Int)]
    
    // MARK: - Private Properties
    
    /// Индексы подков, которые уже размещены на столбах
    private var placedHorseshoeIndices: Set<Int> = []
    
    // MARK: - Initialization
    
    init(gridSize: Int = 6,
         playerStart: (x: Int, y: Int) = (0, 0),
         horseshoes: [(x: Int, y: Int)] = [(2, 2), (3, 4)],
         pillars: [(x: Int, y: Int)] = [(5, 2)],
         obstacles: [(x: Int, y: Int)] = [(4, 1), (5, 4)]) {
        self.gridSize = gridSize
        self.playerPosition = playerStart
        self.horseshoePositions = horseshoes
        self.pillarPositions = pillars
        self.obstaclePositions = obstacles
    }
    
    // MARK: - Public Methods
    
    /// Перемещает игрока в указанном направлении
    func movePlayer(direction: Direction) {
        var newPosition = playerPosition
        
        switch direction {
        case .up:    newPosition.y += 1
        case .down:  newPosition.y -= 1
        case .left:  newPosition.x -= 1
        case .right: newPosition.x += 1
        }
        
        guard isValidPosition(newPosition) && !hasObstacle(at: newPosition) else { return }
        playerPosition = newPosition
    }
    
    /// Выполняет бросок подков в соответствии с текущим положением игрока
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
            
            // Проверяем попадание на столб
            if isOnPillar(position: newPosition) {
                currentPlacedIndices.insert(i)
                print("🎯 Подкова \(i) попала на столб в позиции \(newPosition)")
                print("📊 Всего подков на столбах: \(currentPlacedIndices.count) из \(pillarPositions.count) необходимых")
            }
            
            // Проверяем аут
            if !isEdge(initialPos) && isEdge(newPosition) && !isOnPillar(position: newPosition) {
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
    
    /// Проверяет, достигнута ли победа
    func isVictory() -> Bool {
        pillarPositions.allSatisfy { pillar in
            placedHorseshoeIndices.contains { index in
                let pos = horseshoePositions[index]
                return pos.x == pillar.x && pos.y == pillar.y
            }
        }
    }
    
    /// Проверяет, находится ли подкова на столбе
    func isHorseshoePlaced(at index: Int) -> Bool {
        placedHorseshoeIndices.contains(index)
    }
    
    /// Сброс состояния игры
    func resetGame() {
        isGameLost = false
        placedHorseshoeIndices.removeAll()
        // Здесь также можно добавить сброс других состояний если потребуется
    }
    
    // MARK: - Private Methods
    
    /// Проверяет, находится ли позиция в пределах поля
    private func isValidPosition(_ pos: (x: Int, y: Int)) -> Bool {
        pos.x >= 0 && pos.x < gridSize && pos.y >= 0 && pos.y < gridSize
    }
    
    /// Определяет направление движения подковы относительно игрока
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
    
    /// Вычисляет новую позицию подковы с учетом препятствий и границ
    private func calculateNewPosition(from start: (x: Int, y: Int),
                                    in direction: MovementDirection) -> (x: Int, y: Int) {
        var current = start
        
        switch direction {
        case .horizontal(let dx):
            while true {
                let nextX = current.x + dx
                guard isValidPosition((nextX, current.y)) else { break }
                guard !hasObstacle(at: (nextX, current.y)) else { break }
                
                current.x = nextX
                if isOnPillar(position: current) { break }
            }
            
        case .vertical(let dy):
            while true {
                let nextY = current.y + dy
                guard isValidPosition((current.x, nextY)) else { break }
                guard !hasObstacle(at: (current.x, nextY)) else { break }
                
                current.y = nextY
                if isOnPillar(position: current) { break }
            }
        }
        
        return current
    }
    
    /// Проверяет наличие препятствия в указанной позиции
    private func hasObstacle(at position: (x: Int, y: Int)) -> Bool {
        obstaclePositions.contains { $0.x == position.x && $0.y == position.y }
    }
    
    /// Проверяет, находится ли позиция на столбе
    private func isOnPillar(position: (x: Int, y: Int)) -> Bool {
        pillarPositions.contains { $0.x == position.x && $0.y == position.y }
    }
    
    /// Проверяет, находится ли позиция на краю поля
    private func isEdge(_ pos: (x: Int, y: Int)) -> Bool {
        pos.x == 0 || pos.x == gridSize - 1 || pos.y == 0 || pos.y == gridSize - 1
    }
}
