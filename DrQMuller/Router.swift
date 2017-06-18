import Foundation
import UIKit

class Router {
	static func push(sender: UIViewController, destination: SegueDestination) {
		sender.performSegue(withIdentifier: destination.rawValue, sender: sender)
	}
}

enum SegueDestination: String {
	case LoginToProfile
	case LoginToBookingManager
	case RegisterToProfile
}
