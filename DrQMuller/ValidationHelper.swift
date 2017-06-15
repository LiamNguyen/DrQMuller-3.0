import Foundation

class ValidationHelper {
    fileprivate static let rules: [String: String] = [
        "username": "^[A-Za-z0-9\\-\\_]{8,25}$",
        "password": "^[A-Za-z0-9\\-\\_]{8,30}$"
    ]

    static func validate(scheme: [String: String]) -> Bool {
		let errors = scheme
			.map { (key, value) -> (key: String, errorCode: String) in
				if value.isEmpty {
					return (key: key, errorCode: ErrorCode.empty.rawValue)
				}
				if value.range(of: rules[key] ?? "", options: .regularExpression) == nil {
					return (key: key, errorCode: ErrorCode.patternFail.rawValue)
				}
				return (key: "", errorCode: "")
			}
			.filter { (key: String, errorCode: String) -> Bool in
				return !key.isEmpty && !errorCode.isEmpty
		}
		ErrorDisplayService.sharedInstance.failReason.value = errors.isEmpty ? [(key: String, errorCode: String)]() : errors
		return errors.isEmpty
    }

    fileprivate enum ErrorCode: String {
        case patternFail
        case empty
    }
}
