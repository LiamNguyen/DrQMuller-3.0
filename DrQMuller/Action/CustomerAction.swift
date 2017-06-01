import Foundation
import SwiftyJSON

struct CustomerAction {
    static func saveCustomer(info: [String: Any]) {
        var infoWithoutToken: [String: Any] = [String: Any]()
        for (key, value) in info where key != "authorizationToken" {
            infoWithoutToken[key] = value
        }
        AppStore.sharedInstance.dispatch(
                action: (key: StateKey.user.rawValue, state: infoWithoutToken)
        )
    }

    enum StateKey: String {
        case user
    }
}
