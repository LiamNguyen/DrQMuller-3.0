import Foundation

enum ExtendError: Error {
    case InvalidJSONObject
    case JSONSerializationFailed
    case DispatchActionToStoreFailed
    case StoreKeyChainFailed
    case SaveCustomerFailed
    case UserDefaultsStoreFailed
    case UserDefaultRemoveFailed
}
