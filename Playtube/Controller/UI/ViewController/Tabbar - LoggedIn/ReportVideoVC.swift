//
//  ReportVideoVC.swift
//  Playtube
//


import UIKit
import Async
import PlaytubeSDK

class ReportVideoVC: BaseViewController
{
    @IBOutlet weak var reportTextField: TJTextField!
    private var userId:Int? = nil
    private var sessionId:String? = nil
    var videoId:Int? = nil
    var videoObject:UserDefaultModel.Datum? = nil
    var videoObjectTop:Home.Featured? = nil
    var videoObjectLatest:Home.Featured? = nil
    var searchVideoObject:SearchModel.Datum? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = AppSettings.appColor
        self.getUserSession()
        log.verbose("video Id = \(self.videoId)")
        
    }
    
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func submitButton(_ sender: Any) {
        if Reachability.isConnectedToNetwork(){
            self.showProgressDialog(text: "Loading...")
            let text = self.reportTextField.text!
            Async.background({
                ReportManager.instance.reportVideo(User_id: self.userId!, Session_Token: self.sessionId!, id: self.videoId!, text: text, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.dismissProgressDialog()
                            self.view.makeToast(success?.message)
                            self.dismiss(animated: true, completion: nil)
        
                        })
                    }else if sessionError != nil{
                        
                    self.dismiss(animated: true, completion: nil)
                        self.view.makeToast(sessionError?.errors!.errorText)
                    }else{
                        self.dismissProgressDialog()
                       self.view.makeToast(error?.localizedDescription)
                    }
                })
            })
        } else{
            self.view.makeToast(InterNetError)
        }

    }
    private func getUserSession(){
        log.verbose("getUserSession = \(UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session))")
        let localUserSessionData = UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session)
        self.userId = localUserSessionData[Local.USER_SESSION.user_id] as! Int
        self.sessionId = localUserSessionData[Local.USER_SESSION.session_id] as! String
    }
    
}
