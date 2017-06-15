import Foundation
import Alamofire
import AlamofireObjectMapper

class AuthenticationStore: AuthenticationStoreType {

    static let sharedInstance = AuthenticationStore()

    fileprivate let manager = SessionManager()

    fileprivate let baseURL: URL!
    fileprivate let loginURL: URL!
    fileprivate let registerURL: URL!

    fileprivate init() {
        self.baseURL = URL(string: Constants.Config.API_BASE_URL)
        self.loginURL = URL(string: "user/login", relativeTo: self.baseURL)
        self.registerURL = URL(string: "user/register", relativeTo: self.baseURL)
    }

    func userLogin(_ credential: Data, _ completionHandler: @escaping (AuthenticationResult, Customer?) -> Void) {
        let retrier = Retrier()
        let request = RequestBuilder.build(manager, retrier, requestMethod: .POST, url: self.loginURL, requestBody: credential)

        request.response { _ in
            retrier.deleteRetryInfo(request)
        }
        .validate(statusCode: 200..<201)
        .responseObject { (response: DataResponse<Customer>) in
            let result = self.responseHandler(response.response?.statusCode ?? Constants.HttpStatusCode.internalServerError.rawValue)
            switch response.result {
            case .success:
                if let customer = response.result.value {
                    completionHandler(result, customer)
                }
            case .failure(let error):
                completionHandler(result, nil)
                Logger.sharedInstance.log(event: error.localizedDescription, type: .info)
                if let response = response.response {
                    Logger.sharedInstance.log(event: response, type: .verbose)
                }
            }
        }
    }

	func userRegister(_ credential: Data, _ completionHandler: @escaping (AuthenticationResult, Customer?) -> Void) {
		let retrier = Retrier()
		let request = RequestBuilder.build(manager, retrier, requestMethod: .POST, url: self.registerURL, requestBody: credential)

		request.response { _ in
			retrier.deleteRetryInfo(request)
		}
		.validate(statusCode: 201..<202)
		.responseObject { (response: DataResponse<Customer>) in
			let result = self.responseHandler(response.response?.statusCode ?? Constants.HttpStatusCode.internalServerError.rawValue)
			switch  response.result {
			case .success:
				if let customer = response.result.value {
					completionHandler(result, customer)
				}
			case .failure(let error):
				completionHandler(result, nil)
				Logger.sharedInstance.log(event: error.localizedDescription, type: .info)
				if let response = response.response {
					Logger.sharedInstance.log(event: response, type: .verbose)
				}
			}
		}
	}

    fileprivate func responseHandler(_ statusCode: Int) -> AuthenticationResult {
        switch statusCode {
		case Constants.HttpStatusCode.success.rawValue:
			return .login_success
		case Constants.HttpStatusCode.created.rawValue:
			return .register_success
		case Constants.HttpStatusCode.unauthorized.rawValue:
			return .invalid_username_password
		case Constants.HttpStatusCode.badRequest.rawValue:
			return .username_password_pattern_failed
		case Constants.HttpStatusCode.conflict.rawValue:
			return .username_exist
		default:
			return .server_error
        }
    }

	enum AuthenticationResult: String {
        case login_success
        case register_success
        case username_password_pattern_failed
        case invalid_username_password
        case username_exist
        case server_error
        case save_client_local_error
    }
}
