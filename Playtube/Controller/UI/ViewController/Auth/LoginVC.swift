//
//  LoginVC.swift
//  Playtube


import UIKit
import Async
import Toast_Swift
import FBSDKLoginKit
import GoogleSignIn
import PlaytubeSDK

class LoginVC: BaseViewController ,UITextFieldDelegate{
    
    @IBOutlet weak var texEmail: CustomTextFiled!
    @IBOutlet weak var textPassword: CustomTextFiled!
    @IBOutlet weak var googleBrn: UIButton!
    @IBOutlet weak var facebookBtn: FBSDKButton!
    @IBOutlet weak var googleIconImage: UIImageView!
    
    let storyBoard = UIStoryboard(name: "Auth", bundle: nil)
    var isSignup = false
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var api = Api()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextField()
        if AppSettings.showGoogleLogin == false{
            
            self.googleBrn.isHidden = true
            self.googleIconImage.isHidden = true
        }else {
            self.googleBrn.isHidden = false
             self.googleIconImage.isHidden = false
        }
        
        if AppSettings.showFacebookLogin == false {
            self.facebookBtn.isHidden = true
        }else {
            self.facebookBtn.isHidden = false
            self.facebookBtn.setTitle("Continue with Facebook", for: .normal)
            self.facebookBtn.titleLabel?.textAlignment = .center
            facebookBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
        }
      
//        UIView.appearance().semanticContentAttribute = .forceRightToLeft
    }
    
    func sucessLoginData() {
        
        let alert = validation.alert(str: "valid data and good user")
        self.present(alert, animated: true, completion: nil)
        print("user enter good data")
    }
    func setupTextField() {
        texEmail.txtField.keyboardType = .emailAddress
        texEmail.txtField.delegate = self
        textPassword.txtField.delegate = self
        textPassword.txtField.returnKeyType = .done
        textPassword.txtField.keyboardType = .asciiCapable
        texEmail.txtField.placeholderColor = UIColor(red: 68.0/255.0, green: 68.0/255.0, blue: 68.0/255.0, alpha: 1)
        textPassword.txtField.placeholderColor = UIColor(red: 68.0/255.0, green: 68.0/255.0, blue: 68.0/255.0, alpha: 1)
        
    }
    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func logInButtonAction(_ sender: Any) {
        let result = self.validateLogin()
        if(result.success == true) {
            if Reachability.isConnectedToNetwork(){
                self.showProgressDialog(text: "Loading...")
                let userName = self.texEmail.txtField.text ?? ""
                let password = self.textPassword.txtField.text ?? ""
                Async.background{
                    UserManager.instance.authenticateUser(UserName:userName, Password: password) { (Success, AuthError, error) in
                        if Success != nil{
                            Async.main{
                                log.verbose("Success = \(Success?.data!.message)")
                                self.view.makeToast(Success?.data!.message)
                                self.appDelegate?.loadingProfile()
                                self.dismissProgressDialog()
                                let storyBoard1 = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
                                let vc = storyBoard1.instantiateViewController(withIdentifier: "TabbarVC")as! TabbarVC
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        }else if AuthError != nil{
                            Async.main{
                                log.verbose("AuthError = \(AuthError?.errors!.errorText)")
                                self.view.makeToast(AuthError?.errors!.errorText)
                                self.dismissProgressDialog()
                            }
                        }else{
                            Async.main{
                                log.verbose("Error = \(error?.localizedDescription)")
                                self.dismissProgressDialog()
                                self.view.makeToast(error?.localizedDescription)
                            }
                        }
                    }
                }
                
            }else{
                self.view.makeToast(InterNetError)
            }
            
        }else{
            log.error("TextField Error")
        }
    }
    
    @IBAction func registerButtonAction(_ sender: Any) {
        let vc = self.storyBoard.instantiateViewController(withIdentifier: "RegisterVC")as! RegisterVC
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func ForgetPasswordButton(_ sender: Any) {
        let vc = self.storyBoard.instantiateViewController(withIdentifier: "ForgetPasswordVC")as! ForgetPasswordVC
        navigationController?.pushViewController(vc, animated: true)
        
    }
  
    @IBAction func googleSignInPressed(_ sender: Any) {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    @IBAction func facebookLoginPressed(_ sender: Any) {
     self.facebookLogin()
    }
    private func facebookLogin(){
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            
            if (error == nil){
                self.showProgressDialog(text: "Loading...")
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if (result?.isCancelled)!{
                    self.dismissProgressDialog()
                    return
                }
                if fbloginresult.grantedPermissions != nil {
                    if(fbloginresult.grantedPermissions.contains("email")) {
                        if((FBSDKAccessToken.current()) != nil){
                            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                                if (error == nil){
                                    let dict = result as! [String : AnyObject]
                                    log.debug("result = \(dict)")
                                    guard let firstName = dict["first_name"] as? String else {return}
                                    guard let lastName = dict["last_name"] as? String else {return}
                                    guard let email = dict["email"] as? String else {return}
                                    let accessToken = FBSDKAccessToken.current()?.tokenString
                                    Async.background({
                                        UserManager.instance.facebookLogin(Provider: "facebook", AccessToken: accessToken ?? "", completionBlock: { (success, sessionError, error) in
                                            if success != nil{
                                                Async.main({
                                                    
                                                    self.dismissProgressDialog()
                                                    log.debug(success?.data!.message)
                                                    self.appDelegate?.loadingProfile()
                                                    let storyBoard1 = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
                                                    let vc = storyBoard1.instantiateViewController(withIdentifier: "TabbarVC")as! TabbarVC
                                                    self.navigationController?.pushViewController(vc, animated: true)
                                                    
                                                })
                                            }else if sessionError != nil{
                                                Async.main({
                                                    self.dismissProgressDialog()
                                                    log.debug(sessionError?.errors!.errorText)
                                                    self.view.makeToast(sessionError?.errors!.errorText)
                                                })
                                            }else {
                                                Async.main({
                                                    self.dismissProgressDialog()
                                                    log.debug(error?.localizedDescription)
                                                    self.view.makeToast(error?.localizedDescription)
                                                })
                                            }
                                        })
                                    })
                                    log.verbose("FBSDKAccessToken.current() = \(FBSDKAccessToken.current()?.tokenString)")
                                    
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    private func googleLogin(access_Token:String){
      
        Async.background({
            
            UserManager.instance.googleLogin(Provider: "google", AccessToken: access_Token ?? "", GoogleApiKey: "AIzaSyA-JSf9CU1cdMpgzROCCUpl4wOve9S94ZU", completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog()
                        log.debug(success?.data!.message)
                        self.appDelegate?.loadingProfile()
                        let storyBoard1 = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
                        let vc = storyBoard1.instantiateViewController(withIdentifier: "TabbarVC")as! TabbarVC
                        self.navigationController?.pushViewController(vc, animated: true)
                        
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog()
                        log.debug(sessionError?.errors!.errorText)
                        self.view.makeToast(sessionError?.errors!.errorText)
                    })
                }else {
                    Async.main({
                        self.dismissProgressDialog()
                        log.debug(error?.localizedDescription)
                        self.view.makeToast(error?.localizedDescription)
                    })
                }
            })
        })

    }
      // MARK: - TEXT FIELD DELEGATE
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == texEmail.txtField) {
            textPassword.txtField.becomeFirstResponder()
        }
        else {
            self.view.endEditing(true)
        }
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        texEmail.txtField.errorMessage = nil
        textPassword.txtField.errorMessage = nil
    }
    
    // MARK: - VALIDATION
    
    func validateLogin()->(success:Bool,message:String) {
        resetTextFieldsErrors()
        if isSignup{
            if(textPassword.txtField.text?.isBlank)! || (texEmail.txtField.text?.isBlank)!  {
                if(texEmail.txtField.text?.isBlank)! {
                    texEmail.txtField.errorMessage = "please enter user name"
                }
                if(textPassword.txtField.text?.isBlank)! {
                    textPassword.txtField.errorMessage = "please enter Password"
                }
                
                return (false ,"please enter mandatory fields first")
            }
            
            return (true , "")
        }else{
            if(textPassword.txtField.text?.isBlank)! || (texEmail.txtField.text?.isBlank)!  {
                if(texEmail.txtField.text?.isBlank)! {
                    texEmail.txtField.errorMessage = "please enter user name"
                }
                if(textPassword.txtField.text?.isBlank)! {
                    textPassword.txtField.errorMessage = "please enter Password"
                }
                return (false , "please enter user name")
            }
            
            return (true , "")
        }
        
    }
    func resetTextFieldsErrors(){
        texEmail.txtField.errorMessage = ""
        textPassword.txtField.errorMessage = ""
        
    }
    
    
    
}
extension LoginVC:GIDSignInDelegate,GIDSignInUIDelegate{
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        
    }
    
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
                     withError error: Error!) {
        if (error == nil) {
            let userId = user.userID
            let idToken = user.authentication.accessToken  // Safe to send to
            log.verbose("user auth = \(user.authentication.accessToken)")
            let accessToken = user.authentication.accessToken ?? ""
            self.googleLogin(access_Token: accessToken)
        } else {
            log.error(error.localizedDescription)
            
        }
    }
}
