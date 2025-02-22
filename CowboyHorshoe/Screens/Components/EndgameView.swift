//
//  EndgameView.swift
//  CowboyHorshoe
//
//  Created by Alex on 18.02.2025.
//

import SwiftUI

struct EndgameView: View {
    
    var isVictory: Bool
    
    let goToMenuAction: () -> ()
    let tryAgainAction: () -> ()
    let nextLvlAction: () -> ()
    
    var body: some View {
        ZStack {
            BackgroundView(imageName: isVictory ? .bg1 : .bg2)
            
            ZStack {
                Image(.underlay5)
                    .resizable()
                    .frame(maxWidth: 400, maxHeight: 400)
                    .overlay(alignment: .top) {
                        Image(isVictory ? .win : .lose)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 180)
                            .offset(x: 20, y: 45)
                    }
                    .padding()
                
                VStack {
                    if isVictory {
                        HStack {
                            Image(.horseshoe)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 35)
                            
                            Image(.plus10)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60)
                        }
                        .offset(x: 20)
                    }
                    
                    HStack(spacing: 20) {
                        Button {
                            goToMenuAction()
                        } label: {
                            Image(.home)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80)
                        }
                        
                        Button {
                            if isVictory {
                                nextLvlAction()
                            } else {
                                tryAgainAction()
                            }
                        } label: {
                            Image(isVictory ? .next : .tryAgain)
                                .resizable()
                                .scaledToFit()
                                .frame(width: isVictory ? 110 : 80)
                        }
                    }
                    .offset(x: 20)
                }
            }
        }
    }
}

#Preview {
    EndgameView(isVictory: false, goToMenuAction: {}, tryAgainAction: {}, nextLvlAction: {})
}
