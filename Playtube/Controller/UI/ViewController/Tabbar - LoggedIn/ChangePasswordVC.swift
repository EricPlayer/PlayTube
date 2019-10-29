//
//  ChangePasswordVC.swift
//  Playtube


import UIKit
import Async
import PlaytubeSDK

class ChangePasswordVC: BaseViewController {
    
    @IBOutlet weak var repeatPasswordTF: TJTextField!
    @IBOutlet weak var newPasswordTF: TJTextField!
    @IBOutlet weak var currentPasswordTF: TJTextField!
    
    private var userId:Int? = nil
    private var sessionId:String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = AppSettings.appColor
        self.getUserSession()
        let SaveBtn = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(logoutUser))
        self.navigationItem.rightBarButtonItem  = SaveBtn
     
        // Do any additional setup after loading the view.
    }
    @objc func logoutUser(){
        if (self.currentPasswordTF.text?.isEmpty)!{
            self.view.makeToast("Please enter current password.")
            
        }else if (newPasswordTF.text?.isEmpty)!{
             self.view.makeToast("Please enter new password.")
            
        }else if (repeatPasswordTF.text?.isEmpty)!{
             self.view.makeToast("Please enter repeat password.")
        }else{
            self.showProgressDialog(text: "Loading...")
            let currentPass = self.currentPasswordTF.text ?? ""
            let newPass = self.newPasswordTF.text ?? ""
            let repeatPass = self.repeatPasswordTF.text  ?? ""
            Async.background({
                MyChannelManager.instance.changePassword(User_id: self.userId ?? 0, Session_Token: self.sessionId!, CurrentPassword:currentPass , NewPassword: newPass, RepeatPassword: repeatPass, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog()
                            log.debug("success = \(success?.message)")
                            self.view.makeToast(success?.message)
                            
                        })
                    }else if sessionError != nil {
                        Async.main({
                            self.dismissProgressDialog()
                            log.error("error = \(sessionError?.errors!.errorText)")
                            self.view.makeToast(sessionError?.errors!.errorText)
                        })
                        
                    }else {
                        Async.main({
                            log.error("error = \(error?.localizedDescription)")
                            self.dismissProgressDialog()
                            self.view.makeToast(error?.localizedDescription)
                        })
                    }
                })
            })
        }
      
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.NavigationbarConfiguration()
    }
    override func viewWillDisappear(_ animated: Bool) {
      self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func savePressed(_ sender: Any) {
       
    }
    
    
    private  func getUserSession(){
        log.verbose("getUserSession = \(UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session))")
        let localUserSessionData = UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session)
        self.userId = localUserSessionData[Local.USER_SESSION.user_id] as! Int
        self.sessionId = localUserSessionData[Local.USER_SESSION.session_id] as! String
    }
    private func NavigationbarConfiguration(){
        self.tabBarController?.tabBar.isHidden = true
        self.title = "Change Password"
        let color = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color ]
        self.navigationController?.navigationBar.tintColor = color
    }
    
}
