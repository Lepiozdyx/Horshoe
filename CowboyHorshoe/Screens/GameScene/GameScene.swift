//
// GameScene.swift

import SpriteKit

class GameScene: SKScene {
    // MARK: - Constants
    
    private enum Constants {
        static let moveAnimationDuration: TimeInterval = 0.2
        static let boardScale: CGFloat = 0.8
        static let cellOverlapFactor: CGFloat = 0.55
        
        enum NodeScale {
            static let player: CGFloat = 0.5
            static let horseshoe: CGFloat = 0.45
            static let obstacle: CGFloat = 0.6
            static let pillar: CGFloat = 0.2
        }
        
        enum ZPosition {
            static let background: CGFloat = -100
            static let board: CGFloat = 0
            static let gameObject: CGFloat = 100
        }
    }
    
    // MARK: - Properties
    
    var viewModel: GameViewModel!
    
    var gameOverCallback: ((Bool) -> Void)?
    
    private var backgroundNode: SKSpriteNode?
    private var boardNode: SKNode!
    private var playerNode: SKSpriteNode!
    private var horseshoeNodes: [SKSpriteNode] = []
    private var obstacleNodes: [SKSpriteNode] = []
    private var pillarNodes: [SKSpriteNode] = []
    
    private var boardSize: CGFloat {
        min(size.width, size.height) * Constants.boardScale
    }
    
    private var cellSize: CGFloat {
        boardSize / CGFloat(viewModel.gridSize)
    }
    
    private var cellOverlap: CGFloat {
        cellSize * Constants.cellOverlapFactor
    }
    
    private var actualBoardHeight: CGFloat {
        cellSize + (cellSize - cellOverlap) * CGFloat(viewModel.gridSize - 1)
    }
    
    // MARK: - Scene Lifecycle
    
    override func didMove(to view: SKView) {
        guard viewModel != nil else {
            fatalError("GameScene requires a viewModel")
        }
        
        setupScene()
        setupBoard()
        setupGameObjects()
    }
    
    // MARK: - Public Methods
    
    func resetScene() {
        // Удаляем все игровые объекты
        boardNode.removeAllChildren()
        horseshoeNodes.removeAll()
        obstacleNodes.removeAll()
        pillarNodes.removeAll()
        playerNode = nil  // Обнуляем ссылку на игрока
        
        // Пересоздаем сцену с фоном
        setupScene()
        setupBoard()
        setupGameObjects()  // Это создаст новые объекты с позициями из viewModel
    }
    
    func movePlayer(direction: GameViewModel.Direction) {
        viewModel.movePlayer(direction: direction)
        let newPosition = objectPositionFor(gridX: viewModel.playerPosition.x,
                                          gridY: viewModel.playerPosition.y)
        
        playerNode.run(SKAction.move(to: newPosition, duration: Constants.moveAnimationDuration))
    }
    
    func performThrow() {
        guard !horseshoeNodes.isEmpty else { return }
        
        let initialPositions = viewModel.horseshoePositions
        let throwResult = viewModel.performThrow()
        var movingHorseshoes = 0
        var completedAnimations = 0
        
        // Подсчитываем количество подков, которые должны двигаться
        for (index, _) in horseshoeNodes.enumerated() {
            let initial = initialPositions[index]
            let final = throwResult.newPositions[index]
            if initial != final {
                movingHorseshoes += 1
            }
        }
        
        // Если нет движущихся подков, сразу проверяем результат
        if movingHorseshoes == 0 {
            handleThrowResult(throwResult)
            return
        }
        
        // Анимируем движущиеся подковы
        for (index, hshoeNode) in horseshoeNodes.enumerated() {
            let initial = initialPositions[index]
            let final = throwResult.newPositions[index]
            
            // Пропускаем неподвижные подковы
            guard initial != final else { continue }
            
            let path = calculatePath(from: initial, to: final)
            
            animateHorseshoe(hshoeNode, along: path) { [weak self] in
                guard let self = self else { return }
                
                if throwResult.placedHorseshoes.contains(index) {
                    self.highlightHorseshoe(hshoeNode)
                }
                
                completedAnimations += 1
                
                // Проверяем результат после завершения всех анимаций
                if completedAnimations == movingHorseshoes {
                    self.handleThrowResult(throwResult)
                }
            }
        }
    }
    
