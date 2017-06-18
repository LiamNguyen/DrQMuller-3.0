import Foundation
import KeychainAccess

class KeychainAccessService {
    fileprivate static let keychain: Keychain = Keychain(service: Bundle.main.bundleIdentifier ?? "vn.default.id")

    static func store(value: Any, forKey: KeychainAccessKey) throws {
        do {
            if let value = value as? String {
                try keychain.set(value, key: forKey.rawValue)
            }
            if let value = value as? Data {
                try keychain.set(value, key: forKey.rawValue)
            }
        } catch let error {
            Logger.sharedInstance.log(event: "Failed to store keychain\n\(error.localizedDescription)", type: .error)
            throw ExtendError.StoreKeyChainFailed
        }
    }

    static func getString(forKey: KeychainAccessKey) throws -> String {
        do {
            if let keychain = try keychain.getString(forKey.rawValue) {
                return keychain
            } else {
                Logger.sharedInstance.log(event: "Failed to get keychain", type: .error)
                throw ExtendError.GetKeyChainFailed
            }
        } catch let error {
            Logger.sharedInstance.log(event: "Failed to get keychain\n\(error.localizedDescription)", type: .error)
            throw ExtendError.GetKeyChainFailed
        }
    }

    static func remove(forKey: KeychainAccessKey) throws {
        do {
            try keychain.remove(forKey.rawValue)
        } catch let error {
            Logger.sharedInstance.log(event: "Failed to remove keychain\n\(error.localizedDescription)", type: .error)
            throw ExtendError.RemoveKeyChainFailed
        }
    }

    enum KeychainAccessKey: String {
        case authorizationToken
        case username
        case password
        case testStore
        case testRemove
    }
}
