import Foundation
import SwiftyJSON
import RxSwift

class AppStore {
    static let sharedInstance = AppStore()

    fileprivate var initialState: JSON
    fileprivate var appState: Variable<JSON>!
	fileprivate var firstTimeInitializeState: Bool = true
    fileprivate var autoStoreDisabled: Bool = false

    fileprivate let disposeBag = DisposeBag()

    fileprivate init() {
//        Mark: Define initial app state

        initialState = JSON(
            [
                StateKey.customer.rawValue: ""
            ]
        )

		if let storedAppState = UserDefaultsService.get(forKey: .appState) as? String {
			appState = Variable(Helper.stringToJSON(string: storedAppState))
		} else {
            appState = Variable(initialState)
        }

        bindRx()
    }

    fileprivate func bindRx() {
        appState.asObservable()
            .subscribe(onNext: { [weak self] appState in
                if !self!.autoStoreDisabled && !self!.firstTimeInitializeState {
					do {
                        try UserDefaultsService.save(forKey: .appState, data: appState.rawString() as Any)
                    } catch let error as ExtendError {
                        ErrorDisplayService.sharedInstance.failReason.value.append((
                                key: "",
                                errorCode: error.commonErrorCode
                        ))
                        Logger.sharedInstance.log(event: error.descriptionForLog, type: .error)
                    } catch let error {
                        Logger.sharedInstance.log(event: error.localizedDescription, type: .error)
                    }
                }
				if self!.firstTimeInitializeState {
					self?.firstTimeInitializeState = false
				}
            }).addDisposableTo(disposeBag)
    }

    func getState() -> JSON {
		return appState.value
    }

    func dispatch(action: (key: StateKey, state: Any)) throws {
        do {
            appState.value = try appState.value.merged(with: JSON([action.key.rawValue: action.state]))
        } catch let error {
            Logger.sharedInstance.log(event: "SwiftyJson merge error:\n\(error.localizedDescription)", type: .error)
            throw ExtendError.DispatchActionToStoreFailed
        }
    }

//    Mark: Testing purpose

    func disableAutoStoreUserDefaults() {
        autoStoreDisabled = true
    }

    func enableAutoStoreUserDefaults() {
        autoStoreDisabled = false
    }

	func resetAppState() {
        appState.value = initialState
    }

    enum StateKey: String {
        case customer
        case testing
        case myList
    }
}
