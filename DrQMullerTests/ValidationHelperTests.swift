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

		let schemeFailBoth = [
			"username": "@#$@#$@#",
			"password": "##@$@#$@"
		]

		XCTAssertTrue(ValidationHelper.validate(scheme: schemeSuccess))
		XCTAssertFalse(ValidationHelper.validate(scheme: schemeFailUsername))
		XCTAssertFalse(ValidationHelper.validate(scheme: schemeFailPassword))
		XCTAssertFalse(ValidationHelper.validate(scheme: schemeFailBoth))
	}
}
