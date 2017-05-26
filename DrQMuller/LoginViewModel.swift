import Foundation
import RxSwift

class LoginViewModel {

	var isLoading: Variable<Bool> = Variable(false)
	var viewShouldAdjustWhenKeyBoardAppears: Variable<Bool> = Variable(false)

	var constraintUsernameLogoObservable: Observable<Float>!

	var initialConstraintUsernameLogoObservable: Float = 0

	init() {
		bindRx()
	}

	fileprivate func bindRx() {
		constraintUsernameLogoObservable = viewShouldAdjustWhenKeyBoardAppears.asObservable()
			.map({ [weak self] viewShouldAdjustWhenKeyBoardAppears in
				return viewShouldAdjustWhenKeyBoardAppears ?
					self!.reduceTwoThirdOfInitialContraint(constraint: self!.initialConstraintUsernameLogoObservable) :
					self!.initialConstraintUsernameLogoObservable
			})
	}

	fileprivate func reduceTwoThirdOfInitialContraint(constraint: Float) -> Float {
		return constraint - constraint / 3 * 2
	}
}