    // MARK: - Private Methods - Setup
    
    private func setupScene() {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        setupBackground()
        setupBoardNode()
    }
    
    private func setupBackground() {
        // Удаляем старый фон если он есть
        backgroundNode?.removeFromParent()
        
        let bgTexture = SKTexture(imageNamed: ImageNames.bg2.rawValue)
        let bgNode = SKSpriteNode(texture: bgTexture)
        bgNode.size = size
        bgNode.position = .zero
        bgNode.zPosition = Constants.ZPosition.background
        addChild(bgNode)
        backgroundNode = bgNode
    }
    
    private func setupBoardNode() {
        boardNode = SKNode()
        let verticalOffset = (boardSize - actualBoardHeight) / 2
        boardNode.position = CGPoint(x: 0, y: verticalOffset)
        boardNode.zPosition = Constants.ZPosition.board
        addChild(boardNode)
    }
    
    private func setupBoard() {
        let cubeTexture = SKTexture(imageNamed: ImageNames.gameCube.rawValue)
        
        for y in (0..<viewModel.gridSize).reversed() {
            for x in 0..<viewModel.gridSize {
                let position = positionFor(gridX: x, gridY: y)
                let zPosition = CGFloat(viewModel.gridSize - y)
                
                // Проверяем, является ли ячейка пустой
                let isEmptyTile = viewModel.emptyTilePositions.contains { $0.x == x && $0.y == y }
                
                if !isEmptyTile {
                    let cubeNode = SKSpriteNode(texture: cubeTexture,
                                              size: CGSize(width: cellSize, height: cellSize))
                    cubeNode.position = position
                    cubeNode.zPosition = zPosition
                    boardNode.addChild(cubeNode)
                }
            }
        }
    }
    
    private func setupGameObjects() {
        setupPlayer()
        setupHorseshoes()
        setupObstacles()
        setupPillars()
    }
    
    private func setupPlayer() {
        let size = CGSize(width: cellSize * Constants.NodeScale.player,
                          height: cellSize * Constants.NodeScale.player * 1.6)
        let texture = SKTexture(imageNamed: ImageNames.cowboy.rawValue)
        
        playerNode = SKSpriteNode(texture: texture, size: size)
        playerNode.position = objectPositionFor(gridX: viewModel.playerPosition.x,
                                                gridY: viewModel.playerPosition.y)
        playerNode.zPosition = Constants.ZPosition.gameObject
        boardNode.addChild(playerNode)
    }
    
    private func setupHorseshoes() {
        let size = CGSize(width: cellSize * Constants.NodeScale.horseshoe,
                         height: cellSize * Constants.NodeScale.horseshoe)
        let texture = SKTexture(imageNamed: ImageNames.hShoe.rawValue)
        
        for position in viewModel.horseshoePositions {
            let node = SKSpriteNode(texture: texture, size: size)
            node.position = objectPositionFor(gridX: position.x, gridY: position.y)
            node.zPosition = Constants.ZPosition.gameObject
            boardNode.addChild(node)
            horseshoeNodes.append(node)
        }
    }
    
    private func setupObstacles() {
        let size = CGSize(width: cellSize * Constants.NodeScale.obstacle,
                         height: cellSize * Constants.NodeScale.obstacle * 1.3) // Увеличиваем высоту для препятствий
        
        for position in viewModel.obstaclePositions {
            let texture = SKTexture(imageNamed: Int.random(in: 0...1) == 0 ?
                                  ImageNames.cactus.rawValue : ImageNames.fence.rawValue)
            let node = SKSpriteNode(texture: texture, size: size)
            node.position = objectPositionFor(gridX: position.x, gridY: position.y)
            node.zPosition = Constants.ZPosition.gameObject
            boardNode.addChild(node)
            obstacleNodes.append(node)
        }
    }
    
