//
//  XmarkButtonView.swift

import SwiftUI

struct XmarkButtonView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Button {
            SettingsManager.shared.playClick()
            dismiss()
        } label: {
            Image(.xMark)
                .resizable()
                .scaledToFit()
                .frame(width: 50)
        }
    }
}

#Preview {
    XmarkButtonView()
}
