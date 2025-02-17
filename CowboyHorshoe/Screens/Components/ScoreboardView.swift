//
//  ScoreboardView.swift
//  CowboyHorshoe
//
//  Created by Alex on 17.02.2025.
//

import SwiftUI

struct ScoreboardView: View {
    
    let value: Int
    
    var body: some View {
        ZStack {
            Image(.underlay)
                .resizable()
                .frame(width: 110, height: 45)
                .overlay(alignment: .leading) {
                    Image(.horseshoe)
                        .resizable()
                        .frame(width: 40, height: 45)
                        .offset(x: -20)
                }
            
            Text("\(value)")
                .foregroundStyle(.black)
                .font(.system(size: 18, weight: .heavy, design: .serif))
        }
        .frame(width: 150, height: 45)
    }
}

#Preview {
    ScoreboardView(value: 120)
}
