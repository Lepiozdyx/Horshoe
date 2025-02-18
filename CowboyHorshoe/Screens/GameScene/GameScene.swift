// GameScene.swift

import SpriteKit

class GameScene: SKScene {
    // Ссылка на модель игры.
    var viewModel: GameViewModel!
    
    // Вычисляемый размер ячейки на основе gridSize.
    var cellSize: CGFloat {
        return size.width / CGFloat(viewModel.gridSize)
    }
    
    var playerNode: SKSpriteNode!
    var ballNodes: [SKShapeNode] = []
    var obstacleNodes: [SKSpriteNode] = []
    var goalNodes: [SKSpriteNode] = []  // Для нескольких столбов.
    
    override func didMove(to view: SKView) {
        backgroundColor = .white
        drawGrid()
        setupNodes()
    }
    
    // Отрисовка сетки.
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
    
    // Создание узлов для игрока, мячей, препятствий и ворот.
    func setupNodes() {
        // Футболист – черный квадрат.
        let playerSize = CGSize(width: cellSize * 0.8, height: cellSize * 0.8)
        playerNode = SKSpriteNode(color: .black, size: playerSize)
        playerNode.position = positionFor(gridX: viewModel.playerPosition.x, gridY: viewModel.playerPosition.y)
        addChild(playerNode)
        
        // Мячи – красные круги.
        for pos in viewModel.ballPositions {
            let ballRadius = cellSize * 0.4
            let ball = SKShapeNode(circleOfRadius: ballRadius)
            ball.fillColor = .red
            ball.strokeColor = .clear
            ball.position = positionFor(gridX: pos.x, gridY: pos.y)
            addChild(ball)
            ballNodes.append(ball)
        }
        
        // Препятствия – серые квадраты.
        for pos in viewModel.obstaclePositions {
            let obstacleSize = CGSize(width: cellSize * 0.8, height: cellSize * 0.8)
            let obstacle = SKSpriteNode(color: .gray, size: obstacleSize)
            obstacle.position = positionFor(gridX: pos.x, gridY: pos.y)
            addChild(obstacle)
            obstacleNodes.append(obstacle)
        }
        
        // Ворота – желтые квадраты (по одному на каждую позицию из goalPositions).
        for pos in viewModel.goalPositions {
            let goalSize = CGSize(width: cellSize * 0.8, height: cellSize * 0.8)
            let goal = SKSpriteNode(color: .yellow, size: goalSize)
            goal.position = positionFor(gridX: pos.x, gridY: pos.y)
            addChild(goal)
            goalNodes.append(goal)
        }
    }
    
    /// Преобразует координаты ячейки в позицию центра на сцене.
    func positionFor(gridX: Int, gridY: Int) -> CGPoint {
        let xPos = CGFloat(gridX) * cellSize + cellSize / 2
        let yPos = CGFloat(gridY) * cellSize + cellSize / 2
        return CGPoint(x: xPos, y: yPos)
    }
    
    // Метод перемещения игрока.
    func movePlayer(direction: Direction) {
        viewModel.movePlayer(direction: direction)
        let newPlayerPos = positionFor(gridX: viewModel.playerPosition.x, gridY: viewModel.playerPosition.y)
        playerNode.run(SKAction.move(to: newPlayerPos, duration: 0.2))
    }
    
    /// Выполняет анимацию броска мяча:
    /// 1. Сохраняет начальные позиции мячей.
    /// 2. Вызывает viewModel.performShot() для обновления позиций.
    /// 3. Для каждого мяча вычисляет последовательность клеток от исходной до конечной позиции и анимирует переход.
    func performShot() {
        // Сохраняем начальные позиции мячей.
        let initialPositions = viewModel.ballPositions
        
        // Вызываем логику удара в модели.
        viewModel.performShot()
        
        // Для каждого мяча создаём анимацию перемещения от начальной позиции до новой (вычисленной моделью).
        for (index, ballNode) in ballNodes.enumerated() {
            let initial = initialPositions[index]
            let final = viewModel.ballPositions[index]
            
            var path: [(x: Int, y: Int)] = []
            if initial.x == final.x {
                let step = final.y > initial.y ? 1 : -1
                for y in stride(from: initial.y + step, through: final.y, by: step) {
                    path.append((x: initial.x, y: y))
                }
            } else if initial.y == final.y {
                let step = final.x > initial.x ? 1 : -1
                for x in stride(from: initial.x + step, through: final.x, by: step) {
                    path.append((x: x, y: initial.y))
                }
            }
            
            var actions: [SKAction] = []
            for gridPos in path {
                let destination = positionFor(gridX: gridPos.x, gridY: gridPos.y)
                let moveAction = SKAction.move(to: destination, duration: 0.2)
                actions.append(moveAction)
            }
            let sequence = SKAction.sequence(actions)
            ballNode.run(sequence) { [weak self] in
                guard let self = self else { return }
                // Если мяч достиг ворот, меняем его цвет на зеленый.
                if self.viewModel.goalPositions.contains(where: { $0.x == final.x && $0.y == final.y }) {
                    ballNode.fillColor = .green
                }
            }
        }
    }
}

