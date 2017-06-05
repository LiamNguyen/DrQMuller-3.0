import XCTest
import SwiftyJSON
@testable import DrQMuller

class AppStoreTests: XCTestCase {
    fileprivate var currentStoredAppState: Any?
    fileprivate var initialState: JSON!
    fileprivate var firstExpectedState: JSON!
    fileprivate var secondExpectedState: JSON!
    fileprivate var thirdExpectedState: JSON!

    override func setUp() {
        super.setUp()

        initializeAppStateForTesting()
        currentStoredAppState = UserDefaultsService.get(forKey: .appState)
        UserDefaultsService.remove(forKey: .appState)
    }

    override func tearDown() {
        super.tearDown()

        UserDefaultsService.save(forKey: .appState, data: currentStoredAppState!)
        currentStoredAppState = nil
        initialState = nil
        firstExpectedState = nil
        secondExpectedState = nil
        thirdExpectedState = nil
    }

    func testDispatchAction() {
        XCTAssertEqual(AppStore.sharedInstance.getState(), initialState)

        try? AppStore.sharedInstance.dispatch(action: (key: "hello", state: "I am testing something here for sure"))

        XCTAssertEqual(AppStore.sharedInstance.getState(), firstExpectedState)

        try? AppStore.sharedInstance.dispatch(action: (key: "MyList", state: ["Find more money", "Find even more and more money"]))

        XCTAssertEqual(AppStore.sharedInstance.getState(), secondExpectedState)

        try? AppStore.sharedInstance.dispatch(action: (key: "MyList", state: ["I replaced it already"]))

        XCTAssertEqual(AppStore.sharedInstance.getState(), thirdExpectedState)
    }

    fileprivate func initializeAppStateForTesting() {
        initialState = JSON(
            [
                "customer": ""
            ]
        )
        firstExpectedState = JSON(
            [
                "customer": "",
                "hello": "I am testing something here for sure"
            ]
        )
        secondExpectedState = JSON(
            [
                "customer": "",
                "hello": "I am testing something here for sure",
                "MyList": [
                    "Find more money",
                    "Find even more and more money"
                ]
            ]
        )
        thirdExpectedState = JSON(
            [
                "customer": "",
                "hello": "I am testing something here for sure",
                "MyList": [
                    "Find more money",
                    "Find even more and more money",
                    "I replaced it already"
                ]
            ]
        )
    }
}
