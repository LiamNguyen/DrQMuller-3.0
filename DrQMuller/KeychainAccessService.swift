import Foundation
import KeychainAccess

class KeychainAccessService {
    fileprivate static let keychain: Keychain = Keychain(service: Bundle.main.bundleIdentifier ?? "vn.default.id")

    init() {
    }

    static func store(value: Any, forKey: KeychainAccessKey) throws {
        do {
            if let value = value as? String {
                try keychain.set(value, key: forKey.rawValue)
            }
            if let value = value as? Data {
                try keychain.set(value, key: forKey.rawValue)
            }
        } catch let error {
            print("Failed to store keychain\n\(error.localizedDescription)")
            throw ExtendError.StoreKeyChainFailed
        }
    }

    static func getString(forKey: KeychainAccessKey) -> String {
        do {
            return try keychain.getString(forKey.rawValue) ?? ""
        } catch let error {
            print("Failed to get keychain\n\(error.localizedDescription)")
            return ""
        }
    }

    static func remove(forKey: KeychainAccessKey) {
        do {
            try keychain.remove(forKey.rawValue)
        } catch let error {
            print("Failed to remove keychain\n\(error.localizedDescription)")
        }
    }

    enum KeychainAccessKey: String {
        case authorizationToken
    }
}
