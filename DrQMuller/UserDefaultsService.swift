import Foundation

class UserDefaultsService {
    static func save(forKey: Keys, data: Any) throws {
        UserDefaults.standard.set(data, forKey: forKey.rawValue)
        if (UserDefaultsService.get(forKey: forKey) == nil) {
            throw ExtendError.UserDefaultsStoreFailed
        }
    }

    static func get(forKey: Keys) -> Any? {
        return UserDefaults.standard.value(forKey: forKey.rawValue)
    }

    static func remove(forKey: Keys) throws {
        UserDefaults.standard.removeObject(forKey: forKey.rawValue)
        if (UserDefaultsService.get(forKey: forKey) != nil) {
            throw ExtendError.UserDefaultRemoveFailed
        }
    }

    enum Keys: String {
        case appState
        case testSave
        case testGet
        case testRemove
    }
}
