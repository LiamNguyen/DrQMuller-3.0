import Foundation

protocol AuthenticationStoreType {
    func userLogin(_ credential: Data, _ completionHandler: @escaping (_ result: AuthenticationStore.AuthenticationResult, _ customer: Customer?) -> Void)
    func userRegister(_ credential: Data, _ completionHandler: @escaping (_ customer: Customer?) -> Void)
}
