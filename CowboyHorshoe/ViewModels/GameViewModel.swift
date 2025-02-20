//
// GameViewModel.swift

import Foundation

enum Direction {
    case up, down, left, right
}

class GameViewModel: ObservableObject {
    // Размер игрового поля (для теста 6x6).
    let gridSize: Int = 6
    /// Текущая позиция игрока.
    @Published var playerPosition: (x: Int, y: Int) = (0, 0)
    /// Позиции подков. (Тестовый вариант — 2 подковы)
    @Published var horseshoePositions: [(x: Int, y: Int)] = [(2, 2), (3, 4)]
    /// Позиции столбов.
    @Published var pillarPositions: [(x: Int, y: Int)] = [(5, 2)]
    /// Позиции препятствий (например, заборы, кактусы).
    @Published var obstaclePositions: [(x: Int, y: Int)] = [(4, 1), (5, 4)]
    /// Флаг, сигнализирующий о завершении игры.
    @Published var isGameOver: Bool = false
    /// Флаг победы (true – выигрыш, false – поражение).
    @Published var didWin: Bool = false
    
    /// Индексы подков, которые уже заброшены (на столб).
    var placedHorseshoeIndices: Set<Int> = []
    
    // MARK: - Вспомогательные методы
    /// Проверяет, свободна ли ячейка (x, y) для перемещения игрока.
    func isCellFree(x: Int, y: Int) -> Bool {
        guard x >= 0 && x < gridSize && y >= 0 && y < gridSize else { return false }
        if obstaclePositions.contains(where: { $0.x == x && $0.y == y }) { return false }
        if horseshoePositions.contains(where: { $0.x == x && $0.y == y }) { return false }
        if pillarPositions.contains(where: { $0.x == x && $0.y == y }) { return false }
        return true
    }
    
    /// Определяет, находится ли позиция на краю игрового поля.
    func isEdge(_ pos: (x: Int, y: Int)) -> Bool {
        return pos.x == 0 || pos.x == gridSize - 1 || pos.y == 0 || pos.y == gridSize - 1
    }
    
    // MARK: - Перемещение игрока
    /// Перемещает игрока в заданном направлении, если целевая ячейка свободна.
    func movePlayer(direction: Direction) {
        var newX = playerPosition.x
        var newY = playerPosition.y
        
        switch direction {
        case .up: newY += 1
        case .down: newY -= 1
        case .left: newX -= 1
        case .right: newX += 1
        }
        
        if newX >= 0 && newX < gridSize && newY >= 0 && newY < gridSize && isCellFree(x: newX, y: newY) {
            playerPosition = (newX, newY)
        }
    }
    
    // MARK: - Логика броска
    /// Выполняет действие "Throw":
    /// 1. Для каждой подковы, если она выровнена с игроком по горизонтали или вертикали,
    ///    вычисляет ее новое положение, двигаясь по клеткам до столкновения с препятствием,
    ///    до достижения столба или до края игрового поля.
    /// 2. Если подкова, которая не находилась на краю, после броска оказывается на краю (и эта ячейка не соответствует столбу) – игра считается проигранной («аут»).
    /// 3. При проверке победы учитываются только подковы, которые были заброшены на столбы.
    func performThrow() {
        // Сохраняем изначальные позиции подков для проверки поражения.
        let initialHorseshoePositions = horseshoePositions
        
        // Для каждого элемента проверяем, если он ещё не заброшен, то пытаемся его переместить.
        for i in 0..<horseshoePositions.count {
            // Если подкова уже заброшена (на столб), пропускаем её.
            if placedHorseshoeIndices.contains(i) { continue }
            
            let horseshoePos = horseshoePositions[i]
            // Вертикальное выравнивание.
            if playerPosition.x == horseshoePos.x {
                var directionY = 0
                if playerPosition.y > horseshoePos.y {
                    directionY = -1  // Игрок выше подковы → движение вниз.
                } else if playerPosition.y < horseshoePos.y {
                    directionY = 1   // Игрок ниже подковы → движение вверх.
                } else {
                    continue
                }
                
                var newY = horseshoePos.y
                while true {
                    let nextY = newY + directionY
                    // Если следующая ячейка за пределами поля — прекращаем.
                    if nextY < 0 || nextY >= gridSize { break }
                    // Если в следующей ячейке есть препятствие — останавливаемся перед ним.
                    if obstaclePositions.contains(where: { $0.x == horseshoePos.x && $0.y == nextY }) { break }
                    newY = nextY
                    // Если достигли столба, завершаем движение.
                    if pillarPositions.contains(where: { $0.x == horseshoePos.x && $0.y == nextY }) {
                        break
                    }
                }
                horseshoePositions[i] = (horseshoePos.x, newY)
                if pillarPositions.contains(where: { $0.x == horseshoePos.x && $0.y == newY }) {
                    placedHorseshoeIndices.insert(i)
                }
            }
            // Горизонтальное выравнивание.
            else if playerPosition.y == horseshoePos.y {
                var directionX = 0
                if playerPosition.x > horseshoePos.x {
                    directionX = -1  // Игрок справа от подковы → движение влево.
                } else if playerPosition.x < horseshoePos.x {
                    directionX = 1   // Игрок слева от подковы → движение вправо.
                } else {
                    continue
                }
                
                var newX = horseshoePos.x
                while true {
                    let nextX = newX + directionX
                    if nextX < 0 || nextX >= gridSize { break }
                    if obstaclePositions.contains(where: { $0.x == nextX && $0.y == horseshoePos.y }) { break }
                    newX = nextX
                    if pillarPositions.contains(where: { $0.x == nextX && $0.y == horseshoePos.y }) {
                        break
                    }
                }
                horseshoePositions[i] = (newX, horseshoePos.y)
                if pillarPositions.contains(where: { $0.x == newX && $0.y == horseshoePos.y }) {
                    placedHorseshoeIndices.insert(i)
                }
            }
        }
        
        // Проверяем условие поражения (аут):
        // Если подкова, которая изначально не находилась на краю, после броска оказывается в крайней ячейке
        // (и эта ячейка не соответствует столбу) – игра проиграна.
        for i in 0..<horseshoePositions.count {
            let initial = initialHorseshoePositions[i]
            let final = horseshoePositions[i]
            if !isEdge(initial) && isEdge(final) && !pillarPositions.contains(where: { $0.x == final.x && $0.y == final.y }) {
                isGameOver = true
                didWin = false
                return
            }
        }
        
        // Проверяем условие победы:
        // Для каждого столба должна быть найдена хотя бы одна заброшенная подкова.
        let coveredGoals = pillarPositions.filter { goal in
            placedHorseshoeIndices.contains { index in
                horseshoePositions[index].x == goal.x && horseshoePositions[index].y == goal.y
            }
        }
        if coveredGoals.count == pillarPositions.count {
            didWin = true
            isGameOver = true
        }
    }
}

