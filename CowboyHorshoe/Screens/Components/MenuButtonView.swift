//
//  MenuButtonView.swift

import SwiftUI

struct MenuButtonView: View {
    
    let name: ImageResource
    
    var body: some View {
        Image(.underlay2)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: 150)
            .overlay {
                Image(name)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 90)
                    .offset(y: -3)
                    .padding()
            }
            .playSound()
    }
}

#Preview {
    MenuButtonView(name: .rules)
}
