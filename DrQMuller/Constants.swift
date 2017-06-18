import Foundation
import Localize
import UIKit

struct Constants {
    struct Config {
        #if DEVELOPMENT
            static let API_BASE_URL = "http://210.211.109.180/beta_drmuller/api/index.php/"
        #else
            static let API_BASE_URL = "http://210.211.109.180/drmuller/api/index.php/"
        #endif
    }

	static let deviceUUID: String = UIDevice.current.identifierForVendor?.uuidString ?? ""
	static let deviceName: String = UIDevice.current.name
	static let appId: String = "6JvYGw"
	static let appCode: String = "tCl7oakmzObiyOsfFqnmsjxsrByinRkg"
	static let logKey: String = "svf0wex1ufj3uLhb6fh7QfrhliNcunjO"
	static var longTextLineNumbers: Int = {
		return Constants.DeviceModel.deviceType() == .iPhone5 || Constants.DeviceModel.deviceType() == .iPhone4 ? 3 : 2
	}()

	struct Window {
		static let screenWidth: Float = Float(UIScreen.main.bounds.width)
		static let screenHeight: Float = Float(UIScreen.main.bounds.height)
	}

	struct DeviceModel {
		static func deviceType() -> DeviceType {
			switch Constants.Window.screenHeight {
			case 480:
				return .iPhone4
			case 568:
				return .iPhone5
			case 667:
				return .iPhone6
			case 736:
				return .iPhone6Plus
			case 1024:
				return .iPadMini
			case 1366:
				return .iPadPro
			default:
				print("Undefined device type")
				return .iPhone6
			}
		}
	}

	struct Login {
		struct View {
			static let loginBackground	= "background.png"
		}

		struct TextFieldPlaceHolder {
			static let username			= "Login.TextFieldPlaceHolder.username".localize()
			static let password			= "Login.TextFieldPlaceHolder.password".localize()
		}

		struct Button {
			static let resetPassword	= "Login.Button.resetPassword".localize()
			static let login			= "Login.Button.login".localize()
			static let register			= "Login.Button.register".localize()
		}

		struct ActivityIndicator {
			static let loggingIn        = "Login.ActivityIndicator.loggingIn".localize()
		}
	}

	struct Register {
		struct View {
			static let registerBackground = "background.png"
		}

		struct TextFieldPlaceHolder {
			static let username	        = "Register.TextFieldPlaceHolder.username".localize()
			static let password	        = "Register.TextFieldPlaceHolder.password".localize()
			static let confirmPassword  = "Register.TextFieldPlaceHolder.confirmPassword".localize()
		}

		struct Button {
			static let register			= "Register.Button.register".localize()
		}

		struct Label {
			static let confirmPasswordMismatch = "Register.Label.confirmPasswordMismatch".localize()
		}
	}

	public enum HttpStatusCode: Int {
		//    2XX Success

		case success                  = 200
		case created                  = 201
        case accepted                 = 202
        case noContent                = 204

		//    4XX Client Error

        case badRequest               = 400
        case unauthorized             = 401
        case forbidden                = 403
        case notFound                 = 404
        case methodNotAllowed         = 405
        case notAcceptable            = 406
        case conflict                 = 409

		//    5XX Server Error

        case internalServerError      = 500
        case notImplemented           = 501
        case badGateway               = 502
        case gatewayTimeout           = 504
	}

	public enum DeviceType {
		case iPhone4
		case iPhone5
		case iPhone6
		case iPhone6Plus
		case iPadMini
		case iPadPro
	}

	public enum RequestMethod: String {
		case GET
		case POST
		case PUT
		case PATCH
	}

	public enum Gender: String {
		case Male
		case Female
	}

	public enum UISavedStep: String {
		case none
		case basic
		case necessary
		case important
	}
}
