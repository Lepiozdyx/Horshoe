//
//  RootViewModel.swift

import Foundation

@MainActor
final class RootViewModel: ObservableObject {
    
    enum AppState {
        case fetch
        case initial
        case menu
    }
    
    @Published private(set) var appState: AppState = .fetch
    let webManager: NetworkManager
    
    private var timeoutTask: Task<Void, Never>?
    private let maxLoadingTime: TimeInterval = 10.0
    
    init(webManager: NetworkManager = NetworkManager()) {
        self.webManager = webManager
    }
    
    func stateCheck() {
        timeoutTask?.cancel()
        
        Task { @MainActor in
            do {
                if webManager.targetURL != nil {
                    updateState(.initial)
                    return
                }
                
                let shouldShowWebView = try await webManager.checkInitialURL()
                
                if shouldShowWebView {
                    updateState(.initial)
                } else {
                    updateState(.menu)
                }
                
            } catch {
                updateState(.menu)
            }
        }
        
        startTimeoutTask()
    }
    
    private func updateState(_ newState: AppState) {
        timeoutTask?.cancel()
        timeoutTask = nil
        
        appState = newState
    }
    
    private func startTimeoutTask() {
        timeoutTask = Task { @MainActor in
            do {
                try await Task.sleep(nanoseconds: UInt64(maxLoadingTime * 1_000_000_000))
                
                if self.appState == .fetch {
                    self.appState = .menu
                }
            } catch {}
        }
    }
    
    deinit {
        timeoutTask?.cancel()
    }
}
