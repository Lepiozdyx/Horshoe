//
//  Types.swift

import SwiftUI

enum CharacterType: String, Codable {
    case cowboy, cowgirl

    var images: [ImageResource] {
        switch self {
        case .cowboy: return [.cowboy, .cowboy1, .cowboy2, .cowboy3, .cowboy4, .cowboy5]
        case .cowgirl: return [.cowgirl, .cowgirl1, .cowgirl2, .cowgirl3, .cowgirl4, .cowgirl5]
        }
    }
    
    var defaultSkin: ImageResource {
        images[0]
    }
}
