import UIKit

@IBDesignable
class CustomTextField: UITextField {
	
	override func layoutSubviews() {
		super.layoutSubviews()
	}
	
	override func textRect(forBounds bounds: CGRect) -> CGRect {
		return bounds.insetBy(dx: 50, dy: 7)
	}
	
	override func editingRect(forBounds bounds: CGRect) -> CGRect {
		return textRect(forBounds: bounds)
	}
}
