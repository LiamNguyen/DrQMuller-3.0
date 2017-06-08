import Foundation
import SwiftyJSON

class CustomerAction {
    static func saveCustomer(info: [String: Any]) throws {
        var infoWithoutToken: [String: Any] = [String: Any]()
        for (key, value) in info where key != "authorizationToken" {
            infoWithoutToken[key] = value
        }
        do {
            try AppStore.sharedInstance.dispatch(
                    action: (key: StateKey.customer.rawValue, state: infoWithoutToken)
            )
        } catch let error as ExtendError {
            print(error.descriptionForLog)
            throw ExtendError.SaveCustomerFailed
        }
        do {
            guard let token = info["authorizationToken"] else {
                throw ExtendError.SaveCustomerFailed
            }
            try KeychainAccessService.store(value: token, forKey: .authorizationToken)
        } catch let error as ExtendError {
            print(error.descriptionForLog)
            throw ExtendError.SaveCustomerFailed
        }
    }

    enum StateKey: String {
        case customer
    }
}
