//
// GameScene.swift

import SpriteKit

class GameScene: SKScene {
    // MARK: - Constants
    
    private enum Constants {
        static let moveAnimationDuration: TimeInterval = 0.2
        static let boardScale: CGFloat = 0.8
        static let cellOverlapFactor: CGFloat = 0.55
        static let controlPanelWidthLandscape: CGFloat = 140
        
        enum NodeScale {
            static let player: CGFloat = 0.5
            static let horseshoe: CGFloat = 0.45
            static let obstacle: CGFloat = 0.6
            static let pillar: CGFloat = 0.2
        }
        
        enum ZPosition {
            // Base layers
            static let background: CGFloat = -1000
            static let boardBase: CGFloat = 0
            static let gameObjects: CGFloat = 1000
            
            // Object types z-offset within their row
            enum GameObjectType {
                case player
                case horseshoe
                case obstacle
                case pillar
                
                var zOffset: CGFloat {
                    switch self {
                    case .player: return 5
                    case .horseshoe: return 3
                    case .obstacle: return 4
                    case .pillar: return 2
                    }
                }
            }
            
            // Calculate z-position for game objects
            static func forGameObject(at row: Int, type: GameObjectType) -> CGFloat {
                // Higher rows (further from screen) should have lower z-index
                let baseZ = gameObjects + CGFloat(1000 - row * 10)
                return baseZ + type.zOffset
            }
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
    
    private var cellSize: CGFloat {
        let maxWidth = availableGameArea.width * Constants.boardScale
        let maxHeight = availableGameArea.height * Constants.boardScale
        
        let cellSizeByWidth = maxWidth / CGFloat(viewModel.gridWidth)
        
        let totalHeightByWidth = cellSizeByWidth + (cellSizeByWidth - (cellSizeByWidth * Constants.cellOverlapFactor)) * CGFloat(viewModel.gridHeight - 1)
        
        if totalHeightByWidth > maxHeight {
            let factor = 1 + (1 - Constants.cellOverlapFactor) * CGFloat(viewModel.gridHeight - 1)
            return maxHeight / factor
        }
        
        return cellSizeByWidth
    }
    
    private var availableGameArea: CGRect {
        let isLandscape = size.width > size.height
        if isLandscape {
            let leftPadding = Constants.controlPanelWidthLandscape
            let rightPadding = Constants.controlPanelWidthLandscape
            let width = size.width - leftPadding - rightPadding
            return CGRect(x: leftPadding, y: 0, width: width, height: size.height)
        } else {
            let height = size.height
            return CGRect(x: 0, y: 0, width: size.width, height: height)
        }
    }
    
    private var boardWidth: CGFloat {
        cellSize * CGFloat(viewModel.gridWidth)
    }
    
    private var boardHeight: CGFloat {
        cellSize + (cellSize - cellOverlap) * CGFloat(viewModel.gridHeight - 1)
    }
    
    private var cellOverlap: CGFloat {
        cellSize * Constants.cellOverlapFactor
    }
    
    private var actualBoardHeight: CGFloat {
        cellSize + (cellSize - cellOverlap) * CGFloat(viewModel.gridHeight - 1)
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
        boardNode.removeAllChildren()
        horseshoeNodes.removeAll()
        obstacleNodes.removeAll()
        pillarNodes.removeAll()
        playerNode = nil
        
        setupScene()
        setupBoard()
        setupGameObjects()
    }
    
    func movePlayer(direction: GameViewModel.Direction) {
        viewModel.movePlayer(direction: direction)
        let newPosition = objectPositionFor(gridX: viewModel.playerPosition.x,
                                            gridY: viewModel.playerPosition.y)
        
        switch direction {
        case .left:
            playerNode.xScale = -abs(playerNode.xScale)
        case .right:
            playerNode.xScale = abs(playerNode.xScale)
        default:
            break
        }
        
        let moveAction = SKAction.move(to: newPosition, duration: Constants.moveAnimationDuration)
        let updateZAction = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.updateObjectZPosition(self.playerNode, type: .player, row: self.viewModel.playerPosition.y)
        }
        
        playerNode.run(SKAction.sequence([moveAction, updateZAction]))
    }
    
