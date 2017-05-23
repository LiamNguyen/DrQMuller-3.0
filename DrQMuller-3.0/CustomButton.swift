import UIKit

@IBDesignable
class CustomButton: UIButton {

	override func draw(_ rect: CGRect) {
		self.layer.cornerRadius = 8
	}
}
