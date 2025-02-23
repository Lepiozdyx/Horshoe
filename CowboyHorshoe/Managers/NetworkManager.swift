//
//  NetworkManager.swift

import SwiftUI

final class NetworkManager: ObservableObject {
    
    @Published private(set) var targetUrl: URL?
    
    private let userDefaults: UserDefaults
    private var didSaveURL = false
    #warning("")
    static let initialUrl = URL(string: "https://")!
    
    init(storage: UserDefaults = .standard) {
        self.userDefaults = storage
        loadURL()
    }
    
    // MARK: - Public methods
    
    func checkURL(_ url: URL) {
        if didSaveURL {
            return
        }
        
        guard !isInvalidURL(url) else {
            return
        }
        
        userDefaults.set(url.absoluteString, forKey: "savedurl")
        targetUrl = url
        didSaveURL = true
    }
    
    func checkInitialURL() async throws -> Bool {
        do {
            var request = URLRequest(url: Self.initialUrl)
            request.setValue(getAgent(forWebView: false), forHTTPHeaderField: "User-Agent")
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return false
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                return false
            }
            
            guard let finalURL = httpResponse.url else {
                return false
            }
            
            if finalURL.host?.contains("google.com") == true {
                return false
            }
            
            return true

        } catch {
            return false
        }
    }
    
    func getAgent(forWebView: Bool = false) -> String {
        if forWebView {
            let version = UIDevice.current.systemVersion.replacingOccurrences(of: ".", with: "_")
            let agent = "Mozilla/5.0 (iPhone; CPU iPhone OS \(version) like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
            return agent
        } else {
            let agent = "TestRequest/1.0 CFNetwork/1410.0.3 Darwin/22.4.0"
            return agent
        }
    }
    
    // MARK: - Private methods
    
    private func loadURL() {
        if let urlString = userDefaults.string(forKey: "savedurl") {
            if let url = URL(string: urlString) {
                targetUrl = url
                didSaveURL = true
            } else {
                print("Failed to load URL from string: \(urlString)")
            }
        } else {
            print("Failed")
        }
    }
    
    private func isInvalidURL(_ url: URL) -> Bool {
        let invalidURLs = ["about:blank", "about:srcdoc"]
        
        if invalidURLs.contains(url.absoluteString) {
            return true
        }
        
        if url.host?.contains("google.com") == true {
            return true
        }
        
        return false
    }
}
