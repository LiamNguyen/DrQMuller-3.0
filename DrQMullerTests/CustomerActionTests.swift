import XCTest
import SwiftyJSON
@testable import DrQMuller

class CustomerActionTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testSaveCustomer() throws {
        let customerInfoWithoutToken: [String: Any] = [
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
        var customerInfo: [String: Any] = customerInfoWithoutToken
        customerInfo["authorizationToken"] = "A28B9320-B9DB-4E0C-91B9-AF7CDCE228A6"

        XCTAssertThrowsError(try CustomerAction.saveCustomer(info: customerInfoWithoutToken))
        XCTAssertNoThrow(try CustomerAction.saveCustomer(info: customerInfo))

        XCTAssertEqual(AppStore.sharedInstance.getState()["customer"], JSON(customerInfoWithoutToken))
        XCTAssertEqual(try KeychainAccessService.getString(forKey: .authorizationToken), customerInfo["authorizationToken"] as? String)
    }
}
