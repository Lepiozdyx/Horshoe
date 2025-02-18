// GameScene.swift

import SpriteKit

class GameScene: SKScene {
    // Ссылка на модель игры
    var viewModel: GameViewModel!
    
    // Размер ячейки на основе gridSize из модели
    var cellSize: CGFloat {
        return size.width / CGFloat(viewModel.gridSize)
    }
    
    var playerNode: SKSpriteNode!
    var ballNodes: [SKShapeNode] = []
    var obstacleNodes: [SKSpriteNode] = []
    var goalNode: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        backgroundColor = .white
        drawGrid()
        setupNodes()
    }
    
    // Отрисовка сетки
    func drawGrid() {
        let lineColor = SKColor.lightGray
        let lineWidth: CGFloat = 1.0
        let gridCount = viewModel.gridSize
        
        for i in 0...gridCount {
            let start = CGPoint(x: CGFloat(i) * cellSize, y: 0)
            let end = CGPoint(x: CGFloat(i) * cellSize, y: size.height)
            let path = CGMutablePath()
            path.move(to: start)
            path.addLine(to: end)
            let line = SKShapeNode(path: path)
            line.strokeColor = lineColor
            line.lineWidth = lineWidth
            addChild(line)
        }
        
        for j in 0...gridCount {
            let start = CGPoint(x: 0, y: CGFloat(j) * cellSize)
            let end = CGPoint(x: size.width, y: CGFloat(j) * cellSize)
            let path = CGMutablePath()
            path.move(to: start)
            path.addLine(to: end)
            let line = SKShapeNode(path: path)
            line.strokeColor = lineColor
            line.lineWidth = lineWidth
            addChild(line)
        }
    }
    
    // Создание узлов для всех игровых объектов
    func setupNodes() {
        // Футболист – черный квадрат
        let playerSize = CGSize(width: cellSize * 0.8, height: cellSize * 0.8)
        playerNode = SKSpriteNode(color: .black, size: playerSize)
        playerNode.position = positionFor(gridX: viewModel.playerPosition.x, gridY: viewModel.playerPosition.y)
        addChild(playerNode)
        
        // Мячи – красные круги
        for pos in viewModel.ballPositions {
            let ballRadius = cellSize * 0.4
            let ball = SKShapeNode(circleOfRadius: ballRadius)
            ball.fillColor = .red
            ball.strokeColor = .clear
            ball.position = positionFor(gridX: pos.x, gridY: pos.y)
            addChild(ball)
            ballNodes.append(ball)
        }
        
        // Препятствия – серые квадраты
        for pos in viewModel.obstaclePositions {
            let obstacleSize = CGSize(width: cellSize * 0.8, height: cellSize * 0.8)
            let obstacle = SKSpriteNode(color: .gray, size: obstacleSize)
            obstacle.position = positionFor(gridX: pos.x, gridY: pos.y)
            addChild(obstacle)
            obstacleNodes.append(obstacle)
        }
        
        // Ворота – желтый квадрат
        let goalSize = CGSize(width: cellSize * 0.8, height: cellSize * 0.8)
        goalNode = SKSpriteNode(color: .yellow, size: goalSize)
        goalNode.position = positionFor(gridX: viewModel.goalPosition.x, gridY: viewModel.goalPosition.y)
        addChild(goalNode)
    }
    
    // Перевод координат сетки в позицию центра ячейки
    func positionFor(gridX: Int, gridY: Int) -> CGPoint {
        let xPos = CGFloat(gridX) * cellSize + cellSize / 2
        let yPos = CGFloat(gridY) * cellSize + cellSize / 2
        return CGPoint(x: xPos, y: yPos)
    }
    
    // Метод перемещения игрока (футболиста)
    func movePlayer(direction: Direction) {
        viewModel.movePlayer(direction: direction)
        let newPlayerPos = positionFor(gridX: viewModel.playerPosition.x, gridY: viewModel.playerPosition.y)
        playerNode.run(SKAction.move(to: newPlayerPos, duration: 0.2))
    }
    
    // Вычисление пути (список координат) для движения мяча по клеткам
    func computePath(forBallAt startPos: (x: Int, y: Int)) -> [(x: Int, y: Int)]? {
        // Проверяем выравнивание по вертикали
        if viewModel.playerPosition.x == startPos.x {
            var directionY = 0
            if viewModel.playerPosition.y > startPos.y {
                // Если игрок выше мяча → мяч движется вниз (уменьшение y)
                directionY = -1
            } else if viewModel.playerPosition.y < startPos.y {
                // Если игрок ниже мяча → мяч движется вверх (увеличение y)
                directionY = 1
            } else {
                return nil
            }
            var path: [(x: Int, y: Int)] = []
            var currentPos = startPos
            while true {
                let nextY = currentPos.y + directionY
                // Если следующая ячейка за пределами поля, прекращаем
                if nextY < 0 || nextY >= viewModel.gridSize { break }
                // Если в следующей ячейке находится препятствие – останавливаемся перед ним
                if viewModel.obstaclePositions.contains(where: { $0.x == startPos.x && $0.y == nextY }) { break }
                currentPos.y = nextY
                path.append(currentPos)
                // Если следующая ячейка – ворота, добавляем её и выходим
                if viewModel.goalPosition.x == startPos.x && viewModel.goalPosition.y == nextY {
                    break
                }
            }
            return path.isEmpty ? nil : path
        }
        // Проверяем выравнивание по горизонтали
        else if viewModel.playerPosition.y == startPos.y {
            var directionX = 0
            if viewModel.playerPosition.x > startPos.x {
                // Если игрок справа от мяча → мяч движется влево (уменьшение x)
                directionX = -1
            } else if viewModel.playerPosition.x < startPos.x {
                // Если игрок слева от мяча → мяч движется вправо (увеличение x)
                directionX = 1
            } else {
                return nil
            }
            var path: [(x: Int, y: Int)] = []
            var currentPos = startPos
            while true {
                let nextX = currentPos.x + directionX
                if nextX < 0 || nextX >= viewModel.gridSize { break }
                if viewModel.obstaclePositions.contains(where: { $0.x == nextX && $0.y == startPos.y }) { break }
                currentPos.x = nextX
                path.append(currentPos)
                if viewModel.goalPosition.y == startPos.y && viewModel.goalPosition.x == nextX {
                    break
                }
            }
            return path.isEmpty ? nil : path
        }
        return nil
    }
    
    // Метод выполнения удара с анимацией движения мяча по клеткам
    func performShot() {
        for (index, ballNode) in ballNodes.enumerated() {
            let ballGridPos = viewModel.ballPositions[index]
            if let path = computePath(forBallAt: ballGridPos) {
                // Создаем последовательность анимаций для движения мяча по каждой клетке
                var actions: [SKAction] = []
                for gridPos in path {
                    let destination = positionFor(gridX: gridPos.x, gridY: gridPos.y)
                    let moveAction = SKAction.move(to: destination, duration: 0.2)
                    actions.append(moveAction)
                }
                let sequence = SKAction.sequence(actions)
                ballNode.run(sequence) { [weak self] in
                    guard let self = self else { return }
                    if let finalPos = path.last {
                        // Обновляем позицию мяча в модели
                        self.viewModel.ballPositions[index] = finalPos
                        // Если мяч достиг ворот, можно, например, изменить его цвет
                        if finalPos.x == self.viewModel.goalPosition.x && finalPos.y == self.viewModel.goalPosition.y {
                            ballNode.fillColor = .green
                        }
                    }
                }
            }
        }
    }
}
