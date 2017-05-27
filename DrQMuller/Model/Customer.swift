import Foundation
import ObjectMapper

class Customer: Mappable {
    var customerId: String?
    var customerName: String?
    var dob: String?
    var gender: Constants.Gender?
    var phone: String?
    var address: String?
    var email: String?
    var uiSavedStep: Constants.UISavedStep?
    var active: Bool?
    var authorizationToken: String?

    required init?(map: Map) {}

    init() {}

    func mapping(map: Map) {
		self.customerId         <- map["customerId"]
        self.customerName       <- map["customerName"]
        self.dob                <- map["dob"]
        self.gender             <- map["gender"]
        self.phone              <- map["phone"]
        self.address            <- map["address"]
        self.email              <- map["email"]
        self.uiSavedStep        <- map["uiSavedStep"]
        self.active             <- map["active"]
        self.authorizationToken <- map["authorizationToken"]
	}
}
