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
        try? UserDefaultsService.remove(forKey: .appState)
    }

    override func tearDown() {
        super.tearDown()

		if let currentStoredAppState = currentStoredAppState {
			try? UserDefaultsService.save(forKey: .appState, data: currentStoredAppState)
		}
        currentStoredAppState = nil
        initialState = nil
        firstExpectedState = nil
        secondExpectedState = nil
        thirdExpectedState = nil
    }

    func testDispatchAction() {
        AppStore.sharedInstance.disableAutoStoreUserDefaults()
        AppStore.sharedInstance.resetAppState()

        XCTAssertEqual(AppStore.sharedInstance.getState(), initialState)

        try? AppStore.sharedInstance.dispatch(action: (key: .testing, state: "I am testing something here for sure"))

        XCTAssertEqual(AppStore.sharedInstance.getState(), firstExpectedState)

        try? AppStore.sharedInstance.dispatch(action: (key: .myList, state: ["Find more money", "Find even more and more money"]))

        XCTAssertEqual(AppStore.sharedInstance.getState(), secondExpectedState)

        try? AppStore.sharedInstance.dispatch(action: (key: .myList, state: ["I replaced it already"]))

        XCTAssertEqual(AppStore.sharedInstance.getState(), thirdExpectedState)

        AppStore.sharedInstance.enableAutoStoreUserDefaults()
    }

    func testAutoSaveToUserDefaultsWhenAppStateChange() {
        AppStore.sharedInstance.disableAutoStoreUserDefaults()
        AppStore.sharedInstance.resetAppState()
        AppStore.sharedInstance.enableAutoStoreUserDefaults()

		XCTAssertTrue(UserDefaultsService.get(forKey: .appState) == nil)

        try? AppStore.sharedInstance.dispatch(action: (key: .testing, state: "I am testing something here for sure"))

        if let storedAppState = UserDefaultsService.get(forKey: .appState) as? String {
            XCTAssertEqual(Helper.stringToJSON(string: storedAppState), firstExpectedState)
        } else {
            XCTFail()
        }
    }

    fileprivate func initializeAppStateForTesting() {
        initialState = JSON(
            [
                AppStore.StateKey.customer.rawValue: ""
            ]
        )
        firstExpectedState = JSON(
            [
                AppStore.StateKey.customer.rawValue: "",
                AppStore.StateKey.testing.rawValue: "I am testing something here for sure"
            ]
        )
        secondExpectedState = JSON(
            [
                AppStore.StateKey.customer.rawValue: "",
                AppStore.StateKey.testing.rawValue: "I am testing something here for sure",
                AppStore.StateKey.myList.rawValue: [
                    "Find more money",
                    "Find even more and more money"
                ]
            ]
        )
        thirdExpectedState = JSON(
            [
                AppStore.StateKey.customer.rawValue: "",
                AppStore.StateKey.testing.rawValue: "I am testing something here for sure",
                AppStore.StateKey.myList.rawValue: [
                    "Find more money",
                    "Find even more and more money",
                    "I replaced it already"
                ]
            ]
        )
    }
}
