//
//  LevelManager.swift

import Foundation

struct Position: Equatable {
    let x: Int
    let y: Int
}

struct LevelConfiguration {
    let gridWidth: Int
    let gridHeight: Int
    let playerStart: Position
    let horseshoes: [Position]
    let pillars: [Position]
    let obstacles: [Position]
    let emptyTiles: [Position]
}

enum LevelType: Int, CaseIterable {
    case level1 = 1
    case level2
    case level3
    case level4
    case level5
    case level6
}

@MainActor
final class LevelManager: ObservableObject {
    
    static let shared = LevelManager()
    
    @Published private(set) var currentLevel: LevelType = .level1
    @Published private(set) var unlockedLevels: Set<LevelType> = [.level1]
    
    private let defaults = UserDefaults.standard
    private let unlockedLevelsKey = "unlockedLevels"
    private let currentLevelKey = "currentLevel"
    
    private init() {
        loadProgress()
    }
    
    // MARK: - Level Configurations
    
    private static let levelConfigurations: [LevelType: LevelConfiguration] = [
        .level1: LevelConfiguration(
            gridWidth: 6,
            gridHeight: 2,
            playerStart: Position(x: 0, y: 1),
            horseshoes: [Position(x: 2, y: 1)],
            pillars: [Position(x: 4, y: 1)],
            obstacles: [Position(x: 1, y: 1)],
            emptyTiles: [Position(x: 0, y: 0)]
        ),
        
        .level2: LevelConfiguration(
            gridWidth: 7,
            gridHeight: 7,
            playerStart: Position(x: 3, y: 3),
            horseshoes: [
                Position(x: 1, y: 3),
                Position(x: 3, y: 1),
                Position(x: 5, y: 3),
                Position(x: 3, y: 5)
            ],
            pillars: [
                Position(x: 0, y: 3),
                Position(x: 3, y: 0),
                Position(x: 3, y: 6),
                Position(x: 6, y: 3)
            ],
            obstacles: [
                Position(x: 2, y: 2),
                Position(x: 3, y: 2),
                Position(x: 4, y: 2),
                Position(x: 4, y: 3),
                Position(x: 4, y: 4),
                Position(x: 3, y: 4),
                Position(x: 2, y: 4),
                Position(x: 2, y: 3)
            ],
            emptyTiles: [
                Position(x: 0, y: 0),
                Position(x: 6, y: 0),
                Position(x: 0, y: 6),
                Position(x: 6, y: 6)
            ]
        ),
        
        .level3: LevelConfiguration(
            gridWidth: 7,
            gridHeight: 4,
            playerStart: Position(x: 4, y: 0),
            horseshoes: [
                Position(x: 1, y: 3),
                Position(x: 4, y: 3)
            ],
            pillars: [
                Position(x: 0, y: 3),
                Position(x: 3, y: 3)
            ],
            obstacles: [
                Position(x: 0, y: 1),
                Position(x: 1, y: 1),
                Position(x: 2, y: 1),
                Position(x: 3, y: 1),
                Position(x: 4, y: 1),
                Position(x: 5, y: 1)
            ],
            emptyTiles: [
                Position(x: 0, y: 0)
            ]
        ),
        
        .level4: LevelConfiguration(
            gridWidth: 5,
            gridHeight: 8,
            playerStart: Position(x: 1, y: 2),
            horseshoes: [Position(x: 2, y: 1)],
            pillars: [Position(x: 3, y: 4)],
            obstacles: [
                Position(x: 0, y: 1),
                Position(x: 1, y: 5)
            ],
            emptyTiles: [
                Position(x: 0, y: 0),
                Position(x: 0, y: 2),
                Position(x: 4, y: 5),
                Position(x: 4, y: 6),
                Position(x: 4, y: 7),
                Position(x: 3, y: 7)
            ]
        ),
        
        .level5: LevelConfiguration(
            gridWidth: 6,
            gridHeight: 9,
            playerStart: Position(x: 1, y: 1),
            horseshoes: [Position(x: 4, y: 1)],
            pillars: [Position(x: 5, y: 5)],
            obstacles: [
                Position(x: 3, y: 1),
                Position(x: 2, y: 3),
                Position(x: 1, y: 4),
                Position(x: 0, y: 7),
                Position(x: 3, y: 8),
                Position(x: 4, y: 4),
                Position(x: 5, y: 4)
            ],
            emptyTiles: [
                Position(x: 0, y: 0),
                Position(x: 0, y: 1),
                Position(x: 1, y: 0),
                Position(x: 5, y: 0),
                Position(x: 0, y: 8),
                Position(x: 4, y: 8),
                Position(x: 5, y: 8)
            ]
        ),
        
        .level6: LevelConfiguration(
            gridWidth: 9,
            gridHeight: 8,
            playerStart: Position(x: 1, y: 0),
            horseshoes: [
                Position(x: 2, y: 1),
                Position(x: 6, y: 1),
                Position(x: 1, y: 5),
                Position(x: 7, y: 5)
            ],
            pillars: [
                Position(x: 1, y: 3),
                Position(x: 1, y: 7),
                Position(x: 7, y: 3),
                Position(x: 7, y: 7)
            ],
            obstacles: [
                Position(x: 0, y: 1),
                Position(x: 0, y: 5),
                Position(x: 3, y: 1),
                Position(x: 4, y: 0),
                Position(x: 5, y: 1),
                Position(x: 8, y: 1),
                Position(x: 3, y: 4),
                Position(x: 5, y: 4),
                Position(x: 8, y: 5)
            ],
            emptyTiles: [
                Position(x: 0, y: 4),
                Position(x: 1, y: 4),
                Position(x: 2, y: 4),
                Position(x: 6, y: 4),
                Position(x: 7, y: 4),
                Position(x: 8, y: 4)
            ]
        )
    ]
    
    func configuration(for level: LevelType) -> LevelConfiguration {
        guard let config = Self.levelConfigurations[level] else {
            fatalError("Configuration not found for level \(level)")
        }
        return config
    }
    
    func unlockLevel(_ level: LevelType) {
        unlockedLevels.insert(level)
        saveProgress()
    }
    
    func moveToNextLevel() {
        guard let nextLevel = LevelType(rawValue: currentLevel.rawValue + 1) else {
            currentLevel = .level1
            return
        }
        currentLevel = nextLevel
        unlockLevel(nextLevel)
        saveProgress()
    }
    
    // MARK: - Progress Management
    
    private func saveProgress() {
        let unlockedLevelNumbers = unlockedLevels.map { $0.rawValue }
        defaults.set(unlockedLevelNumbers, forKey: unlockedLevelsKey)
        defaults.set(currentLevel.rawValue, forKey: currentLevelKey)
    }
    
    private func loadProgress() {
        if let savedLevelNumbers = defaults.array(forKey: unlockedLevelsKey) as? [Int] {
            unlockedLevels = Set(savedLevelNumbers.compactMap { LevelType(rawValue: $0) })
        }
        
        if let savedCurrentLevel = defaults.value(forKey: currentLevelKey) as? Int,
           let level = LevelType(rawValue: savedCurrentLevel) {
            currentLevel = level
        }
    }
    
    func resetProgress() {
        currentLevel = .level1
        unlockedLevels = [.level1]
        saveProgress()
    }
}
