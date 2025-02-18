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
            
            // Элементы управления: стрелки и кнопка "Throw"
            ControlPanelView(scene: scene)
        }
        .padding()
    }
}

#Preview {
    GameView()
}

struct ControlPanelView: View {
    
    let scene: GameScene
    
    var body: some View {
        HStack {
            ZStack {
                VStack(spacing: 20) {
                    Button {
                        scene.movePlayer(direction: .up)
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                    
                    Button {
                        scene.movePlayer(direction: .down)
                    } label: {
                        Image(systemName: "arrow.down.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                }
                
                HStack(spacing: 20) {
                    Button {
                        scene.movePlayer(direction: .left)
                    } label: {
                        Image(systemName: "arrow.left.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                    
                    Button {
                        scene.movePlayer(direction: .right)
                    } label: {
                        Image(systemName: "arrow.right.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                }
            }
            
            Spacer()
            
            Button {
                scene.performShot()
            } label: {
                Text("Throw")
                    .frame(width: 100, height: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }
}
