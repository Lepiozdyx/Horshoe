//
// GameScene.swift

import SpriteKit

class GameScene: SKScene {
    var viewModel: GameViewModel!
    
    var boardSize: CGFloat {
        return min(size.width, size.height) * 0.8
    }
    
    let boardNode = SKNode()
    
    var cellSize: CGFloat {
        return boardSize / CGFloat(viewModel.gridSize)
    }
    
    // Высота перекрытия ячеек (половина высоты ячейки)
    var cellOverlap: CGFloat {
        return cellSize * 0.55
    }
    
    // Вычисляем реальную высоту поля с учетом нахлеста
    var actualBoardHeight: CGFloat {
        return cellSize + (cellSize - cellOverlap) * CGFloat(viewModel.gridSize - 1)
    }
    
    var playerNode: SKSpriteNode!
    var horseshoeNodes: [SKSpriteNode] = []
    var obstacleNodes: [SKSpriteNode] = []
    var pillarNodes: [SKSpriteNode] = []
    var animationsCompleted = 0
    
    override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let bgTexture = SKTexture(imageNamed: ImageNames.bg2.rawValue)
        let bgNode = SKSpriteNode(texture: bgTexture)
        bgNode.size = self.size
        bgNode.position = CGPoint(x: 0, y: 0)
        bgNode.zPosition = -100
        addChild(bgNode)
        
        // Центрируем boardNode с учетом реальной высоты поля
        let verticalOffset = (boardSize - actualBoardHeight) / 2
        boardNode.position = CGPoint(x: 0, y: verticalOffset)
        boardNode.zPosition = 0
        addChild(boardNode)
        
