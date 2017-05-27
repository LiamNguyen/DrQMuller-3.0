import Foundation
import Alamofire

class Retrier: RequestRetrier {

    var defaultRetryCount = 3
    fileprivate  var requestsAndRetryCounts: [(Request, Int)] = []
    fileprivate  var lock = NSLock()

    fileprivate func index(_ request: Request) -> Int? {
        return requestsAndRetryCounts.index(where: { $0.0 === request })
    }

    func addRetryInfo(_ request: Request, retryCount: Int? = nil) {
        lock.lock() ; defer { lock.unlock() }
        guard index(request) == nil else { print("ERROR addRetryInfo called for already tracked request"); return }

        requestsAndRetryCounts.append((request, retryCount ?? defaultRetryCount))
    }

    func deleteRetryInfo(_ request: Request) {
        lock.lock() ; defer { lock.unlock() }
        guard let index = index(request) else { print("ERROR deleteRetryInfo called for not tracked request"); return }

        requestsAndRetryCounts.remove(at: index)
    }

    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {

        lock.lock() ; defer { lock.unlock() }

        guard let index = index(request) else { completion(false, 0); return }
        let (request, retryCount) = requestsAndRetryCounts[index]

        if retryCount == 0 {
            completion(false, 0)
        } else {
            requestsAndRetryCounts[index] = (request, retryCount - 1)
            completion(true, 0.5)
        }
    }
}
