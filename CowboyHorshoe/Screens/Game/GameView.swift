//
//  GameView.swift

import SwiftUI
import SpriteKit

struct GameView: View {
    
    @StateObject var viewModel = GameViewModel()
    @State private var scene: GameScene = {
        let scene = GameScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .aspectFit
        return scene
    }()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            SpriteView(scene: scene)
                .ignoresSafeArea()
            
            ControlPanelView(scene: scene)
                .padding(.horizontal)
                .padding(.bottom, 20)
        }
        .onAppear {
            scene.viewModel = viewModel
        }
    }
}

#Preview {
    GameView()
}
