//
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
    var horseshoeNodes: [SKShapeNode] = []
    var obstacleNodes: [SKSpriteNode] = []
    var pillarNodes: [SKSpriteNode] = []  // Для нескольких столбов.
    
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
    
    // Создание узлов для игрока, подков, препятствий и столбов.
    func setupNodes() {
        // Ковбой (игрок) – абстрактный черный квадрат.
        let playerSize = CGSize(width: cellSize * 0.8, height: cellSize * 0.8)
        playerNode = SKSpriteNode(color: .black, size: playerSize)
        playerNode.position = positionFor(gridX: viewModel.playerPosition.x, gridY: viewModel.playerPosition.y)
        addChild(playerNode)
        
        // Подковы – красные круги.
        for pos in viewModel.horseshoePositions {
            let hshoeRadius = cellSize * 0.3
            let hshoe = SKShapeNode(circleOfRadius: hshoeRadius)
            hshoe.fillColor = .red
            hshoe.strokeColor = .clear
            hshoe.position = positionFor(gridX: pos.x, gridY: pos.y)
            addChild(hshoe)
            horseshoeNodes.append(hshoe)
        }
        
        // Препятствия – зеленые квадраты.
        for pos in viewModel.obstaclePositions {
            let obstacleSize = CGSize(width: cellSize, height: cellSize)
            let obstacle = SKSpriteNode(color: .green, size: obstacleSize)
            obstacle.position = positionFor(gridX: pos.x, gridY: pos.y)
            addChild(obstacle)
            obstacleNodes.append(obstacle)
        }
        
        // Столбы – желтые квадраты (по одному на каждую позицию из pillarPositions).
        for pos in viewModel.pillarPositions {
            let pillarSize = CGSize(width: cellSize * 0.3, height: cellSize * 0.8)
            let pillar = SKSpriteNode(color: .orange, size: pillarSize)
            pillar.position = positionFor(gridX: pos.x, gridY: pos.y)
            addChild(pillar)
            pillarNodes.append(pillar)
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
    
    /// Выполняет анимацию броска подковы:
    /// 1. Сохраняет начальные позиции подков.
    /// 2. Вызывает viewModel.performThrow() для обновления позиций.
    /// 3. Для каждой подковы вычисляет последовательность клеток от исходной до конечной позиции и анимирует переход.
    func performThrow() {
        // Сохраняем начальные позиции подков.
        let initialPositions = viewModel.horseshoePositions
        // Вызываем логику броска в модели.
        viewModel.performThrow()
        
        // Для каждой подковы создаём анимацию перемещения от начальной позиции до новой (вычисленной моделью).
        for (index, hshoeNode) in horseshoeNodes.enumerated() {
            let initial = initialPositions[index]
            let final = viewModel.horseshoePositions[index]
            
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
            hshoeNode.run(sequence) { [weak self] in
                guard let self = self else { return }
                // Если подкова достигла столба, меняем цвет на зеленый.
                if self.viewModel.pillarPositions.contains(where: { $0.x == final.x && $0.y == final.y }) {
                    hshoeNode.fillColor = .green
                }
            }
        }
    }
}