    func performThrow() {
        guard !horseshoeNodes.isEmpty else { return }
        
        let scaleUp = SKAction.scale(to: 1.15, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        let throwAnimation = SKAction.sequence([scaleUp, scaleDown])
        playerNode.run(throwAnimation)
        
        let initialPositions = viewModel.horseshoePositions
        let throwResult = viewModel.performThrow()
        var movingHorseshoes = 0
        var completedAnimations = 0
        
        for (index, _) in horseshoeNodes.enumerated() {
            let initial = initialPositions[index]
            let final = throwResult.newPositions[index]
            if initial != final {
                movingHorseshoes += 1
            }
        }
        
        if movingHorseshoes == 0 {
            handleThrowResult(throwResult)
            return
        }
        
        for (index, hshoeNode) in horseshoeNodes.enumerated() {
            let initial = initialPositions[index]
            let final = throwResult.newPositions[index]
            
            guard initial != final else { continue }
            
            let path = calculatePath(from: initial, to: final)
            
            animateHorseshoe(hshoeNode, along: path) { [weak self] in
                guard let self = self else { return }
                
                if throwResult.placedHorseshoes.contains(index) {
                    self.highlightHorseshoe(hshoeNode)
                }
                
                completedAnimations += 1
                
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
        
        let centerX = availableGameArea.midX - size.width/2
        let centerY = availableGameArea.midY - size.height/2
        
        let horizontalOffset = centerX - boardWidth/2
        let verticalOffset = centerY - boardHeight/2
        
        boardNode.position = CGPoint(x: horizontalOffset, y: verticalOffset)
        boardNode.zPosition = Constants.ZPosition.boardBase
        addChild(boardNode)
    }
    
    private func setupBoard() {
        let cubeTexture = SKTexture(imageNamed: ImageNames.gameCube.rawValue)
        
        for y in (0..<viewModel.gridHeight).reversed() {
            for x in 0..<viewModel.gridWidth {
                let position = positionFor(gridX: x, gridY: y)
                
                let isEmptyTile = viewModel.emptyTilePositions.contains { $0.x == x && $0.y == y }
                
                if !isEmptyTile {
                    let cubeNode = SKSpriteNode(texture: cubeTexture,
                                                size: CGSize(width: cellSize, height: cellSize))
                    cubeNode.position = position
                    cubeNode.zPosition = Constants.ZPosition.boardBase
                    boardNode.addChild(cubeNode)
                }
            }
        }
    }
    
    private func updateObjectZPosition(_ node: SKSpriteNode, type: Constants.ZPosition.GameObjectType, row: Int) {
        node.zPosition = Constants.ZPosition.forGameObject(at: row, type: type)
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
        let texture = SKTexture(image: UIImage(resource: SkinManager.shared.currentSkin.imageResource))
        
        playerNode = SKSpriteNode(texture: texture, size: size)
        playerNode.position = objectPositionFor(gridX: viewModel.playerPosition.x,
                                                gridY: viewModel.playerPosition.y)
        updateObjectZPosition(playerNode, type: .player, row: viewModel.playerPosition.y)
        boardNode.addChild(playerNode)
    }
    
    private func setupHorseshoes() {
        let size = CGSize(width: cellSize * Constants.NodeScale.horseshoe,
                          height: cellSize * Constants.NodeScale.horseshoe)
        let texture = SKTexture(imageNamed: ImageNames.hShoe.rawValue)
        
        for position in viewModel.horseshoePositions {
            let node = SKSpriteNode(texture: texture, size: size)
            node.position = objectPositionFor(gridX: position.x, gridY: position.y)
            updateObjectZPosition(node, type: .horseshoe, row: position.y)
            boardNode.addChild(node)
            horseshoeNodes.append(node)
        }
    }
    
    private func setupObstacles() {
        let size = CGSize(width: cellSize * Constants.NodeScale.obstacle,
                          height: cellSize * Constants.NodeScale.obstacle * 1.3)
        
        for position in viewModel.obstaclePositions {
            let texture = SKTexture(imageNamed: ImageNames.cactus.rawValue)
            let node = SKSpriteNode(texture: texture, size: size)
            node.position = objectPositionFor(gridX: position.x, gridY: position.y)
            updateObjectZPosition(node, type: .obstacle, row: position.y)
            boardNode.addChild(node)
            obstacleNodes.append(node)
        }
    }
    
    private func setupPillars() {
        let size = CGSize(width: cellSize * Constants.NodeScale.pillar,
                          height: cellSize * Constants.NodeScale.pillar * 3.5)
        let texture = SKTexture(imageNamed: ImageNames.pillar.rawValue)
        
        for position in viewModel.pillarPositions {
            let node = SKSpriteNode(texture: texture, size: size)
            node.position = objectPositionFor(gridX: position.x, gridY: position.y)
            updateObjectZPosition(node, type: .pillar, row: position.y)
            boardNode.addChild(node)
            pillarNodes.append(node)
        }
    }
    
    // MARK: - Private Methods - Position Calculation
    
    private func positionFor(gridX: Int, gridY: Int) -> CGPoint {
        let xPos = CGFloat(gridX) * cellSize + cellSize / 2
        let yPos = CGFloat(gridY) * (cellSize - cellOverlap) + cellSize / 2
        
        return CGPoint(x: xPos, y: yPos)
    }
    
    private func objectPositionFor(gridX: Int, gridY: Int) -> CGPoint {
        let basePosition = positionFor(gridX: gridX, gridY: gridY)
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
            let updateZAction = SKAction.run { [weak self] in
                guard let self = self else { return }
                self.updateObjectZPosition(node, type: .horseshoe, row: gridPos.y)
            }
            actions.append(moveAction)
            actions.append(updateZAction)
        }
        
        let sequence = SKAction.sequence(actions)
        node.run(sequence, completion: completion)
    }
    
    private func highlightHorseshoe(_ node: SKSpriteNode) {
        node.color = .green
        node.colorBlendFactor = 0.5
    }
    
    private func handleThrowResult(_ result: GameViewModel.ThrowResult) {
        if viewModel.isGameLost {
            gameOverCallback?(false)
        } else if viewModel.isVictory() {
            gameOverCallback?(true)
        } else {
            //
        }
    }
}
