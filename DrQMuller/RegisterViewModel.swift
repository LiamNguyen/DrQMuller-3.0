import Foundation
import RxSwift
import UIKit

class RegisterViewModel {

//	Mark: Variables

	var isLoading: Variable<Bool> = Variable(false)
	var viewShouldAdjustWhenKeyBoardAppears: Variable<Bool> = Variable(false)
	var username: Variable<String> = Variable("")
	var password: Variable<String> = Variable("")
	var confirmPassword: Variable<String> = Variable("")

//	Mark: Observables

	var constraintUsernameLogoObservable: Observable<Float>!
	var constraintLogoViewObservable: Observable<Float>!
	var registerButtonShouldEnable: Observable<Bool>!
	var registerButtonAlphaObservable: Observable<Float>!
	var confirmPasswordMatchObservable: Observable<Bool>!
	var confirmPasswordTextFieldBorderColorObservable: Observable<CGColor>!
	var confirmPasswordTextFieldBorderWidthObservable: Observable<Float>!

//	Mark: Normal properties

	var initialConstraintUsernameLogo: Float = 0
	var initialConstraintLogoView: Float = 0
	var credential: [String: String] = [String: String]()

	fileprivate let disposeBag: DisposeBag = DisposeBag()

	init() {
		bindRx()
	}

	fileprivate func bindRx() {
		constraintUsernameLogoObservable = viewShouldAdjustWhenKeyBoardAppears.asObservable()
			.map({ [weak self] viewShouldAdjustWhenKeyBoardAppears in
				return viewShouldAdjustWhenKeyBoardAppears ?
					Helper.reduceTwoThirdOfInitialConstraint(constraint: self!.initialConstraintUsernameLogo) :
					self!.initialConstraintUsernameLogo
			})

		constraintLogoViewObservable = viewShouldAdjustWhenKeyBoardAppears.asObservable()
			.map({ [weak self] viewShouldAdjustWhenKeyBoardAppears in
				return viewShouldAdjustWhenKeyBoardAppears ?
					Helper.reduceHalfOfInitialConstraint(constraint: self!.initialConstraintLogoView) :
					self!.initialConstraintLogoView
			})

		Observable.combineLatest(
			username.asObservable(),
			password.asObservable()
			).subscribe(onNext: { [weak self] (username, password) in
				self?.credential = [
					"username": username.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
					"password": password.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
				]
			}).addDisposableTo(disposeBag)

		confirmPasswordMatchObservable = Observable.combineLatest(
			password.asObservable(),
			confirmPassword.asObservable()
		).map { (password, confirmPassword) -> Bool in
			let trimmedPassword = password.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
			let trimmedConfirmPassword = confirmPassword.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

			return confirmPassword.isEmpty ? true : trimmedPassword == trimmedConfirmPassword
		}

		confirmPasswordTextFieldBorderWidthObservable = confirmPasswordMatchObservable
			.map { confirmPasswordMatch -> Float in
			return confirmPasswordMatch ? 0 : 1.5
		}

		confirmPasswordTextFieldBorderColorObservable = confirmPasswordMatchObservable
			.map { confirmPasswordMatch -> CGColor in
			return confirmPasswordMatch ? UIColor.black.cgColor : UIColor.red.cgColor
		}

		registerButtonShouldEnable = Observable.combineLatest(
			username.asObservable(),
			password.asObservable(),
			confirmPassword.asObservable(),
			confirmPasswordMatchObservable
		).map { (username, password, confirmPassword, confirmPasswordMatch) in
			return !username.isEmpty && !password.isEmpty && !confirmPassword.isEmpty && confirmPasswordMatch
		}

		registerButtonAlphaObservable = registerButtonShouldEnable
			.map { loginButtonShouldEnable in
				return loginButtonShouldEnable ? 1 : 0.5
		}
	}
}
