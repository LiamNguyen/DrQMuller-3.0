import UIKit
import RxSwift
import RxCocoa
import AudioToolbox

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet fileprivate weak var txtUsername: CustomTextField!
    @IBOutlet fileprivate weak var txtPassword: CustomTextField!
    @IBOutlet fileprivate weak var btnResetPassword: UIButton!
    @IBOutlet fileprivate weak var btnLogin: CustomButton!
    @IBOutlet fileprivate weak var btnRegister: CustomButton!
	@IBOutlet fileprivate weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet fileprivate weak var constraintTopUsernameBottomLogo: NSLayoutConstraint!

	fileprivate var loginViewModel: LoginViewModel!

	fileprivate var disposeBag: DisposeBag! = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

		self.loginViewModel = LoginViewModel()

		self.txtUsername.delegate = self
		self.txtPassword.delegate = self

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

    @IBAction func txtUserNameOnChange(_ sender: CustomTextField) {
		loginViewModel.username.value = txtUsername.text ?? ""
    }

    @IBAction func txtPasswordOnChange(_ sender: CustomTextField) {
        loginViewModel.password.value = txtPassword.text ?? ""
    }

//	Mark: Bind observables from ViewModel

	fileprivate func bindRxObserver() {

		loginViewModel.isLoading.asObservable()
			.subscribe(onNext: { [weak self] isLoading in
				isLoading ?
					self?.activityIndicator.startAnimating() :
				self?.activityIndicator.stopAnimating()
			}).addDisposableTo(disposeBag)

		loginViewModel.initialConstraintUsernameLogoObservable = Float(self.constraintTopUsernameBottomLogo.constant)
		loginViewModel.constraintUsernameLogoObservable
			.map({ CGFloat($0) })
			.subscribe(onNext: { [weak self] constant in
				DispatchQueue.main.async {
					self?.constraintTopUsernameBottomLogo.constant = constant
					UIView.animate(withDuration: 0.4, animations: {
						self?.view.layoutIfNeeded()
					})
				}
			}).addDisposableTo(disposeBag)
	}

//	Mark: Bind actions supported by RxSwift & RxCocoa

	fileprivate func bindRxAction() {
        btnLogin
            .rx
            .tap
            .subscribe(onNext: { [weak self] in
                self?.userLogin()
            }).addDisposableTo(disposeBag)
    }

//    Mark: User Login

    fileprivate func userLogin() {
        loginViewModel.userLogin { result in
            switch result {
            case .login_success:
                print("User in")
            default:
				AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
				self.showMessage(result.rawValue.localize(), type: .error, options: [.animation(.fade)])
            }
        }
    }

//	Mark: Draw layout and initial view appearance

	fileprivate func customizeAppearance() {
		self.view.layer.contents = UIImage(named: Constants.Login.View.loginBackground)?.cgImage

	}

//	Mark: Localize texts when language changed

    fileprivate func setPlaceHoldersAndButtonTitles() {
//        Mark: TextFields Placeholder

        self.txtUsername.placeholder = Constants.Login.TextFieldPlaceHolder.username
        self.txtPassword.placeholder = Constants.Login.TextFieldPlaceHolder.password

//        Mark: Buttons's Title

        self.btnResetPassword.setTitle(Constants.Login.Button.resetPassword, for: .normal)
		self.btnLogin.setTitle(Constants.Login.Button.login, for: .normal)
		self.btnRegister.setTitle(Constants.Login.Button.register, for: .normal)
    }

//	Mark: TextFields delegation

	func textFieldDidBeginEditing(_ textField: UITextField) {
		if Constants.DeviceModel.deviceType() == .iPhone5 {
			loginViewModel.viewShouldAdjustWhenKeyBoardAppears.value = true
		}
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()

		if textField == txtUsername {
			txtPassword.becomeFirstResponder()
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
