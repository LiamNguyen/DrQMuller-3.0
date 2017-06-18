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

        initialState = JSON([
            StateKeys.customer: ""
        ])

        initializeAppState()
        bindRx()
    }

    fileprivate func bindRx() {
        appState.asObservable()
            .subscribe(onNext: { [weak self] _ in
                if !self!.autoStoreDisabled && !self!.firstTimeInitializeState {
                    do {
                        try Cache.sharedInstance.save(fields: [StateKeys.customer])
                    } catch let error as ExtendError {
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

    func dispatch(action: (key: String, state: Any)) throws {
        do {
            appState.value = try appState.value.merged(with: JSON([action.key: action.state]))
        } catch let error {
            Logger.sharedInstance.log(event: "SwiftyJson merge error:\n\(error.localizedDescription)", type: .error)
            throw ExtendError.DispatchActionToStoreFailed
        }
    }

    fileprivate func initializeAppState() {
        do {
            appState = Variable(try initialState.merged(with: Cache.sharedInstance.getAppCache()))
        } catch let error {
            Logger.sharedInstance.log(event: "SwiftyJson merge error:\n\(error.localizedDescription)", type: .error)
            ErrorDisplayService.sharedInstance.failReason.value.append((
                key: "",
                errorCode: "application_error"
            ))
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
}
