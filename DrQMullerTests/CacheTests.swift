import XCTest
@testable import DrQMuller

class CacheTests: XCTestCase {

	fileprivate var currentStoredAppCache: Any?
	fileprivate var testDataMyList: [String]!
	fileprivate var testDataCustomer: [String: Any]!

	override func setUp() {
		super.setUp()

		currentStoredAppCache = UserDefaultsService.get(forKey: .appCache)
		try? UserDefaultsService.remove(forKey: .appCache)

		testDataMyList = [
			"Find more money",
			"Find even more and more money",
			"I replaced it already"
		]

		testDataCustomer = [
			"customerId": "4B2AA2B5-9A1F-4A92-BFC1-7DE483F09A4A",
			"customerName": "Testing bots",
			"dob": "1980-01-22",
			"gender": "Male",
			"phone": "00000000000",
			"address": "Testing address",
			"email": "test@test.com",
			"uiSavedStep": "none",
			"active": 0
		]
	}

	override func tearDown() {
		super.tearDown()

		if let currentStoredAppCache = currentStoredAppCache {
			try? UserDefaultsService.save(forKey: .appCache, data: currentStoredAppCache)
		}
		currentStoredAppCache = nil
		testDataMyList = nil
		testDataCustomer = nil
	}

	func testSaveCacheByGettingRequiredFieldsFromStateTree() throws {
        AppStore.sharedInstance.disableAutoStoreUserDefaults()
        AppStore.sharedInstance.resetAppState()
        AppStore.sharedInstance.enableAutoStoreUserDefaults()

		XCTAssertNoThrow(try Cache.sharedInstance.save(fields: [.customer]))

		XCTAssertTrue(UserDefaultsService.get(forKey: .appCache) == nil)

		XCTAssertThrowsError(try Cache.sharedInstance.save(fields: [.customer, .myList]))

		XCTAssertNoThrow(try AppStore.sharedInstance.dispatch(
			action: (key: .myList, state: testDataMyList)
		))

        XCTAssertTrue(UserDefaultsService.get(forKey: .appCache) == nil)

        XCTAssertNoThrow(try AppStore.sharedInstance.dispatch(
            action: (key: .customer, state: testDataCustomer)
        ))

        XCTAssertFalse(UserDefaultsService.get(forKey: .appCache) == nil)

		XCTAssertNoThrow(try Cache.sharedInstance.save(fields: [.customer, .myList]))

		if let storedAppCache = UserDefaultsService.get(forKey: .appCache) as? String {
            XCTAssertEqual(AppStore.sharedInstance.getState(), Helper.stringToJSON(string: storedAppCache))
        } else {
            XCTFail()
        }
	}
}
