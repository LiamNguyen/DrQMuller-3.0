import Foundation
import RxSwift
import SwiftyJSON

class LoginViewModel {

//	Mark: Variables

	var isLoading: Variable<Bool> = Variable(false)
	var viewShouldAdjustWhenKeyBoardAppears: Variable<Bool> = Variable(false)
	var username: Variable<String> = Variable("")
	var password: Variable<String> = Variable("")
	var isLoadingForAutoLogin: Variable<Bool> = Variable(false)
	var autoLoginSuccess: Variable<Bool> = Variable(false)

//	Mark: Observables

	var constraintUsernameLogoObservable: Observable<Float>!
	var constraintLogoViewObservable: Observable<Float>!
	var loginButtonShouldEnable: Observable<Bool>!
	var loginButtonAlphaObservable: Observable<Float>!

//	Mark: Normal properties

	var initialConstraintUsernameLogo: Float = 0
	var initialConstraintLogoView: Float = 0
	fileprivate var credential: [String: String] = [String: String]()

	fileprivate let disposeBag: DisposeBag = DisposeBag()

	init() {
		bindRx()
		rememberMe()
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

		loginButtonShouldEnable = Observable.combineLatest(
			username.asObservable(),
			password.asObservable()
		).map { (username, password) in
			return !username.isEmpty && !password.isEmpty
		}

		loginButtonAlphaObservable = loginButtonShouldEnable
			.map { loginButtonShouldEnable in
			return loginButtonShouldEnable ? 1 : 0.5
		}
	}

	func userLogin(completionHandler: @escaping (_ result: AuthenticationStore.AuthenticationResult) -> Void) {
		if let requestBody = requestBody() {
			self.isLoading.value = true
			AuthenticationStore.sharedInstance.userLogin(requestBody) { [weak self] (result, customer) in
				self?.isLoading.value = false
				if let customer = customer {
					completionHandler(self!.saveCustomer(customer: customer) && self!.storeUsernameAndPassword() ? result : .save_client_local_error)
				} else {
					completionHandler(result == .login_success ? .server_error : result)
				}
			}
		}
	}

	fileprivate func rememberMe() {
	    do {
		    username.value = try KeychainAccessService.getString(forKey: .username)
		    password.value = try KeychainAccessService.getString(forKey: .password)

		    if !username.value.isEmpty && !password.value.isEmpty {
				self.isLoadingForAutoLogin.value = true
				userLogin { [weak self] result in
					self?.isLoadingForAutoLogin.value = false
					self?.autoLoginSuccess.value = (result == AuthenticationStore.AuthenticationResult.login_success)
				}
		    }
	    } catch let error as ExtendError {
		    Logger.sharedInstance.log(event: error.descriptionForLog, type: .error)
	    } catch let error {
		    Logger.sharedInstance.log(event: "Unhandled error: \(error.localizedDescription)", type: .error)
	    }
	}

	fileprivate func saveCustomer(customer: Customer) -> Bool {
		do {
			try CustomerAction.saveCustomer(info: customer.toJSON())
			return true
		} catch let error as ExtendError {
			Logger.sharedInstance.log(event: error.descriptionForLog, type: .error)
		} catch let error {
			Logger.sharedInstance.log(event: "Unhandled error: \(error.localizedDescription)", type: .error)
		}
		return false
	}

	fileprivate func storeUsernameAndPassword() -> Bool {
		do {
			if !username.value.isEmpty && !password.value.isEmpty {
				try	KeychainAccessService.store(value: username.value, forKey: .username)
				try KeychainAccessService.store(value: password.value, forKey: .password)
			}
			return true
		} catch let error as ExtendError {
			Logger.sharedInstance.log(event: error.descriptionForLog, type: .error)
		} catch let error {
			Logger.sharedInstance.log(event: "Unhandled error: \(error.localizedDescription)", type: .error)
		}
		return false
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
