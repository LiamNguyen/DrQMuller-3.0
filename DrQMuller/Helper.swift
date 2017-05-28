import Foundation

class Helper {
    static func jsonObjectToData(_ jsonObject: [String: Any]) throws-> Data {
        let jsonValidObject = JSONSerialization.isValidJSONObject(jsonObject)
        if !jsonValidObject {
            print("Invalid JSON object")
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
}