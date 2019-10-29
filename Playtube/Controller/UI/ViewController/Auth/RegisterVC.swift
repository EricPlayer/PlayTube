//
//  RegisterVC.swift
//  Playtube

import UIKit
import Async
import PlaytubeSDK
class RegisterVC:BaseViewController, UITextFieldDelegate{
    @IBOutlet weak var checkBoxButton: UIButton!
    @IBOutlet weak var userName: CustomTextFiled!
    @IBOutlet weak var userEmail: CustomTextFiled!
    @IBOutlet weak var passwird: CustomTextFiled!
    @IBOutlet weak var confirmPassword: CustomTextFiled!
    
    var agree:Bool? = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextField()
    }
    
    func setupTextField() {
        
        confirmPassword.txtField.keyboardType = .default
        confirmPassword.txtField.delegate = self
        confirmPassword.txtField.placeholderColor = UIColor(red: 68.0/255.0, green: 68.0/255.0, blue: 68.0/255.0, alpha: 1)
        userName.txtField.delegate = self
        userName.txtField.placeholderColor = UIColor(red: 68.0/255.0, green: 68.0/255.0, blue: 68.0/255.0, alpha: 1)
        userName.txtField.keyboardType = .default
        userEmail.txtField.keyboardType = .emailAddress
        userEmail.txtField.delegate = self
        userEmail.txtField.placeholderColor = UIColor(red: 68.0/255.0, green: 68.0/255.0, blue: 68.0/255.0, alpha: 1)
        passwird.txtField.delegate = self
        passwird.txtField.returnKeyType = .next
        passwird.txtField.keyboardType = .default
        passwird.txtField.placeholderColor = UIColor(red: 68.0/255.0, green: 68.0/255.0, blue: 68.0/255.0, alpha: 1)
        
    }
    
    
    @IBAction func privacyPolicyPressed(_ sender: Any) {
        let aboutUsURL = URL(string: "https://playtubescript.com/terms/privacy-policy")
        UIApplication.shared.openURL(aboutUsURL!)
    }
    @IBAction func termOfPloicyPressed(_ sender: Any) {
        let aboutUsURL = URL(string: "https://playtubescript.com/terms/terms")
        UIApplication.shared.openURL(aboutUsURL!)
    }
    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func registerButton(_ sender: Any) {
        let result = self.validtRegiser()
        if(result.success == true) {
            if Reachability.isConnectedToNetwork(){
                if agree!{
                    self.showProgressDialog(text: "Loading...")
                    let userName = self.userName.txtField.text ?? ""
                    let email = self.userEmail.txtField.text ?? ""
                    let password = self.passwird.txtField.text ?? ""
                    let confirmPassword = self.confirmPassword.txtField.text ?? ""
                    Async.background{
                        UserManager.instance.RegisterUser(Email: email , UserName: userName, Password:password , ConfirmPassword: confirmPassword) { (Success,EmailSuccess, AuthError, error)  in
                            if Success != nil{
                                Async.main{
                                    log.verbose("Success = \(Success?.message)")
                                    self.dismissProgressDialog()
                                    let storyBoard1 = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
                                    let vc = storyBoard1.instantiateViewController(withIdentifier: "TabbarVC")as! TabbarVC
                                    self.navigationController?.pushViewController(vc, animated: true)
                                    
                                }
                            }else if EmailSuccess != nil{
                                
                                Async.main({
                                    log.verbose("EmailSuccess = \(EmailSuccess?.message)")
                                    self.dismissProgressDialog()
                                    let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
                                    let vc = storyBoard.instantiateViewController(withIdentifier: "emailVerificaionVC")as! emailVerificaionVC
                                   self.present(vc, animated: true, completion: nil)
                                })
                            } else if AuthError != nil{
                                Async.main{
                                    log.verbose("AuthError = \(AuthError?.errors!.errorText)")
                                    self.dismissProgressDialog()
                                }
                            }else{
                                Async.main{
                                    log.verbose("Error = \(error?.localizedDescription)")
                                    self.dismissProgressDialog()
                                }
                            }
                        }
                    }
                    
                }else{
                      self.view.makeToast("Please select the Terms & Conditions.")
                    
                }
                
            }else{
                 self.view.makeToast(InterNetError)
                
            }
        }else{
         log.error("TextField Error")
        }
                
    }
    @IBAction func checkBoxButtonAction(_ sender: Any) {
        if agree! {
            checkBoxButton.setImage(UIImage(named: "unCheckBox"), for: .normal)
            agree = false
        }else{
            checkBoxButton.setImage(UIImage(named: "checkBox"), for: .normal)
            agree = true
        }
    }
    
    // MARK: - TEXT FIELD DELEGATE
    func textFieldDidBeginEditing(_ textField: UITextField) {
        userEmail.txtField.errorMessage = ""
        userName.txtField.errorMessage = ""
        passwird.txtField.errorMessage = ""
        confirmPassword.txtField.errorMessage = ""
    }
    
    
    // MARK: - VALIDATION
    var isSignup = false
    func validtRegiser()->(success:Bool,message:String) {
        resetTextFieldsErrors()
        if !isSignup{
            if(passwird.txtField.text?.isBlank)! || (confirmPassword.txtField.text?.isBlank)! || (userName.txtField.text?.isBlank)! || (userEmail.txtField.text?.isBlank)!  {
                if(userName.txtField.text?.isBlank)! {
                    userName.txtField.errorMessage = "please enter user name"
                }
                if(userEmail.txtField.text?.isBlank)! {
                    userEmail.txtField.errorMessage = "please enter Email"
                }
                if(passwird.txtField.text?.isBlank)! {
                    passwird.txtField.errorMessage = "please enter Password"
                }
                if(confirmPassword.txtField.text?.isBlank)!{
                    confirmPassword.txtField.errorMessage = "please confirme your password"
                }
                return (false ,"please enter mandatory fields first")
            }else if ((userName.txtField.text?.count)! < 5) || ((userName.txtField.text?.count)! > 32){
                userName.txtField.errorMessage = "name must be between 5 to 32 characters"
                return (false ,"")
            }else if(userEmail.txtField.text?.isEmail == false) {
                userEmail.txtField.errorMessage = "please enter valid email address"
                return (false , "please enter valid email address")
            }else if passwird.txtField.text! !=  confirmPassword.txtField.text! {
                confirmPassword.txtField.errorMessage = "the password is not matches!"
                return (false , "please match password")
            }else if passwird.txtField.text!.count < 8 {
                passwird.txtField.errorMessage = "password must up to 8 character"
                confirmPassword.txtField.errorMessage = "password must up to 8 character"
                return (false , "too short password")
            } 
        }
        return (true , "")
    }
    func resetTextFieldsErrors(){
        userEmail.txtField.errorMessage = ""
        userName.txtField.errorMessage = ""
        passwird.txtField.errorMessage = ""
        confirmPassword.txtField.errorMessage = ""
    }
    
    
}
