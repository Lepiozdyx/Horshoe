//  GameView.swift

import SwiftUI
import SpriteKit

struct GameView: View {
    @StateObject var viewModel = GameViewModel()
    
    // Инициализируем сцену с размером 400x400 (она сама масштабируется в SpriteView)
    @State private var scene: GameScene = {
        let scene = GameScene(size: CGSize(width: 400, height: 400))
        scene.scaleMode = .aspectFit
        return scene
    }()
    
    var body: some View {
        NavigationView {
            VStack {
                // Отображаем игровую сцену
                SpriteView(scene: scene)
                    .frame(width: 400, height: 400)
                    .border(Color.black)
                    .onAppear {
                        // Передаём модель игры в сцену
                        scene.viewModel = viewModel
                    }
                
                // Элементы управления: стрелки и кнопка "Throw"
                VStack(spacing: 16) {
                    // Верхняя стрелка
                    Button(action: {
                        scene.movePlayer(direction: .up)
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                    
                    HStack(spacing: 16) {
                        // Левая стрелка
                        Button(action: {
                            scene.movePlayer(direction: .left)
                        }) {
                            Image(systemName: "arrow.left.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                        }
                        
                        // Кнопка "Throw"
                        Button(action: {
                            scene.performShot()
                        }) {
                            Text("Throw")
                                .font(.headline)
                                .frame(width: 80, height: 50)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        // Правая стрелка
                        Button(action: {
                            scene.movePlayer(direction: .right)
                        }) {
                            Image(systemName: "arrow.right.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                        }
                    }
                    
                    // Нижняя стрелка
                    Button(action: {
                        scene.movePlayer(direction: .down)
                    }) {
                        Image(systemName: "arrow.down.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                }
                .padding()
            }
            .navigationTitle("Game")
        }
    }
}

#Preview {
    GameView()
}

