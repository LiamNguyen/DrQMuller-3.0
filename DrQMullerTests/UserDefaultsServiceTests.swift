import XCTest
@testable import DrQMuller

class UserDefaultsServiceTests: XCTestCase {

    var testDataSave: String!
    var testDataSaveSecond: [String]!
    var testDataGet: String!
    var testDataRemove: String!

    override func setUp() {
        super.setUp()

        testDataSave = "Test save"
        testDataSaveSecond = ["Test save array"]
        testDataGet = "Test get"
        testDataRemove = "Test remove"
    }

    override func tearDown() {
        super.tearDown()

        testDataSave = nil
        testDataGet = nil
        testDataRemove = nil

        _ = UserDefaultsService.remove(forKey: .testSave)
        _ = UserDefaultsService.remove(forKey: .testGet)
        _ = UserDefaultsService.remove(forKey: .testRemove)
    }

    func testSavingToUserDefaults() {
        XCTAssertTrue(UserDefaultsService.save(forKey: .testSave, data: testDataSave))

        if let retrievedTestDataSave = UserDefaultsService.get(forKey: .testSave) as? String {
            XCTAssertEqual(retrievedTestDataSave, testDataSave)
        } else {
            XCTFail()
        }

        XCTAssertTrue(UserDefaultsService.save(forKey: .testSave, data: testDataSaveSecond))

        if let retrievedTestDataSaveSecond = UserDefaultsService.get(forKey: .testSave) as? [String] {
            XCTAssertEqual(retrievedTestDataSaveSecond, testDataSaveSecond)
        } else {
            XCTFail()
        }
    }

    func testGetFromUserDefaults() {
        XCTAssertTrue(UserDefaultsService.get(forKey: .testGet) == nil)

        if UserDefaultsService.save(forKey: .testGet, data: testDataGet) {
            if let retrievedTestDataGet = UserDefaultsService.get(forKey: .testGet) as? String {
                XCTAssertEqual(retrievedTestDataGet, testDataGet)
            } else {
                XCTFail()
            }
        } else {
            XCTFail()
        }
    }

    func testRemoveFromUserDefaults() {
        XCTAssertTrue(UserDefaultsService.save(forKey: .testRemove, data: testDataRemove))
        XCTAssertTrue(UserDefaultsService.remove(forKey: .testRemove))
        XCTAssertTrue(UserDefaultsService.get(forKey: .testRemove) == nil)
    }
}
