import Foundation
import RxSwift
import UIKit
import AudioToolbox

class ErrorDisplayService {
    static let sharedInstance = ErrorDisplayService()

    var failReason: Variable<[(key: String, errorCode: String)]> = Variable([])

    fileprivate let disposeBag = DisposeBag()

    private init() {
        bindRx()
    }

    fileprivate func bindRx() {
        failReason.asObservable()
            .subscribe(onNext: { [weak self] failReason in
                if !failReason.isEmpty {
                    self?.showMessage(key: failReason[0].key, errorCode: failReason[0].errorCode)
                    self?.failReason.value.removeAll()
                }
            }).addDisposableTo(disposeBag)
    }

    fileprivate func showMessage(key: String, errorCode: String) {
        let error = key.isEmpty ? "Error.\(errorCode)" : "Error.\(key).\(errorCode)"
        if let topViewController = UIApplication.topViewController() {
            topViewController.showMessage(
                error.localize(),
                type: .error,
                options: [.textNumberOfLines(2)]
            )
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
}
