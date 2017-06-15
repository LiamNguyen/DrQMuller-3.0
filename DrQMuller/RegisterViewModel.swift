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

	func userRegister(completionHandler: @escaping (_ result: AuthenticationStore.AuthenticationResult) -> Void) {
		let successValidation = ValidationHelper.validate(scheme: self.credential)
		guard requestBody() != nil, successValidation else {
			if requestBody() == nil {
				ErrorDisplayService.sharedInstance.failReason.value.append((
					key: "",
					errorCode: "application_error"
				))
			}
			return
		}
		self.isLoading.value = true
		AuthenticationStore.sharedInstance.userRegister(requestBody()!) { [weak self] (result, customer) in
			self?.isLoading.value = false
			if let customer = customer {
				completionHandler(self!.saveCustomer(customer: customer) ? result : .save_client_local_error)
			} else {
				completionHandler(result == .register_success ? .server_error : result)
			}
		}
	}

	fileprivate func saveCustomer(customer: Customer) -> Bool {
		do {
			try CustomerAction.saveCustomer(info: customer.toJSON())
			return true
		} catch let error as ExtendError {
			Logger.sharedInstance.log(event: error.descriptionForLog, type: .error)
			return false
		} catch let error {
			Logger.sharedInstance.log(event: "Unhandled error: \(error.localizedDescription)", type: .error)
			return false
		}
	}

	fileprivate func requestBody() -> Data? {
		do {
			return try Helper.jsonObjectToData(self.credential)
		} catch let error as ExtendError {
			Logger.sharedInstance.log(event: error.descriptionForLog, type: .error)
		} catch let error {
			Logger.sharedInstance.log(event: "Unhandled error: \(error.localizedDescription)", type: .error)
		}
		return nil
	}
}
