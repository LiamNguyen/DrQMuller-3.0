import Foundation
import SwiftyBeaver

class Logger {

    static let sharedInstance = Logger()

    fileprivate let beaverLog = SwiftyBeaver.self

    fileprivate init() {
        let cloud = SBPlatformDestination(
            appID: Constants.appId,
            appSecret: Constants.appCode,
            encryptionKey: Constants.logKey
        )
        let console = ConsoleDestination()
        let file = FileDestination()

        beaverLog.addDestination(cloud)
        beaverLog.addDestination(console)
        beaverLog.addDestination(file)
    }

    func log(event: Any, type: LogType) {
        #if DEVELOPMENT
            print(event)
        #else
            switch type {
            case .verbose:
                beaverLog.verbose(event)
            case .debug:
                beaverLog.debug(event)
            case .info:
                beaverLog.info(event)
            case .warning:
                beaverLog.warning(event)
            case .error:
                beaverLog.error(event)
            }
        #endif
    }

    enum LogType {
        case verbose
        case debug
        case info
        case warning
        case error
    }
}
