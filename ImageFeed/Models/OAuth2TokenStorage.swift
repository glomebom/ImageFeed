//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Gleb on 09.04.2024.
//

import Foundation
import UIKit
import SwiftKeychainWrapper

protocol OAuth2TokenStorageProtocol {
    var token: String? { get set }
}

final class OAuth2TokenStorage: OAuth2TokenStorageProtocol {
    
    private enum Keys: String {
        case token
    }
    
    //private let userDefaults = UserDefaults.standard
    
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: Keys.token.rawValue)
        }
        set {
            guard let newValue else { return }
            KeychainWrapper.standard.set(newValue, forKey: Keys.token.rawValue)
        }
    }
    
    func resetToken() {
        KeychainWrapper.standard.removeObject(forKey: Keys.token.rawValue)
    }
}
