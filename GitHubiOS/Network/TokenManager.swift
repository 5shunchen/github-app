//
//  TokenManager.swift
//  GitHubiOS
//
//  Created by iOS Architect on 5/17/26.
//

import Foundation

protocol TokenManagerProtocol {
    func getToken() -> String?
    func saveToken(_ token: String) throws
    func deleteToken() throws
}

final class TokenManager: TokenManagerProtocol {
    static let shared = TokenManager()
    
    private let keychainWrapper: KeychainWrapperProtocol
    
    init(keychainWrapper: KeychainWrapperProtocol = KeychainWrapper.shared) {
        self.keychainWrapper = keychainWrapper
    }
    
    func getToken() -> String? {
        return try? keychainWrapper.getString(for: "github_token")
    }
    
    func saveToken(_ token: String) throws {
        try keychainWrapper.set(token, for: "github_token")
    }
    
    func deleteToken() throws {
        try keychainWrapper.removeValue(for: "github_token")
    }
}

// MARK: - Keychain Wrapper Protocol
protocol KeychainWrapperProtocol {
    func getString(for key: String) throws -> String?
    func set(_ value: String, for key: String) throws
    func removeValue(for key: String) throws
}

// MARK: - Default Keychain Implementation
final class KeychainWrapper: KeychainWrapperProtocol {
    static let shared = KeychainWrapper()
    
    private init() {}
    
    func getString(for key: String) throws -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: kCFBooleanTrue!,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        
        var data: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &data)
        
        guard status == errSecSuccess, let tokenData = data as? Data else {
            return nil
        }
        
        return String(data: tokenData, encoding: .utf8)
    }
    
    func set(_ value: String, for key: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw NSError(domain: "Keychain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert token to data"])
        }
        
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData: data
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw NSError(domain: "Keychain", code: Int(status), userInfo: [NSLocalizedDescriptionKey: "Failed to save token to keychain"])
        }
    }
    
    func removeValue(for key: String) throws {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw NSError(domain: "Keychain", code: Int(status), userInfo: [NSLocalizedDescriptionKey: "Failed to delete token from keychain"])
        }
    }
}
