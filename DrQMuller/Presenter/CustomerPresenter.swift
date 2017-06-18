import Foundation
import SwiftyJSON

struct CustomerPresenter {
	static func currentCustomer() -> JSON {
	    return AppStore.sharedInstance.getState()[StateKeys.customer]
	}

	static func isCustomerNotYetFilledProfile() -> Bool {
	    return CustomerPresenter.currentCustomer()[StateKeys.CustomerInformation.uiSavedStep] == "none"
	}
}
