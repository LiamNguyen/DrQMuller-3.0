import XCTest
@testable import DrQMuller

class ValidationHelperTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

	func testValidate() {
		let schemeSuccess = [
			"username": "pnguyen1",
			"password": "pnguyen1"
		]

		let schemeFailUsername = [
			"username": "*#@$($#@!$F",
			"password": "pnguyen1"
		]

		let schemeFailPassword = [
			"username": "pnguyen1",
			"password": ""
		]

		XCTAssertTrue(ValidationHelper.validate(scheme: schemeSuccess).isEmpty)
		XCTAssertEqual(
			ValidationHelper.validate(scheme: schemeFailUsername)[0].key,
			"username"
		)
		XCTAssertEqual(
			ValidationHelper.validate(scheme: schemeFailUsername)[0].errorCode,
			"patternFail"
		)
		XCTAssertEqual(
			ValidationHelper.validate(scheme: schemeFailPassword)[0].key,
			"password"
		)
		XCTAssertEqual(
			ValidationHelper.validate(scheme: schemeFailPassword)[0].errorCode,
			"empty"
		)
	}

    func testPerformanceExample() {
        self.measure {
        }
    }
}
