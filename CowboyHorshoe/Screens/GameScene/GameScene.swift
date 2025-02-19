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
    var horseshoeNodes: [SKSpriteNode] = []
    var obstacleNodes: [SKSpriteNode] = []
    var pillarNodes: [SKSpriteNode] = []  // Для нескольких столбов.
    
    // Счётчик завершённых анимаций подков.
    var animationsCompleted = 0
    
    override func didMove(to view: SKView) {
        backgroundColor = .white
        setupBackgroundGrid()
        setupNodes()
    }
    
    // Отрисовка сетки.
    func setupBackgroundGrid() {
        let gridCount = viewModel.gridSize
        let cubeTexture = SKTexture(imageNamed: ImageNames.gameCube.rawValue)
        
        for x in 0..<gridCount {
            for y in 0..<gridCount {
                let cubeNode = SKSpriteNode(texture: cubeTexture, size: CGSize(width: cellSize, height: cellSize))
                cubeNode.position = positionFor(gridX: x, gridY: y)
                cubeNode.zPosition = -1
                addChild(cubeNode)
            }
        }
    }
    
    // Создание узлов для игрока, подков, препятствий и столбов.
    func setupNodes() {
        // Ковбой (игрок)
        let playerSize = CGSize(width: cellSize * 0.8, height: cellSize * 0.8)
        let playerTexture = SKTexture(imageNamed: ImageNames.cowboy.rawValue)
        playerNode = SKSpriteNode(texture: playerTexture, size: playerSize)
        playerNode.position = objectPositionFor(gridX: viewModel.playerPosition.x, gridY: viewModel.playerPosition.y)
        playerNode.zPosition = 1
        addChild(playerNode)
        
        // Подковы.
        for pos in viewModel.horseshoePositions {
            let horseshoeSize = CGSize(width: cellSize * 0.6, height: cellSize * 0.5)
            let hshoeTexture = SKTexture(imageNamed: ImageNames.hShoe.rawValue)
            let hshoe = SKSpriteNode(texture: hshoeTexture, size: horseshoeSize)
            hshoe.position = objectPositionFor(gridX: pos.x, gridY: pos.y)
            hshoe.zPosition = 1
            addChild(hshoe)
            horseshoeNodes.append(hshoe)
        }
        
        // Препятствия.
        for pos in viewModel.obstaclePositions {
            let obstacleSize = CGSize(width: cellSize, height: cellSize)
            let obstacleTexture = SKTexture(imageNamed: ImageNames.cactus.rawValue)
            let obstacle = SKSpriteNode(texture: obstacleTexture, size: obstacleSize)
            obstacle.position = objectPositionFor(gridX: pos.x, gridY: pos.y)
            obstacle.zPosition = 1
            addChild(obstacle)
            obstacleNodes.append(obstacle)
        }
        
        // Столбы.
        for pos in viewModel.pillarPositions {
            let pillarSize = CGSize(width: cellSize * 0.2, height: cellSize * 0.8)
            let pillarTexture = SKTexture(imageNamed: ImageNames.pillar.rawValue)
            let pillar = SKSpriteNode(texture: pillarTexture, size: pillarSize)
            pillar.position = objectPositionFor(gridX: pos.x, gridY: pos.y)
            pillar.zPosition = 1
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
    
    func objectPositionFor(gridX: Int, gridY: Int) -> CGPoint {
        let basePos = positionFor(gridX: gridX, gridY: gridY)
        // Эмпирически подбираемый сдвиг: например, при cellSize = 80, сдвиг 0.75*cellSize ≈ 60
        let objectYOffset = cellSize * 0.75
        return CGPoint(x: basePos.x, y: basePos.y + objectYOffset)
    }
    
    // Метод перемещения игрока.
    func movePlayer(direction: Direction) {
        viewModel.movePlayer(direction: direction)
        let newPlayerPos = objectPositionFor(gridX: viewModel.playerPosition.x, gridY: viewModel.playerPosition.y)
        playerNode.run(SKAction.move(to: newPlayerPos, duration: 0.2))
    }
    
    /// Выполняет анимацию броска подков:
    /// - Сохраняет начальные позиции подков.
    /// - Вызывает логику броска в модели.
    /// - Анимирует перемещение каждой подковы по вычисленному пути.
    /// - После завершения всех анимаций проверяет, достигнут ли выигрыш/проигрыш, и выводит оверлей.
    func performThrow() {
        animationsCompleted = 0
        // Сохраняем изначальные позиции подков.
        let initialPositions = viewModel.horseshoePositions
        // Вызываем логику броска.
        viewModel.performThrow()
        
        // Анимация движения каждой подковы.
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
            hshoeNode.run(sequence, completion: { [weak self] in
                guard let self = self else { return }
                // Если подкова достигла столба, можно изменить внешний вид (например, наложить зеленую заливку).
                if self.viewModel.pillarPositions.contains(where: { $0.x == final.x && $0.y == final.y }) {
                    hshoeNode.color = .green
                    hshoeNode.colorBlendFactor = 0.5
                }
                self.animationsCompleted += 1
                if self.animationsCompleted == self.horseshoeNodes.count {
                    self.checkGameOver()
                }
            })
        }
        
        if horseshoeNodes.isEmpty {
            checkGameOver()
        }
    }
    
    // Проверка состояния игры и вывод оверлея при окончании.
    func checkGameOver() {
        if viewModel.isGameOver {
            let message = viewModel.didWin ? "Win!" : "Loose!"
            presentGameOver(message: message)
        }
    }

    // Отображение оверлея с сообщением о завершении уровня.
    func presentGameOver(message: String) {
        let overlay = SKShapeNode(rectOf: CGSize(width: size.width * 0.8, height: size.height * 0.4), cornerRadius: 20)
        overlay.fillColor = .black
        overlay.alpha = 0.7
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = 200
        addChild(overlay)
        
        let label = SKLabelNode(text: message)
        label.fontName = "Helvetica-Bold"
        label.fontSize = 40
        label.fontColor = .white
        label.position = CGPoint(x: 0, y: -label.frame.height / 2)
        label.zPosition = 201
        overlay.addChild(label)
    }
}
