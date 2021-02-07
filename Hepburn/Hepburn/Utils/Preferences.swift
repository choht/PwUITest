//
//  Preferences.swift
//  Hepburn
//
//  Created by HyeonTae Cho on 2021/01/30.
//

import Foundation

class Preferences: ObservableObject {
    
    /* Server address : String */
    private static let KEY_SERVER_ADDRESS = "key.server.address"
    /* Server port : Int */
    private static let KEY_SERVER_PORT = "key.server.port"
    
    @Published var serverAddress = UserDefaults.standard.string(forKey: KEY_SERVER_ADDRESS) ?? "" {
        didSet {
            UserDefaults.standard.set(self.serverAddress, forKey: Preferences.KEY_SERVER_ADDRESS)
        }
    }
    
    @Published var serverPort = UserDefaults.standard.string(forKey: KEY_SERVER_PORT) ?? "" {
        didSet {
            UserDefaults.standard.set(self.serverPort, forKey: Preferences.KEY_SERVER_PORT)
        }
    }
    
    func getServerUrl() -> String! {
        let url = "http://\(serverAddress)"
        
        if serverPort.isEmpty {
            return url
        }
        
        return "\(url):\(serverPort)"
    }
}
