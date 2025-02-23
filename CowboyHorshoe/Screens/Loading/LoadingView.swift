//
//  LoadingView.swift

import SwiftUI

struct LoadingView: View {
    
    @State private var progressBar: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            BackgroundView(imageName: .bg3)
            
            Image(.loadingBar)
                .resizable()
                .frame(width: 300,  height: 40)
                .padding(.bottom)
                .overlay(alignment: .leading) {
                    Rectangle()
                        .foregroundStyle(.yellow)
                        .frame(width: progressBar * 229, height: 23)
                        .padding(.horizontal, 36)
                        .padding(.bottom, 10)
                }
        }
        .onAppear {
            withAnimation(.linear(duration: 1)) {
                progressBar = 1
            }
        }
    }
}

#Preview {
    LoadingView()
}
