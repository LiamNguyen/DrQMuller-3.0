import Foundation
import RxSwift
import SwiftyJSON

class Cache {
    static let sharedInstance = Cache()

    fileprivate var initialCache: JSON!
    fileprivate var appCache: Variable<JSON>!

    fileprivate let disposeBag = DisposeBag()

    fileprivate init() {
        initialCache = JSON([
            AppStore.StateKey.customer.rawValue: ""
        ])

        if let storedAppCache = UserDefaultsService.get(forKey: .appCache) as? String {
            appCache = Variable(Helper.stringToJSON(string: storedAppCache))
        } else {
            appCache = Variable(initialCache)
        }

        bindRx()
    }

    fileprivate func bindRx() {
        appCache.asObservable()
            .subscribe(onNext: { [weak self] stateCache in
                do {
                    if self?.appCache.value != self?.initialCache {
                        try UserDefaultsService.save(forKey: .appCache, data: stateCache.rawString() as Any)
                    }
                } catch let error as ExtendError {
                    ErrorDisplayService.sharedInstance.failReason.value.append((
                        key: "",
                        errorCode: error.commonErrorCode
                    ))
                    Logger.sharedInstance.log(event: error.descriptionForLog, type: .error)
                } catch let error {
                    Logger.sharedInstance.log(event: error.localizedDescription, type: .error)
                }
            }).addDisposableTo(disposeBag)
    }

    func getAppCache() -> JSON {
        return appCache.value
    }

    func save(fields: [AppStore.StateKey]) throws {
        var newCache: [String: Any] = [String: Any]()

        _ = try fields.map { key in
            if AppStore.sharedInstance.getState()[key.rawValue] == JSON.null {
                throw ExtendError.FindKeyInStateTreeFailed
            }
            newCache[key.rawValue] = AppStore.sharedInstance.getState()[key.rawValue]
        }

        mergeCache(cache: JSON(newCache))
    }

    fileprivate func mergeCache(cache: JSON) {
        do {
            appCache.value = try appCache.value.merged(with: cache)
        } catch let error {
            Logger.sharedInstance.log(event: "SwiftyJson merge error:\n\(error.localizedDescription)", type: .error)
            ErrorDisplayService.sharedInstance.failReason.value.append((
                key: "",
                errorCode: "application_error"
            ))
        }
    }
}