        setupBackgroundGrid()
        setupNodes()
    }
    
    func positionFor(gridX: Int, gridY: Int) -> CGPoint {
        let offsetX = -boardSize / 2
        // Начинаем построение снизу, смещая базовую точку вниз на половину реальной высоты поля
        let offsetY = -actualBoardHeight / 2
        
        let xPos = offsetX + CGFloat(gridX) * cellSize + cellSize / 2
        // Добавляем нахлест для каждой следующей строки
        let yPos = offsetY + CGFloat(gridY) * (cellSize - cellOverlap) + cellSize / 2
        
        return CGPoint(x: xPos, y: yPos)
    }
    
    func objectPositionFor(gridX: Int, gridY: Int) -> CGPoint {
        let basePosition = positionFor(gridX: gridX, gridY: gridY)
        // Смещаем объекты вверх для размещения их на поверхности ячейки
        return CGPoint(x: basePosition.x, y: basePosition.y + cellSize / 2)
    }
    
    func setupBackgroundGrid() {
        let cubeTexture = SKTexture(imageNamed: ImageNames.gameCube.rawValue)
        
        // Отрисовываем сетку снизу вверх для правильного наложения
        for y in (0..<viewModel.gridSize).reversed() {
            for x in 0..<viewModel.gridSize {
                let cubeNode = SKSpriteNode(texture: cubeTexture, size: CGSize(width: cellSize, height: cellSize))
                cubeNode.position = positionFor(gridX: x, gridY: y)
                
                // Устанавливаем zPosition в зависимости от положения ячейки
                // Нижние ячейки должны быть впереди верхних
                cubeNode.zPosition = CGFloat(viewModel.gridSize - y)
                
                boardNode.addChild(cubeNode)
            }
        }
    }
    
    func setupNodes() {
        // Ковбой
        let playerSize = CGSize(width: cellSize * 0.5, height: cellSize * 0.8)
        let playerTexture = SKTexture(imageNamed: ImageNames.cowboy.rawValue)
        playerNode = SKSpriteNode(texture: playerTexture, size: playerSize)
        playerNode.position = objectPositionFor(gridX: viewModel.playerPosition.x, gridY: viewModel.playerPosition.y)
        // Игровые объекты должны быть впереди всех ячеек
        playerNode.zPosition = CGFloat(viewModel.gridSize + 1)
        boardNode.addChild(playerNode)
        
        // Подковы
        for pos in viewModel.horseshoePositions {
            let horseshoeSize = CGSize(width: cellSize * 0.45, height: cellSize * 0.5)
            let hshoeTexture = SKTexture(imageNamed: ImageNames.hShoe.rawValue)
            let hshoe = SKSpriteNode(texture: hshoeTexture, size: horseshoeSize)
            hshoe.position = objectPositionFor(gridX: pos.x, gridY: pos.y)
            hshoe.zPosition = CGFloat(viewModel.gridSize + 1)
            boardNode.addChild(hshoe)
            horseshoeNodes.append(hshoe)
        }
        
        // Препятствия
        for pos in viewModel.obstaclePositions {
            let obstacleSize = CGSize(width: cellSize * 0.6, height: cellSize * 0.65)
            let obstacleTexture = SKTexture(imageNamed: Int.random(in: 0...1) == 0 ? ImageNames.cactus.rawValue : ImageNames.fence.rawValue)
            let obstacle = SKSpriteNode(texture: obstacleTexture, size: obstacleSize)
            obstacle.position = objectPositionFor(gridX: pos.x, gridY: pos.y)
            obstacle.zPosition = CGFloat(viewModel.gridSize + 1)
            boardNode.addChild(obstacle)
            obstacleNodes.append(obstacle)
        }
        
        // Столбы
        for pos in viewModel.pillarPositions {
            let pillarSize = CGSize(width: cellSize * 0.2, height: cellSize * 0.7)
            let pillarTexture = SKTexture(imageNamed: ImageNames.pillar.rawValue)
            let pillar = SKSpriteNode(texture: pillarTexture, size: pillarSize)
            pillar.position = objectPositionFor(gridX: pos.x, gridY: pos.y)
            pillar.zPosition = CGFloat(viewModel.gridSize + 1)
            boardNode.addChild(pillar)
            pillarNodes.append(pillar)
        }
    }
    
    func movePlayer(direction: Direction) {
        viewModel.movePlayer(direction: direction)
        let newPlayerPos = objectPositionFor(gridX: viewModel.playerPosition.x, gridY: viewModel.playerPosition.y)
        playerNode.run(SKAction.move(to: newPlayerPos, duration: 0.2))
    }
    
    func performThrow() {
        animationsCompleted = 0
        let initialPositions = viewModel.horseshoePositions
        viewModel.performThrow()
        
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
                let destination = objectPositionFor(gridX: gridPos.x, gridY: gridPos.y)
                let moveAction = SKAction.move(to: destination, duration: 0.2)
                actions.append(moveAction)
            }
            
            let sequence = SKAction.sequence(actions)
            hshoeNode.run(sequence) { [weak self] in
                guard let self = self else { return }
                if self.viewModel.pillarPositions.contains(where: { $0.x == final.x && $0.y == final.y }) {
                    hshoeNode.color = .green
                    hshoeNode.colorBlendFactor = 0.5
                }
                self.animationsCompleted += 1
                if self.animationsCompleted == self.horseshoeNodes.count {
                    self.checkGameOver()
                }
            }
        }
        
        if horseshoeNodes.isEmpty {
            checkGameOver()
        }
    }
    
    func checkGameOver() {
        if viewModel.isGameOver {
            let message = viewModel.didWin ? "Win!" : "Loose!"
            presentGameOver(message: message)
        }
    }
    
    func presentGameOver(message: String) {
        let overlay = SKShapeNode(rectOf: CGSize(width: boardSize * 0.8, height: boardSize * 0.4), cornerRadius: 20)
        overlay.fillColor = .black
        overlay.alpha = 0.7
        overlay.position = CGPoint(x: 0, y: 0)
        overlay.zPosition = 200
        boardNode.addChild(overlay)
        
        let label = SKLabelNode(text: message)
        label.fontName = "Helvetica-Bold"
        label.fontSize = 40
        label.fontColor = .white
        label.position = CGPoint(x: 0, y: -label.frame.height / 2)
        label.zPosition = 201
        overlay.addChild(label)
    }
}
