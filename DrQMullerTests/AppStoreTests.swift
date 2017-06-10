import XCTest
import SwiftyJSON
@testable import DrQMuller

class AppStoreTests: XCTestCase {
    fileprivate var currentStoredAppCache: Any?
    fileprivate var initialState: JSON!
    fileprivate var firstExpectedState: JSON!
    fileprivate var secondExpectedState: JSON!
    fileprivate var thirdExpectedState: JSON!
    fileprivate var customer: JSON!

    override func setUp() {
        super.setUp()

        initializeAppStateForTesting()
        currentStoredAppCache = UserDefaultsService.get(forKey: .appCache)
        try? UserDefaultsService.remove(forKey: .appCache)
    }

    override func tearDown() {
        super.tearDown()

		if let currentStoredAppCache = currentStoredAppCache {
			try? UserDefaultsService.save(forKey: .appCache, data: currentStoredAppCache)
		}
        currentStoredAppCache = nil
        initialState = nil
        firstExpectedState = nil
        secondExpectedState = nil
        thirdExpectedState = nil
        customer = nil
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

		XCTAssertTrue(UserDefaultsService.get(forKey: .appCache) == nil)

        try? AppStore.sharedInstance.dispatch(action: (key: .testing, state: "I am testing something here for sure"))

        XCTAssertTrue(UserDefaultsService.get(forKey: .appCache) == nil)

        try? AppStore.sharedInstance.dispatch(action: (key: .customer, state: customer))

        if let storedAppCache = UserDefaultsService.get(forKey: .appCache) as? String {
            let customerStateKey: String = AppStore.StateKey.customer.rawValue
            let storedCustomer = Helper.stringToJSON(string: storedAppCache)[customerStateKey]
            let currentCustomer = AppStore.sharedInstance.getState()[customerStateKey]

            XCTAssertEqual(storedCustomer, currentCustomer)
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

        customer = JSON([
            "customerId": "4B2AA2B5-9A1F-4A92-BFC1-7DE483F09A4A",
            "customerName": "Testing bots",
            "dob": "1980-01-22",
            "gender": "Male",
            "phone": "00000000000",
            "address": "Testing address",
            "email": "test@test.com",
            "uiSavedStep": "none",
            "active": 0
        ])
    }
}
