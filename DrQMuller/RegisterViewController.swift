import UIKit
import RxSwift

class RegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet fileprivate weak var txtUsername: CustomTextField!
    @IBOutlet fileprivate weak var txtPassword: CustomTextField!
    @IBOutlet fileprivate weak var txtConfirmPassword: CustomTextField!
    @IBOutlet fileprivate weak var btnRegister: CustomButton!
    @IBOutlet fileprivate weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet fileprivate weak var constraintTopUsernameBottomLogo: NSLayoutConstraint!
    @IBOutlet fileprivate weak var constraintTopLogoTopView: NSLayoutConstraint!
	@IBOutlet fileprivate weak var lblConfirmPasswordMismatch: UILabel!

	fileprivate var registerViewModel: RegisterViewModel!

    fileprivate let disposeBag: DisposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

		self.registerViewModel = RegisterViewModel()

		self.txtUsername.delegate = self
		self.txtPassword.delegate = self
		self.txtConfirmPassword.delegate = self

		customizeAppearance()

		bindRxObserver()
		bindRxAction()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        self.navigationController?.navigationBar.isHidden = true
        setUITexts()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)

        self.navigationController?.navigationBar.isHidden = false
    }

//	Mark: Bind observables from ViewModel

	fileprivate func bindRxObserver() {

		registerViewModel.isLoading.asObservable()
			.subscribe(onNext: { [weak self] isLoading in
				isLoading ?
					self?.activityIndicator.startAnimating() :
					self?.activityIndicator.stopAnimating()
			}).addDisposableTo(disposeBag)

		registerViewModel.initialConstraintUsernameLogo = Float(self.constraintTopUsernameBottomLogo.constant)
		registerViewModel.initialConstraintLogoView = Float(self.constraintTopLogoTopView.constant)

		Observable.combineLatest(
			registerViewModel.constraintUsernameLogoObservable,
			registerViewModel.constraintLogoViewObservable
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

		registerViewModel.confirmPasswordTextFieldBorderWidthObservable
			.map({ CGFloat($0) })
			.subscribe(onNext: { [weak self] width in
				self?.txtConfirmPassword.layer.borderWidth = width
			}).addDisposableTo(disposeBag)

		registerViewModel.confirmPasswordTextFieldBorderColorObservable
			.subscribe(onNext: { [weak self] color in
				self?.txtConfirmPassword.layer.borderColor = color
			}).addDisposableTo(disposeBag)

		registerViewModel.confirmPasswordMatchObservable
			.bind(to: lblConfirmPasswordMismatch.rx.isHidden)
			.addDisposableTo(disposeBag)

		registerViewModel.registerButtonShouldEnable
			.bind(to: btnRegister.rx.isEnabled)
			.addDisposableTo(disposeBag)

		registerViewModel.registerButtonAlphaObservable
			.map({ CGFloat($0) })
			.bind(to: btnRegister.rx.alpha)
			.addDisposableTo(disposeBag)

//        Mark: Text fields onChange observable

		txtUsername
			.rx
			.text
			.subscribe(onNext: { [weak self] username in
				self?.registerViewModel.username.value = username ?? ""
			}).addDisposableTo(disposeBag)

		txtPassword
			.rx
			.text
			.subscribe(onNext: { [weak self] password in
				self?.registerViewModel.password.value = password ?? ""
			}).addDisposableTo(disposeBag)

		txtConfirmPassword
			.rx
			.text
			.subscribe(onNext: { [weak self] confirmPassword in
				self?.registerViewModel.confirmPassword.value = confirmPassword ?? ""
			}).addDisposableTo(disposeBag)
	}

	fileprivate func bindRxAction() {
		btnRegister
			.rx
			.tap
			.subscribe(onNext: { [weak self] _ in
				self?.userRegister()
			}).addDisposableTo(disposeBag)
	}

	fileprivate func userRegister() {
	    registerViewModel.userRegister { result in
		    switch result {
		    case .register_success:
		        print("User registered")
		        print(AppStore.sharedInstance.getState()[AppStore.StateKey.customer.rawValue])
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

    fileprivate func setUITexts() {
//        Mark: TextFields Placeholder

        self.txtUsername.placeholder = Constants.Register.TextFieldPlaceHolder.username
        self.txtPassword.placeholder = Constants.Register.TextFieldPlaceHolder.password
		self.txtConfirmPassword.placeholder = Constants.Register.TextFieldPlaceHolder.confirmPassword

//        Mark: Buttons's Title

        self.btnRegister.setTitle(Constants.Register.Button.register, for: .normal)

//	    Mark: Labels

        self.lblConfirmPasswordMismatch.text = Constants.Register.Label.confirmPasswordMismatch
    }

	//	Mark: TextFields delegation

	func textFieldDidBeginEditing(_ textField: UITextField) {
		if ![.iPadMini, .iPadPro].contains(Constants.DeviceModel.deviceType()) {
			registerViewModel.viewShouldAdjustWhenKeyBoardAppears.value = true
		}
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()

		if textField == txtUsername {
			txtPassword.becomeFirstResponder()
			return false
		} else if textField == txtPassword {
			txtConfirmPassword.becomeFirstResponder()
			return false
		} else {
			registerViewModel.viewShouldAdjustWhenKeyBoardAppears.value = false
			userRegister()
			return true
		}
	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.view.endEditing(true)
		registerViewModel.viewShouldAdjustWhenKeyBoardAppears.value = false
	}
}
