import XCTest
@testable import DrQMuller

class KeyChainAccessServiceTests: XCTestCase {

    fileprivate var testDataStore: String!
    fileprivate var testDataRemove: String!

    override func setUp() {
        super.setUp()

        testDataStore = "0EAAF8AF-A61E-4840-B112-7D020AE0B3FF"
        testDataRemove = "47F85747-28B9-4150-A396-A37263F5F6D0"
	}

    override func tearDown() {
        super.tearDown()

        testDataStore = nil
        testDataRemove = nil

        try? KeychainAccessService.remove(forKey: .testStore)
        try? KeychainAccessService.remove(forKey: .testRemove)
    }

    func testStoreKeyChain() throws {
		XCTAssertNoThrow(try KeychainAccessService.store(value: testDataStore, forKey: .testStore))
        XCTAssertNoThrow(try KeychainAccessService.getString(forKey: .testStore))
        XCTAssertEqual(try KeychainAccessService.getString(forKey: .testStore), testDataStore)
    }

    func testRemoveKeyChain() throws {
        XCTAssertNoThrow(try KeychainAccessService.store(value: testDataRemove, forKey: .testRemove))
        XCTAssertNoThrow(try KeychainAccessService.remove(forKey: .testRemove))
        XCTAssertThrowsError(try KeychainAccessService.getString(forKey: .testRemove))
    }
}
