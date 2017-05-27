import Foundation
import RxSwift

class LoginViewModel {

//	Mark: Variables

	var isLoading: Variable<Bool> = Variable(false)
	var viewShouldAdjustWhenKeyBoardAppears: Variable<Bool> = Variable(false)
    var username: Variable<String> = Variable("")
    var password: Variable<String> = Variable("")

//	Mark: Observables

	var constraintUsernameLogoObservable: Observable<Float>!

//	Mark: Normal properties

	var initialConstraintUsernameLogoObservable: Float = 0
    var credential: [String: String] = [String: String]()

	let disposeBag = DisposeBag()

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

		Observable.combineLatest(
			username.asObservable(),
			password.asObservable()
        ).subscribe(onNext: { [weak self] (username, password) in
			self?.credential = [
				"username": username.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
				"password": password.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
			]
		}).addDisposableTo(disposeBag)
	}

    func userLogin(completionHandler: @escaping (_ result: AuthenticationStore.AuthenticationResult) -> Void) {
        if let requestBody = requestBody() {
            self.isLoading.value = true
            AuthenticationStore.sharedInstance.userLogin(requestBody) { (result, customer) in
                print(customer?.toJSONString(prettyPrint: true) ?? "")
                completionHandler(result)
                self.isLoading.value = false
            }
        }
    }

	fileprivate func reduceTwoThirdOfInitialContraint(constraint: Float) -> Float {
		return constraint - constraint / 3 * 2
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
