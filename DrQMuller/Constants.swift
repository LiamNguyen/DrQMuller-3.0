import Foundation
import Localize
import UIKit

struct Constants {

	static let deviceUUID: String = UIDevice.current.identifierForVendor?.uuidString ?? ""
	static let deviceName: String = UIDevice.current.name
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

		struct TextfieldPlaceHolder {
			static let username			= "Login.TextfieldPlaceHolder.username".localize()
			static let password			= "Login.TextfieldPlaceHolder.password".localize()
		}

		struct Button {
			static let resetPassword	= "Login.Button.resetPassword".localize()
			static let login			= "Login.Button.login".localize()
			static let register			= "Login.Button.register".localize()
		}
	}

	struct HttpStatusCode {
		//    2XX Sucess

		static let success                  = 200
		static let created                  = 201
		static let accepted                 = 202
		static let noContent                = 204

		//    4XX Client Error

		static let badRequest               = 400
		static let unauthorized             = 401
		static let forbidden                = 403
		static let notFound                 = 404
		static let methodNotAllowed         = 405
		static let notAcceptable            = 406
		static let conflict                 = 409

		//    5XX Server Error

		static let internalServerError      = 500
		static let notImplemented           = 501
		static let badGateway               = 502
		static let gatewayTimeout           = 504
	}

	public enum DeviceType {
		case iPhone4
		case iPhone5
		case iPhone6
		case iPhone6Plus
		case iPadMini
		case iPadPro
	}
}
