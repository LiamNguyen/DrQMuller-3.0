import Foundation
import SwiftyJSON

class Helper {
    static func jsonObjectToData(_ jsonObject: [String: Any]) throws-> Data {
        if !JSONSerialization.isValidJSONObject(jsonObject) {
            throw ExtendError.InvalidJSONObject
        }
        do {
            return try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
        } catch {
            throw ExtendError.JSONSerializationFailed
        }
    }

    static func dataStringify(_ data: Data) -> String {
        if let nsString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
            return nsString as String
        }
        return "Failed to convert NSString to String"
    }

	static func stringToJSON(string: String) -> JSON {
		return JSON(string.data(using: .utf8) ?? Data())
	}

    static func reduceTwoThirdOfInitialConstraint(constraint: Float) -> Float {
        return constraint - constraint / 3 * 2
    }

    static func reduceHalfOfInitialConstraint(constraint: Float) -> Float {
        return constraint / 2
    }
}
