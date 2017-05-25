import Foundation
import RxSwift

class LoginViewModel {
	
	var isLoading: Variable<Bool> = Variable(false)
	var viewShouldAdjustWhenKeyBoardAppears: Variable<Bool> = Variable(false)
	
	var constraint_TopUsername_BottomLogoObservable: Observable<Float>!
	
	var originalValue_Constraint_TopUsername_BottomLogoObservable: Float = 0
	
	init() {
		bindRx()
	}
	
	fileprivate func bindRx() {
		constraint_TopUsername_BottomLogoObservable = viewShouldAdjustWhenKeyBoardAppears.asObservable()
			.map({ [weak self] viewShouldAdjustWhenKeyBoardAppears in
				return viewShouldAdjustWhenKeyBoardAppears ?
					self!.reduceTwoThirdOfInitialContraint(constraint: self!.originalValue_Constraint_TopUsername_BottomLogoObservable) :
					self!.originalValue_Constraint_TopUsername_BottomLogoObservable
			})
	}
	
	fileprivate func reduceTwoThirdOfInitialContraint(constraint: Float) -> Float {
		return constraint - constraint / 3 * 2
	}
}
