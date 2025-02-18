// GameViewModel.swift

import Foundation

enum Direction {
    case up, down, left, right
}

class GameViewModel: ObservableObject {
    // Размер поля 6x6
    let gridSize: Int = 6
    
    // Позиции задаются в координатах (x, y), где x,y ∈ 0..<gridSize
    @Published var playerPosition: (x: Int, y: Int) = (0, 0)
    // Тестовый вариант – два мяча
    @Published var ballPositions: [(x: Int, y: Int)] = [(2, 2), (3, 4)]
    // Позиция ворот (одна ячейка)
    @Published var goalPosition: (x: Int, y: Int) = (5, 2)
    // Препятствия – две ячейки
    @Published var obstaclePositions: [(x: Int, y: Int)] = [(1, 1), (4, 4)]
    
    // Проверка: свободна ли ячейка для перемещения футболиста
    func isCellFree(x: Int, y: Int) -> Bool {
        guard x >= 0 && x < gridSize && y >= 0 && y < gridSize else { return false }
        if obstaclePositions.contains(where: { $0.x == x && $0.y == y }) { return false }
        if ballPositions.contains(where: { $0.x == x && $0.y == y }) { return false }
        if goalPosition.x == x && goalPosition.y == y { return false }
        return true
    }
    
    // Перемещение футболиста, если целевая ячейка свободна
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
    
    // Логика удара:
    // Для каждого мяча, если он выровнен по горизонтали или вертикали с футболистом,
    // перемещаем его в сторону, противоположную расположению футболиста,
    // пока не достигнем края поля или не встретим препятствие (в таком случае останавливаемся за ячейкой с препятствием)
    // Если мяч достигает ворот, то он перемещается в ячейку ворот.
    func performShot() {
        for i in 0..<ballPositions.count {
            let ballPos = ballPositions[i]
            // Вертикальное выравнивание
            if playerPosition.x == ballPos.x {
                var directionY = 0
                if playerPosition.y > ballPos.y {
                    // Футболист выше мяча → мяч летит вниз (уменьшаем y)
                    directionY = -1
                } else if playerPosition.y < ballPos.y {
                    // Футболист ниже мяча → мяч летит вверх (увеличиваем y)
                    directionY = 1
                }
                var newY = ballPos.y
                while true {
                    let nextY = newY + directionY
                    if nextY < 0 || nextY >= gridSize {
                        // Достигли края поля
                        break
                    }
                    // Если в следующей ячейке препятствие – останавливаемся за ним
                    if obstaclePositions.contains(where: { $0.x == ballPos.x && $0.y == nextY }) {
                        break
                    }
                    // Если следующая ячейка – ворота, перемещаем мяч туда и выходим
                    if goalPosition.x == ballPos.x && goalPosition.y == nextY {
                        newY = nextY
                        break
                    }
                    newY = nextY
                }
                ballPositions[i] = (ballPos.x, newY)
            }
            // Горизонтальное выравнивание
            else if playerPosition.y == ballPos.y {
                var directionX = 0
                if playerPosition.x > ballPos.x {
                    // Футболист справа от мяча → мяч летит влево (уменьшаем x)
                    directionX = -1
                } else if playerPosition.x < ballPos.x {
                    // Футболист слева от мяча → мяч летит вправо (увеличиваем x)
                    directionX = 1
                }
                var newX = ballPos.x
                while true {
                    let nextX = newX + directionX
                    if nextX < 0 || nextX >= gridSize {
                        break
                    }
                    if obstaclePositions.contains(where: { $0.x == nextX && $0.y == ballPos.y }) {
                        break
                    }
                    if goalPosition.y == ballPos.y && goalPosition.x == nextX {
                        newX = nextX
                        break
                    }
                    newX = nextX
                }
                ballPositions[i] = (newX, ballPos.y)
            }
        }
    }
    
    // Дополнительно добавить проверку условий победы/проигрыша
}
