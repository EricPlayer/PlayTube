//
//  DeleteAccountVC.swift
//  Playtube


import UIKit
import PlaytubeSDK
import Async

class DeleteAccountVC: BaseViewController {
    
    private var userId:Int? = nil
    private var sessionId:String? = nil
    private let appDelegate = UIApplication.shared.delegate as? AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
   
    }
    

    @IBAction func okPressed(_ sender: Any) {
        Async.background({
            UserManager.instance.deleteUser(User_id: self.userId ?? 0, Session_Token: self.sessionId ?? "") { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        self.dismissProgressDialog()
                        log.verbose("success = \(success!.message)")
                        UserDefaults.standard.clearUserDefaults()
                        let storyBoard = UIStoryboard(name: "Auth", bundle: nil)
                        let vc = storyBoard.instantiateViewController(withIdentifier: "Login")
                        self.appDelegate!.window?.rootViewController = vc
                        
                    })
                }else if sessionError != nil{
                    
                    Async.main{
                        log.verbose("sessionError = \(sessionError?.errors!.errorText)")
                        self.dismissProgressDialog()
                        self.view.makeToast(sessionError?.errors!.errorText)
                    }
                }else {
                    Async.main({
                        self.dismissProgressDialog()
                        self.view.makeToast(error?.localizedDescription)
                        log.error("error = \(error?.localizedDescription)")
                    })
                }
            }
        })
      
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    private  func getUserSession(){
        log.verbose("getUserSession = \(UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session))")
        let localUserSessionData = UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session)
        self.userId = localUserSessionData[Local.USER_SESSION.user_id] as! Int
        self.sessionId = localUserSessionData[Local.USER_SESSION.session_id] as! String
    }
}
