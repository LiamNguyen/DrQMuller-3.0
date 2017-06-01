import Foundation
import SwiftyJSON

class AppStore {
    static let sharedInstance = AppStore()

    fileprivate var appState: JSON!

    fileprivate init() {}

    func getState() -> JSON {
        return appState
    }

    func dispatch(action: (key: String, state: Any)) {
        if appState != nil {
            appState = try? appState.merged(with: JSON([action.key: action.state]))
        } else {
            appState = JSON([action.key: action.state])
        }
    }
}
