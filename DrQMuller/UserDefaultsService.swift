import Foundation

class UserDefaultsService {
    static func save(forKey: Keys, data: Any) {
        UserDefaults.standard.set(data, forKey: forKey.rawValue)
    }

    static func get(forKey: Keys) -> Any? {
        return UserDefaults.standard.value(forKey: forKey.rawValue)
    }

    static func remove(forKey: Keys) {
        UserDefaults.standard.removeObject(forKey: forKey.rawValue)
    }

    enum Keys: String {
        case appState
    }
}
