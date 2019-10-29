//
//  ForgetPasswordVC.swift
//  Playtube


import UIKit
import Async
import PlaytubeSDK
class ForgetPasswordVC: BaseViewController {
    
    @IBOutlet weak var emailTextFieldTF: CustomTextFiled!
    
    var status = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func sendButton(_ sender: Any) {
        let result = self.validateForgotPassword()
        if(result.success == true) {
            if Reachability.isConnectedToNetwork(){
                self.showProgressDialog(text: "Loading...")
                let email = self.emailTextFieldTF.txtField.text ?? ""
                Async.background{
                    UserManager.instance.ForgetPassword(Email: email, completionBlock: { (Success, AuthError, error) in
                        if Success != nil{
                            Async.main{
                                log.verbose("Success = \(Success?.data!.message)")
                                self.view.makeToast(Success?.data!.message)
                                self.dismissProgressDialog()
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
                            }
                        }
                    })
                    
                }
                
            }else{
                self.view.makeToast(InterNetError)
            }
            
        }else{
            log.error("TextField Error")
        }
        
    }
}
extension ForgetPasswordVC:UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField == emailTextFieldTF.txtField) {
            emailTextFieldTF.txtField.becomeFirstResponder()
        }
        else {
            self.view.endEditing(true)
        }
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        emailTextFieldTF.txtField.errorMessage = nil
        
    }
    
    
    // MARK: - VALIDATION
    
    func validateForgotPassword()->(success:Bool,message:String) {
        resetTextFieldsErrors()
        if status{
            if (emailTextFieldTF.txtField.text?.isBlank)!  {
                if(emailTextFieldTF.txtField.text?.isBlank)! {
                    emailTextFieldTF.txtField.errorMessage = "please enter user name"
                }
                return (false ,"please enter mandatory fields first")
            }
            
            return (true , "")
        }else{
            if (emailTextFieldTF.txtField.text?.isBlank)!  {
                if(emailTextFieldTF.txtField.text?.isBlank)! {
                    emailTextFieldTF.txtField.errorMessage = "please enter user name"
                }
                return (false , "please enter user name")
            }
            
            return (true , "")
        }
        
    }
    func resetTextFieldsErrors(){
        emailTextFieldTF.txtField.errorMessage = ""
        
        
    }
    
}
