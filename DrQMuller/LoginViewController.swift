import UIKit
import RxSwift
import RxCocoa
import Localize
import NVActivityIndicatorView

class LoginViewController: UIViewController, UITextFieldDelegate, NVActivityIndicatorViewable {

    @IBOutlet fileprivate weak var txtUsername: CustomTextField!
    @IBOutlet fileprivate weak var txtPassword: CustomTextField!
    @IBOutlet fileprivate weak var btnResetPassword: UIButton!
    @IBOutlet fileprivate weak var btnLogin: CustomButton!
    @IBOutlet fileprivate weak var btnRegister: CustomButton!
	@IBOutlet fileprivate weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet fileprivate weak var constraintTopUsernameBottomLogo: NSLayoutConstraint!
    @IBOutlet fileprivate weak var constraintTopLogoTopView: NSLayoutConstraint!

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

//	Mark: Bind observables from ViewModel

	fileprivate func bindRxObserver() {

		loginViewModel.isLoading.asObservable()
			.subscribe(onNext: { [weak self] isLoading in
				isLoading ?
					self?.activityIndicator.startAnimating() :
				self?.activityIndicator.stopAnimating()
			}).addDisposableTo(disposeBag)

		loginViewModel.initialConstraintUsernameLogo = Float(self.constraintTopUsernameBottomLogo.constant)
		loginViewModel.initialConstraintLogoView = Float(self.constraintTopLogoTopView.constant)

		Observable.combineLatest(
				loginViewModel.constraintUsernameLogoObservable,
				loginViewModel.constraintLogoViewObservable
			)
			.map({ (CGFloat($0), CGFloat($1)) })
			.subscribe(onNext: { [weak self] (usernameLogoConstant, logoViewConstant) in
			DispatchQueue.main.async {
				self?.constraintTopUsernameBottomLogo.constant = usernameLogoConstant
				self?.constraintTopLogoTopView.constant = logoViewConstant
				UIView.animate(withDuration: 0.4, animations: {
					self?.view.layoutIfNeeded()
				})
			}
		}).addDisposableTo(disposeBag)

        loginViewModel.loginButtonShouldEnable
            .bind(to: btnLogin.rx.isEnabled)
            .addDisposableTo(disposeBag)

        loginViewModel.loginButtonAlphaObservable
            .map({ CGFloat($0) })
            .bind(to: btnLogin.rx.alpha)
            .addDisposableTo(disposeBag)

		loginViewModel.isLoadingForAutoLogin.asObservable()
			.subscribe(onNext: { [weak self] isLoadingForAutoLogin in
				if isLoadingForAutoLogin {
					self?.startAnimating(
						CGSize(width: 50, height: 50),
						message: Constants.Login.ActivityIndicator.loggingIn,
						type: NVActivityIndicatorType.ballTrianglePath
					)
				} else {
					self?.stopAnimating()
				}
			}).addDisposableTo(disposeBag)

		loginViewModel.autoLoginSuccess.asObservable()
			.subscribe(onNext: { [weak self] success in
				if success {
					
				}
			}).addDisposableTo(disposeBag)

//        Mark: Text fields onChange observable

        txtUsername
            .rx
            .text
            .subscribe(onNext: { [weak self] username in
                self?.loginViewModel.username.value = username ?? ""
            }).addDisposableTo(disposeBag)

        txtPassword
            .rx
            .text
            .subscribe(onNext: { [weak self] password in
                self?.loginViewModel.password.value = password ?? ""
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
        loginViewModel.userLogin {result in
            switch result {
            case .login_success:
                print("User in")
            default:
				ErrorDisplayService.sharedInstance.failReason.value.append((key: "", errorCode: result.rawValue))
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
		if ![.iPadMini, .iPadPro].contains(Constants.DeviceModel.deviceType()) {
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
			userLogin()
			return true
		}
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.view.endEditing(true)
		loginViewModel.viewShouldAdjustWhenKeyBoardAppears.value = false
	}

	@IBAction func unwindToLoginViewController(segue: UIStoryboardSegue) {}
}
