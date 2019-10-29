//
//  DeletePlayList.swift
//  Playtube


import UIKit
import Async
import PlaytubeSDK

class DeletePlayList: BaseViewController {
    
    var listid:String? = nil
    private var userId:Int? = nil
    private var sessionId:String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

self.getUserSession()
        
    }
    @IBAction func okPressed(_ sender: Any) {
        if Reachability.isConnectedToNetwork(){
            self.showProgressDialog(text: "Loading...")
            Async.background({
                PlaylistManager.instance.deletePlaylist(User_id: self.userId!, Session_Token: self.sessionId!, List_id: self.listid ?? "", completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.view.makeToast(success?.message)
                            self.dismissProgressDialog()
                             self.dismiss(animated: true, completion: nil)
                        })
                    }else if sessionError != nil{
                        Async.main({
                            self.dismissProgressDialog()
                            self.view.makeToast(sessionError?.errors!.errorText)
                            log.error("sessionError = \(sessionError?.errors!.errorText)")
                             self.dismiss(animated: true, completion: nil)
                        })
                    }else{
                        Async.main({
                            self.dismissProgressDialog()
                            self.view.makeToast(error?.localizedDescription)
                            log.error("error = \(error?.localizedDescription)")
                             self.dismiss(animated: true, completion: nil)
                        })
                    }
                })
            })

        }else{
            self.view.makeToast(InterNetError)
        }
       
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
