import Foundation
import RxSwift
import SwiftyJSON

class LoginViewModel {

//	Mark: Variables

	var isLoading: Variable<Bool> = Variable(false)
	var viewShouldAdjustWhenKeyBoardAppears: Variable<Bool> = Variable(false)
    var username: Variable<String> = Variable("")
    var password: Variable<String> = Variable("")

//	Mark: Observables

	var constraintUsernameLogoObservable: Observable<Float>!
	var constraintLogoViewObservable: Observable<Float>!
    var loginButtonShouldEnable: Observable<Bool>!
    var loginButtonAlphaObservable: Observable<Float>!

//	Mark: Normal properties

	var initialConstraintUsernameLogo: Float = 0
	var initialContraintLogoView: Float = 0
    var credential: [String: String] = [String: String]()

	let disposeBag = DisposeBag()

	init() {
		bindRx()
	}

	fileprivate func bindRx() {
		constraintUsernameLogoObservable = viewShouldAdjustWhenKeyBoardAppears.asObservable()
			.map({ [weak self] viewShouldAdjustWhenKeyBoardAppears in
				return viewShouldAdjustWhenKeyBoardAppears ?
						self!.reduceTwoThirdOfInitialConstraint(constraint: self!.initialConstraintUsernameLogo) :
						self!.initialConstraintUsernameLogo
			})

		constraintLogoViewObservable = viewShouldAdjustWhenKeyBoardAppears.asObservable()
			.map({ [weak self] viewShouldAdjustWhenKeyBoardAppears in
				return viewShouldAdjustWhenKeyBoardAppears ?
						self!.reduceHalfOfInitialConstraint(constraint: self!.initialContraintLogoView) :
						self!.initialContraintLogoView
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
					completionHandler(self!.saveCustomer(customer: customer) ? result : .save_client_local_error)
				} else {
					completionHandler(result == .login_success ? .server_error : result)
				}
            }
        }
    }

    fileprivate func saveCustomer(customer: Customer) -> Bool {
        do {
            try CustomerAction.saveCustomer(info: customer.toJSON())
            return true
        } catch let error {
            print("Failed To save customer\n\(error.localizedDescription)")
            return false
        }
    }

	fileprivate func reduceTwoThirdOfInitialConstraint(constraint: Float) -> Float {
		return constraint - constraint / 3 * 2
	}

	fileprivate func reduceHalfOfInitialConstraint(constraint: Float) -> Float {
		return constraint / 2
	}

    fileprivate func requestBody() -> Data? {
        do {
            return try Helper.jsonObjectToData(self.credential)
        } catch ExtendError.InvalidJSONObject {
            print("Invalid JSON Object")
        } catch ExtendError.JSONSerializationFailed {
            print("Failed to serialize JSON")
        } catch {
            print("Unknown Error")
        }
        return nil
    }
}
