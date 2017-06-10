import Foundation
import Alamofire

class RequestBuilder {

    static func build(_ manager: SessionManager, _ retrier: Retrier, requestMethod: Constants.RequestMethod, url: URL, requestBody: Data = Data(), authorizationToken: String = "") -> DataRequest {
        if requestMethod != .GET && requestBody.isEmpty {
            Logger.sharedInstance.log(event: "\nERROR: Missing request body for \(requestMethod.rawValue)\n", type: .debug)
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = requestMethod.rawValue

        switch requestMethod {
        case .POST, .PUT, .PATCH:
            urlRequest.httpBody = requestBody
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.addValue(authorizationToken, forHTTPHeaderField: "Authorization")
        case .GET:
            break
        }

        let request = manager.request(urlRequest)
        manager.retrier = retrier
        retrier.addRetryInfo(request)

        return request
    }
}
