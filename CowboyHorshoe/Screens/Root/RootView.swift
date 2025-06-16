//
//  RootView.swift

import SwiftUI

struct RootView: View {
    
    @StateObject private var root = RootViewModel()
        
    var body: some View {
        Group {
            switch root.appState {
            case .fetch:
                LoadingView()
                
            case .initial:
                if let url = root.webManager.targetURL {
                    WebViewManager(url: url, webManager: root.webManager)
                } else {
                    WebViewManager(url: NetworkManager.initialURL, webManager: root.webManager)
                }
                
            case .menu:
                ContentView()
            }
        }
        .onAppear {
            root.stateCheck()
        }
    }
}
