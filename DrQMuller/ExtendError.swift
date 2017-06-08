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

extension ExtendError {
    var commonErrorCode: String {
        switch self {
            default: return "application_error"
        }
    }
    var descriptionForLog: String {
        switch self {
            default: return "Error type: \(self)\nDescription: \(self.localizedDescription)"
        }
    }
}
