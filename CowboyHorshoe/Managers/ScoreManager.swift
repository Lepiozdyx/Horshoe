//
//  ScoreManager.swift

import Foundation

@MainActor
final class ScoreManager: ObservableObject {
    
    static let shared = ScoreManager()
    
    @Published private(set) var score: Int  {
        didSet {
            UserDefaults.standard.set(score, forKey: "playerScore")
        }
    }
    
    private init() {
        self.score = UserDefaults.standard.integer(forKey: "playerScore")
    }
    
    func addScore(_ points: Int) {
        score += points
    }
}
