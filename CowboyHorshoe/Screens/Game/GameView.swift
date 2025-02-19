//
//  GameView.swift

import SwiftUI
import SpriteKit

struct GameView: View {
    
    @StateObject var viewModel = GameViewModel()
    
    @State private var scene: GameScene = {
        let scene = GameScene(size: CGSize(width: 200, height: 200))
        scene.scaleMode = .fill
        return scene
    }()
    
    var body: some View {
        ZStack {
            BackgroundView(imageName: .bg2)
            
            VStack {
                Spacer()
                
                SpriteView(scene: scene)
                    .border(Color.black)
                    .onAppear {
                        scene.viewModel = viewModel
                    }
                
                Spacer()
                
                // Элементы управления: стрелки и кнопка "Throw"
                ControlPanelView(scene: scene)
            }
            .padding()
        }
    }
}

#Preview {
    GameView()
}
