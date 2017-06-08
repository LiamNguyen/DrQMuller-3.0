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

        try? UserDefaultsService.remove(forKey: .testSave)
        try? UserDefaultsService.remove(forKey: .testGet)
        try? UserDefaultsService.remove(forKey: .testRemove)
    }

    func testSavingToUserDefaults() throws {
        XCTAssertNoThrow(try UserDefaultsService.save(forKey: .testSave, data: testDataSave))

        if let retrievedTestDataSave = UserDefaultsService.get(forKey: .testSave) as? String {
            XCTAssertEqual(retrievedTestDataSave, testDataSave)
        } else {
            XCTFail()
        }

        XCTAssertNoThrow(try UserDefaultsService.save(forKey: .testSave, data: testDataSaveSecond))

        if let retrievedTestDataSaveSecond = UserDefaultsService.get(forKey: .testSave) as? [String] {
            XCTAssertEqual(retrievedTestDataSaveSecond, testDataSaveSecond)
        } else {
            XCTFail()
        }
    }

    func testGetFromUserDefaults() throws {
        XCTAssertTrue(UserDefaultsService.get(forKey: .testGet) == nil)
        XCTAssertNoThrow(try UserDefaultsService.save(forKey: .testGet, data: testDataGet))

        if let retrievedTestDataGet = UserDefaultsService.get(forKey: .testGet) as? String {
            XCTAssertEqual(retrievedTestDataGet, testDataGet)
        } else {
            XCTFail()
        }
    }

    func testRemoveFromUserDefaults() throws {
        XCTAssertNoThrow(try UserDefaultsService.save(forKey: .testRemove, data: testDataRemove))
        XCTAssertNoThrow(try UserDefaultsService.remove(forKey: .testRemove))
        XCTAssertTrue(UserDefaultsService.get(forKey: .testRemove) == nil)
    }
}
