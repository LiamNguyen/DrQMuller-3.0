import Foundation

class UserDefaultsService {
    static func save(forKey: Keys, data: Any) -> Bool {
        UserDefaults.standard.set(data, forKey: forKey.rawValue)
        return UserDefaultsService.get(forKey: forKey) != nil
    }

    static func get(forKey: Keys) -> Any? {
        return UserDefaults.standard.value(forKey: forKey.rawValue)
    }

    static func remove(forKey: Keys) -> Bool {
        UserDefaults.standard.removeObject(forKey: forKey.rawValue)
        return UserDefaultsService.get(forKey: forKey) == nil
    }

    enum Keys: String {
        case appState
    }
}
