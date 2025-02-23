//
//  RootView.swift

import SwiftUI

struct RootView: View {
    
    @StateObject private var root = RootViewModel()
    
    var body: some View {
        Group {
            switch root.state {
            case .loading:
                LoadingView()
            case .initial:
                if let url = root.manager.targetUrl {
                    WebViewManager(url: url, manager: root.manager)
                } else {
                    WebViewManager(url: NetworkManager.initialUrl, manager: root.manager)
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