    private func setupPillars() {
        let size = CGSize(width: cellSize * Constants.NodeScale.pillar,
                         height: cellSize * Constants.NodeScale.pillar * 3.5) // Увеличиваем высоту для столбов
        let texture = SKTexture(imageNamed: ImageNames.pillar.rawValue)
        
        for position in viewModel.pillarPositions {
            let node = SKSpriteNode(texture: texture, size: size)
            node.position = objectPositionFor(gridX: position.x, gridY: position.y)
            node.zPosition = Constants.ZPosition.gameObject
            boardNode.addChild(node)
            pillarNodes.append(node)
        }
    }
    
    // MARK: - Private Methods - Position Calculation
    
    private func positionFor(gridX: Int, gridY: Int) -> CGPoint {
        let offsetX = -boardSize / 2
        let offsetY = -actualBoardHeight / 2
        
        let xPos = offsetX + CGFloat(gridX) * cellSize + cellSize / 2
        let yPos = offsetY + CGFloat(gridY) * (cellSize - cellOverlap) + cellSize / 2
        
        return CGPoint(x: xPos, y: yPos)
    }
    
    private func objectPositionFor(gridX: Int, gridY: Int) -> CGPoint {
        let basePosition = positionFor(gridX: gridX, gridY: gridY)
        // Смещаем объекты вверх для размещения их на поверхности ячейки
        return CGPoint(x: basePosition.x, y: basePosition.y + cellSize / 2)
    }
    
    // MARK: - Private Methods - Animation & Game Logic
    
    private func calculatePath(from start: (x: Int, y: Int),
                             to end: (x: Int, y: Int)) -> [(x: Int, y: Int)] {
        var path: [(x: Int, y: Int)] = []
        
        if start.x == end.x {
            let step = end.y > start.y ? 1 : -1
            for y in stride(from: start.y + step, through: end.y, by: step) {
                path.append((x: start.x, y: y))
            }
        } else if start.y == end.y {
            let step = end.x > start.x ? 1 : -1
            for x in stride(from: start.x + step, through: end.x, by: step) {
                path.append((x: x, y: start.y))
            }
        }
        
        return path
    }
    
    private func animateHorseshoe(_ node: SKSpriteNode,
                                 along path: [(x: Int, y: Int)],
                                 completion: @escaping () -> Void) {
        var actions: [SKAction] = []
        
        for gridPos in path {
            let destination = objectPositionFor(gridX: gridPos.x, gridY: gridPos.y)
            let moveAction = SKAction.move(to: destination, duration: Constants.moveAnimationDuration)
            actions.append(moveAction)
        }
        
        let sequence = SKAction.sequence(actions)
        node.run(sequence, completion: completion)
    }
    
    private func highlightHorseshoe(_ node: SKSpriteNode) {
        node.color = .green
        node.colorBlendFactor = 0.5
    }
    
    private func handleThrowResult(_ result: GameViewModel.ThrowResult) {
        print("\n📍 Проверка результата броска:")
        
        if viewModel.isGameLost {
            print("❌ ПОРАЖЕНИЕ: Подкова вышла за пределы поля")
            gameOverCallback?(false)
        } else if viewModel.isVictory() {
            print("🏆 ПОБЕДА: Все столбы заняты подковами")
            gameOverCallback?(true)
        } else {
            print("🎮 Игра продолжается...")
            print("- Подковы на столбах: \(result.placedHorseshoes.count)")
            print("- Всего столбов: \(viewModel.pillarPositions.count)")
        }
    }
}
