//
//  RootViewModel.swift

import Foundation

@MainActor final class RootViewModel: ObservableObject {
    // MARK: - States enum
    
    enum States {
        case loading
        case initial
        case menu
    }
    
    @Published private(set) var state: States = .loading
    
    let manager: NetworkManager
    
    init(manager: NetworkManager = NetworkManager()) {
        self.manager = manager
    }
    
    func stateCheck() {
        Task {
            if manager.targetUrl != nil {
                state = .initial
                return
            }
            
            do {
                if try await manager.checkInitialURL() {
                    state = .initial
                } else {
                    state = .menu
                }
            }
            catch {
                state = .menu
            }
        }
    }
}
