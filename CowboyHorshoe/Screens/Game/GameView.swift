//
//  GameView.swift

import SwiftUI
import SpriteKit

struct GameView: View {
    
    @StateObject var viewModel = GameViewModel()
    
    // Инициализируем сцену
    @State private var scene: GameScene = {
        let scene = GameScene(size: CGSize(width: 400, height: 400))
        scene.scaleMode = .aspectFit
        return scene
    }()
    
    var body: some View {
        VStack {
            SpriteView(scene: scene)
                .frame(width: 400, height: 400)
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

#Preview {
    GameView()
}
