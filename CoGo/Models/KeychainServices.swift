//
//  KeychainServices.swift
//  CoGo
//
//  Created by Sean Noh on 1/30/22.
//

import Foundation

enum KeychainWrapperError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
    
    case badData
    case servicesError
    case itemNotFound
    case unableToConvertToString
}

class KeychainWrapper {
  func storeGenericPasswordFor(
    account: String,
    service: String,
    password: String
    
  ) throws {
    guard let passwordData = password.data(using: .utf8) else {
      print("Error converting value to data.")
      throw KeychainWrapperError.badData
    }
      let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: account,
        kSecAttrService as String: service,
        kSecValueData as String: passwordData
      ]
      let status = SecItemAdd(query as CFDictionary, nil)
      switch status {
      case errSecSuccess:
        break
      case errSecDuplicateItem:
        try updateGenericPasswordFor(
          account: account,
          service: service,
          password: password)
      default:
          throw KeychainWrapperError.servicesError
      }

  }
    func getGenericPasswordFor(account: String, service: String) throws -> String {
      let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: account,
        kSecAttrService as String: service,
        kSecMatchLimit as String: kSecMatchLimitOne,
        kSecReturnAttributes as String: true,
        kSecReturnData as String: true
      ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else {
          throw KeychainWrapperError.itemNotFound
        }
        guard status == errSecSuccess else {
          throw KeychainWrapperError.servicesError
        }
        guard
          let existingItem = item as? [String: Any],
          let valueData = existingItem[kSecValueData as String] as? Data,
          let value = String(data: valueData, encoding: .utf8)
          else {
            throw KeychainWrapperError.unableToConvertToString
        }
        return value

    }
    func updateGenericPasswordFor(account: String, service: String, password: String) throws {
      guard let passwordData = password.data(using: .utf8) else {
        print("Error converting value to data.")
        return
      }
      // 1
      let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: account,
        kSecAttrService as String: service
      ]

      // 2
      let attributes: [String: Any] = [
        kSecValueData as String: passwordData
      ]

      // 3
      let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
      guard status != errSecItemNotFound else {
        throw KeychainWrapperError.itemNotFound
      }
      guard status == errSecSuccess else {
          throw KeychainWrapperError.servicesError
      }
    }
    func deleteGenericPasswordFor(account: String, service: String) throws {
      // 1
      let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: account,
        kSecAttrService as String: service
      ]

      // 2
      let status = SecItemDelete(query as CFDictionary)
      guard status == errSecSuccess || status == errSecItemNotFound else {
          throw KeychainWrapperError.servicesError
      }
    }

}
