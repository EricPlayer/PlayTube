//
//  CreatePlaylistVC.swift
//  Playtube

import UIKit
import Async
import PlaytubeSDK

class CreatePlaylistVC: BaseViewController {
    
    @IBOutlet weak var privateRadioLabel: UIButton!
    @IBOutlet weak var playlistNameTextFieldTF: TJTextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var publicButtonLabel: UIButton!
    
    var playlistObject:PlaylistModel.MyAllPlaylist? = nil
    var status:Bool? = nil
    var listId:String? = nil
    private var userId:Int? = nil
    private var sessionId:String? = nil
    private var privacyCount:Int? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = AppSettings.appColor
        self.setupUI()
        self.privacyCount = 0
        self.getUserSession()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.NavigationbarConfiguration()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func radioButton(_ sender: UIButton) {
        if sender.tag == 0{
            self.privateRadioLabel.setImage(UIImage(named: "radio_button_on"), for: .normal)
            self.publicButtonLabel.setImage(UIImage(named: "radio_button_off"), for: .normal)
            self.privacyCount = 0
        }else{
            self.publicButtonLabel.setImage(UIImage(named: "radio_button_on"), for: .normal)
            self.privateRadioLabel.setImage(UIImage(named: "radio_button_off"), for: .normal)
            self.privacyCount = 1
        }
    }
    private func NavigationbarConfiguration(){
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = false
        self.title = "Create PlayList"
        let color = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color ]
        self.navigationController?.navigationBar.tintColor = color
        let Save = UIBarButtonItem(title: "Save", style: .done, target: self, action: Selector("Save"))
        self.navigationItem.rightBarButtonItem = Save
    }
    
    
    @objc func Save(){
       
        if (self.playlistNameTextFieldTF.text?.isEmpty)!{
            self.view.makeToast("Please enter playlist name")
        }else if self.descriptionTextView.text.isEmpty{
            self.view.makeToast("Please enter playlist description")
        } else {
            
            let playlistName = self.playlistNameTextFieldTF.text
            let playlistDescription = self.descriptionTextView.text
             self.showProgressDialog(text: "Loading...")
            if Reachability.isConnectedToNetwork(){
                if self.status!{
                    Async.background({
                        PlaylistManager.instance.updatePlaylist(User_id: self.userId!, Session_Token: self.sessionId!, List_id: self.listId!, Name: playlistName!, Description: playlistDescription!, Privacy: self.privacyCount!, completionBlock: { (success, sessionError, error) in
                            if success != nil{
                                Async.main({
                                    self.view.makeToast(success?.message)
                                    self.dismissProgressDialog()
                                })
                            }else if sessionError != nil{
                                Async.main({
                                    self.dismissProgressDialog()
                                    self.view.makeToast(sessionError?.errors!.errorText)
                                    log.error("sessionError = \(sessionError?.errors!.errorText)")
                                })
                            }else{
                                Async.main({
                                    self.dismissProgressDialog()
                                    self.view.makeToast(error?.localizedDescription)
                                    log.error("error = \(error?.localizedDescription)")
                                })
                            }
                        })
                    })
                    
                }else{
                    Async.background({
                        PlaylistManager.instance.addPlaylist(User_id: self.userId!, Session_Token: self.sessionId!, Name: playlistName!, Description: playlistDescription!, Privacy: self.privacyCount!, completionBlock: { (success, sessionError, error) in
                            if success != nil{
                                Async.main({
                                    self.view.makeToast("Playlist Created successfully!!")
                                    self.dismissProgressDialog()
                                })
                            }else if sessionError != nil{
                                Async.main({
                                    self.dismissProgressDialog()
                                    self.view.makeToast(sessionError?.errors!.errorText)
                                    log.error("sessionError = \(sessionError?.errors!.errorText)")
                                })
                            }else{
                                Async.main({
                                    self.dismissProgressDialog()
                                    self.view.makeToast(error?.localizedDescription)
                                    log.error("error = \(error?.localizedDescription)")
                                })
                            }
                        })
                    })
                    
                }
            }else{
                self.view.makeToast(InterNetError)
            }
        }
        
    }
    private func setupUI(){
        if self.status!{
self.playlistNameTextFieldTF.text = self.playlistObject?.name
        self.descriptionTextView.text = self.playlistObject?.description
            if self.playlistObject?.privacy == 0{
                self.privacyCount = 0
                self.privateRadioLabel.setImage(UIImage(named: "radio_button_on"), for: .normal)
                self.publicButtonLabel.setImage(UIImage(named: "radio_button_off"), for: .normal)
            }else {
                self.publicButtonLabel.setImage(UIImage(named: "radio_button_on"), for: .normal)
                self.privateRadioLabel.setImage(UIImage(named: "radio_button_off"), for: .normal)
                self.privacyCount = 1
                
            }
        }else {
           self.textViewPlaceHolder()
        }
    }
    private  func getUserSession(){
        log.verbose("getUserSession = \(UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session))")
        let localUserSessionData = UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session)
        self.userId = localUserSessionData[Local.USER_SESSION.user_id] as! Int
        self.sessionId = localUserSessionData[Local.USER_SESSION.session_id] as! String
    }
    private func textViewPlaceHolder(){
        descriptionTextView.delegate = self
        descriptionTextView.text = "Placeholder"
        descriptionTextView.textColor = UIColor.lightGray
    }
}
extension CreatePlaylistVC:UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Playlist Description"
            textView.textColor = UIColor.lightGray
        }
    }
}
