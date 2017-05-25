import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet fileprivate weak var txt_Username     : CustomTextField!
    @IBOutlet fileprivate weak var txt_Password     : CustomTextField!
    @IBOutlet fileprivate weak var btn_ResetPassword: UIButton!
    @IBOutlet fileprivate weak var btn_Login        : CustomButton!
    @IBOutlet fileprivate weak var btn_Register     : CustomButton!
	@IBOutlet fileprivate weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet fileprivate weak var constraint_TopUsername_BottomLogo: NSLayoutConstraint!
	
	fileprivate var loginViewModel: LoginViewModel!
	
	fileprivate var disposeBag: DisposeBag! = DisposeBag()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.loginViewModel = LoginViewModel()
		
		self.txt_Username.delegate = self
		self.txt_Password.delegate = self
		
		customizeAppearance()
		
		bindRxObserver()
		bindRxAction()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		
		self.navigationController?.navigationBar.isHidden = true
		setPlaceHoldersAndButtonTitles()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(true)
		
        self.navigationController?.navigationBar.isHidden = false
	}
	
//	Mark: Bind observables from ViewModel
	
	fileprivate func bindRxObserver() {
		
		loginViewModel.isLoading.asObservable()
			.subscribe(onNext: { [weak self] isLoading in
				isLoading ?
					self?.activityIndicator.startAnimating() :
				self?.activityIndicator.stopAnimating()
			}).addDisposableTo(disposeBag)
		
		loginViewModel.originalValue_Constraint_TopUsername_BottomLogoObservable = Float(self.constraint_TopUsername_BottomLogo.constant)
		loginViewModel.constraint_TopUsername_BottomLogoObservable
			.map({ CGFloat($0) })
			.subscribe(onNext: { [weak self] constant in
				DispatchQueue.main.async {
					self?.constraint_TopUsername_BottomLogo.constant = constant
					UIView.animate(withDuration: 0.4, animations: {
						self?.view.layoutIfNeeded()
					})
				}
			}).addDisposableTo(disposeBag)
	}
	
//	Mark: Bind actions supported by RxSwift & RxCocoa
	
	fileprivate func bindRxAction() {
		
	}
	
//	Mark: Draw layout and initial view appearance
	
	fileprivate func customizeAppearance() {
		self.view.layer.contents = UIImage(named: Constants.Login.View.loginBackground)?.cgImage

	}
	
//	Mark: Localize texts when language changed
	
    fileprivate func setPlaceHoldersAndButtonTitles() {
//        Mark: Textfield Placeholder

        self.txt_Username.placeholder = Constants.Login.TextfieldPlaceHolder.username
        self.txt_Password.placeholder = Constants.Login.TextfieldPlaceHolder.password
        
//        Mark: Buttons's Title
        
        self.btn_ResetPassword.setTitle(Constants.Login.Button.resetPassword, for: .normal)
		self.btn_Login.setTitle(Constants.Login.Button.login, for: .normal)
		self.btn_Register.setTitle(Constants.Login.Button.register, for: .normal)
    }
	
//	Mark: Textfields delegation
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		if Constants.DeviceModel.deviceType() == .iPhone5 {
			loginViewModel.viewShouldAdjustWhenKeyBoardAppears.value = true
		}
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		
		if textField == txt_Username {
			txt_Password.becomeFirstResponder()
			return false
		} else {
			loginViewModel.viewShouldAdjustWhenKeyBoardAppears.value = false
			return true
		}
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.view.endEditing(true)
		loginViewModel.viewShouldAdjustWhenKeyBoardAppears.value = false
	}
}

