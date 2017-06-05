import XCTest
@testable import DrQMuller

class AuthenticationStoreTests: XCTestCase {
	fileprivate var baseURL: URL!
	fileprivate var loginURL: URL!
	fileprivate var registerURL: URL!

	override func setUp() {
		super.setUp()

		self.baseURL = URL(string: Constants.Config.API_BASE_URL)
		self.loginURL = URL(string: "user/login", relativeTo: self.baseURL)
		self.registerURL = URL(string: "user/register", relativeTo: self.baseURL)
	}

	override func tearDown() {
		super.tearDown()

		self.baseURL = nil
		self.loginURL = nil
		self.registerURL = nil
	}

	func testUserLoginSuccess() {
		let promise = expectation(description: "HTTP Status: 200 and Customer is not nil")

		let credentialObject = [
			"username": "pnguyen1",
			"password": "pnguyen1"
		]
		let credentialData = try? Helper.jsonObjectToData(credentialObject)

		AuthenticationStore.sharedInstance.userLogin(credentialData!) { (result, customer) in
			if result == .login_success && customer != nil {
				promise.fulfill()
			}
		}

		waitForExpectations(timeout: 5, handler: nil)
	}

	func testUserLoginFail() {
		let promise = expectation(description: "HTTP Status not 200 and Customer is nil")

		let credentialObject = [
			"username": "@#!!@!@",
			"password": "@#$#@$"
		]
		let credentialData = try? Helper.jsonObjectToData(credentialObject)

		AuthenticationStore.sharedInstance.userLogin(credentialData!) { (result, customer) in
			if (result != .login_success && customer == nil) {
				promise.fulfill()
			}
		}

		waitForExpectations(timeout: 5, handler: nil)
	}
}
