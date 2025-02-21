//
//  ControlPanelView.swift

import SwiftUI

struct ControlPanelView: View {
    
    let scene: GameScene
    
    var body: some View {
        HStack {
            ZStack {
                VStack(spacing: 20) {
                    Button {
                        scene.movePlayer(direction: .up)
                    } label: {
                        Image(.arrow)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 60)
                            .rotationEffect(.degrees(-90))
                    }
                    
                    Button {
                        scene.movePlayer(direction: .down)
                    } label: {
                        Image(.arrow)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 60)
                            .rotationEffect(.degrees(90))
                    }
                }
                
                HStack(spacing: 30) {
                    Button {
                        scene.movePlayer(direction: .left)
                    } label: {
                        Image(.arrow)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 60)
                            .rotationEffect(.degrees(180))
                    }
                    
                    Button {
                        scene.movePlayer(direction: .right)
                    } label: {
                        Image(.arrow)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 60)
                    }
                }
                
                Image(.controlRectangle)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 45)
                    .rotationEffect(.degrees(90))
            }
            
            Spacer()
            
            Button {
                scene.performThrow()
            } label: {
                Image(.throw)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 120)
            }
        }
    }
}

#Preview {
    ControlPanelView(scene: GameScene())
}
