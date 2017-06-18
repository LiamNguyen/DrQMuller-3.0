import XCTest
@testable import DrQMuller

class LoginViewModelTests: XCTestCase {

	fileprivate var loginViewModel: LoginViewModel!

	override func setUp() {
		super.setUp()

		loginViewModel = LoginViewModel()
		setUpCredential()
	}

	override func tearDown() {
		super.tearDown()

		loginViewModel = nil
	}

	func testSaveCustomer() throws {
		loginViewModel.userLogin { _ in
			XCTAssertNotEqual(try? KeychainAccessService.getString(forKey: .authorizationToken), "")
			XCTAssertNotEqual(AppStore.sharedInstance.getState()[AppStore.StateKey.customer.rawValue], "")
		}
	}

	func testUsernameAndPasswordAreStored() throws {
		loginViewModel.userLogin { _ in
			XCTAssertEqual(try? KeychainAccessService.getString(forKey: .username), "pnguyen1")
			XCTAssertEqual(try? KeychainAccessService.getString(forKey: .password), "pnguyen1")
		}
	}

	fileprivate func setUpCredential() {
		loginViewModel.username.value = "pnguyen1"
		loginViewModel.password.value = "pnguyen1"
	}
}
