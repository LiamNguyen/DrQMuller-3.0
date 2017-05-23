import UIKit

class LoginViewController: UIViewController {

    @IBOutlet fileprivate weak var txt_Username     : CustomTextField!
    @IBOutlet fileprivate weak var txt_Password     : CustomTextField!
    @IBOutlet fileprivate weak var btn_ResetPassword: UIButton!
    @IBOutlet fileprivate weak var btn_Login        : CustomButton!
    @IBOutlet fileprivate weak var btn_Register     : CustomButton!
    
    @IBOutlet fileprivate weak var constraint_TopUsername_BottomLogo: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
		customizeAppearance()
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
	
	fileprivate func customizeAppearance() {
		self.view.layer.contents = UIImage(named: Constants.Login.View.loginBackground)?.cgImage

	}
    
    fileprivate func setPlaceHoldersAndButtonTitles() {
//        Mark: Textfield Placeholder

        self.txt_Username.placeholder = Constants.Login.TextfieldPlaceHolder.username
        self.txt_Password.placeholder = Constants.Login.TextfieldPlaceHolder.password
        
//        Mark: Buttons's Title
        
        self.btn_ResetPassword.setTitle(Constants.Login.Button.resetPassword, for: .normal)
		self.btn_Login.setTitle(Constants.Login.Button.login, for: .normal)
		self.btn_Register.setTitle(Constants.Login.Button.register, for: .normal)
    }
}

