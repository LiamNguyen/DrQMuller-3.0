import Foundation
import SwiftyJSON
import RxSwift

class AppStore {
    static let sharedInstance = AppStore()

    fileprivate var initialState: JSON
    fileprivate var appState: Variable<JSON>!

    fileprivate let disposeBag = DisposeBag()

    fileprivate init() {
//        Mark: Define initial app state

        initialState = JSON(
            [
                "customer": ""
            ]
        )

		if let storedAppState = UserDefaultsService.get(forKey: .appState) as? String {
			appState = Variable(JSON(storedAppState.data(using: .utf8) ?? Data()))
		} else {
            appState = Variable(initialState)
        }

        bindRx()
    }

    fileprivate func bindRx() {
        appState.asObservable()
            .subscribe(onNext: { appState in
                UserDefaultsService.save(forKey: .appState, data: appState.rawString() as Any)
            }).addDisposableTo(disposeBag)
    }

    func getState() -> JSON {
		return appState.value
    }

    func dispatch(action: (key: String, state: Any)) throws {
        do {
            appState.value = try appState.value.merged(with: JSON([action.key: action.state]))
        } catch let error {
            print("SwiftyJson merge error:\n\(error.localizedDescription)")
            throw ExtendError.DispatchActionToStoreFailed
        }
    }
}
