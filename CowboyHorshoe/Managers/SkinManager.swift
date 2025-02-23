//
//  SkinManager.swift

import Foundation
import SwiftUI

struct PlayerSkin: Codable, Equatable {
    let type: CharacterType
    let imageIndex: Int
    
    var imageResource: ImageResource {
        type.images[imageIndex]
    }
}

@MainActor
final class SkinManager: ObservableObject {
    static let shared = SkinManager()
    
    @Published private(set) var currentSkin: PlayerSkin
    @Published private(set) var purchasedSkinIndexes: Set<String>
    
    private let defaults = UserDefaults.standard
    private let purchasedSkinsKey = "purchasedSkins"
    private let currentSkinKey = "currentSkin"
    
    private init() {

        let defaultSkins = Set([
            "\(CharacterType.cowboy.rawValue)_0",
            "\(CharacterType.cowgirl.rawValue)_0"
        ])
        
        if let savedSkins = defaults.stringArray(forKey: purchasedSkinsKey) {
            self.purchasedSkinIndexes = Set(savedSkins)
        } else {
            self.purchasedSkinIndexes = defaultSkins
        }
        
        if let savedSkinData = defaults.data(forKey: currentSkinKey),
           let savedSkin = try? JSONDecoder().decode(PlayerSkin.self, from: savedSkinData) {
            self.currentSkin = savedSkin
        } else {
            self.currentSkin = PlayerSkin(type: .cowboy, imageIndex: 0)
        }
        
        if defaults.stringArray(forKey: purchasedSkinsKey) == nil {
            savePurchasedSkins()
        }
        if defaults.data(forKey: currentSkinKey) == nil {
            saveCurrentSkin()
        }
    }
    
    private func skinKey(type: CharacterType, index: Int) -> String {
        "\(type.rawValue)_\(index)"
    }
    
    func purchaseSkin(type: CharacterType, imageIndex: Int) -> Bool {
        let key = skinKey(type: type, index: imageIndex)
        guard !purchasedSkinIndexes.contains(key) else { return false }
        
        let cost = 50
        guard ScoreManager.shared.score >= cost else { return false }
        
        ScoreManager.shared.addScore(-cost)
        purchasedSkinIndexes.insert(key)
        savePurchasedSkins()
        return true
    }
    
    func selectSkin(type: CharacterType, imageIndex: Int) {
        let key = skinKey(type: type, index: imageIndex)
        guard purchasedSkinIndexes.contains(key) else { return }
        
        let newSkin = PlayerSkin(type: type, imageIndex: imageIndex)
        currentSkin = newSkin
        saveCurrentSkin()
    }
    
    func isSkinPurchased(type: CharacterType, imageIndex: Int) -> Bool {
        let key = skinKey(type: type, index: imageIndex)
        return purchasedSkinIndexes.contains(key)
    }
    
    private func savePurchasedSkins() {
        defaults.set(Array(purchasedSkinIndexes), forKey: purchasedSkinsKey)
    }
    
    private func saveCurrentSkin() {
        if let encoded = try? JSONEncoder().encode(currentSkin) {
            defaults.set(encoded, forKey: currentSkinKey)
        }
    }
}
