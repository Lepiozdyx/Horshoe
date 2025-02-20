//
//  GameView.swift

import SwiftUI
import SpriteKit

struct GameView: View {
    @StateObject var viewModel = GameViewModel()
    
    @State private var scene: GameScene = {
        let scene = GameScene(size: CGSize(width: 600, height: 600))
        scene.scaleMode = .fill
        return scene
    }()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                SpriteView(scene: scene)
//                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()
                
                ControlPanelView(scene: scene)
            }
            .onAppear {
                scene.viewModel = viewModel
            }
        }
    }
}

#Preview {
    GameView()
}
