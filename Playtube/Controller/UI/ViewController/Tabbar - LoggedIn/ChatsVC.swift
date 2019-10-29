//
//  ChatsVC.swift
//  Playtube
//
//  Created by Macbook Pro on 30/03/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import PlaytubeSDK
import Async
class ChatsVC: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    private var userId:Int? = nil
    private var sessionId:String? = nil
    private var chatArray = [ChatModel.Datum]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getUserSession()
        self.fetchChats()
        self.tableView.separatorStyle = .none

    }
    override func viewWillAppear(_ animated: Bool) {
         NavigationbarConfiguration()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    private func fetchChats(){
        self.showProgressDialog(text: "Loading...")
    Async.background({
        ChatManager.instance.getChats(User_id: self.userId ?? 0, Session_Token: self.sessionId ?? "", completionBlock: { (success, sessionError, error) in
            if success != nil{
                Async.main({
                    self.chatArray = (success?.data)!
                    self.tableView.reloadData()
                    self.dismissProgressDialog()
                    
                })
            }else if sessionError != nil{
                Async.main({
                    log.error("sessionError = \(sessionError?.errors!.errorText)")
                    self.view.makeToast(sessionError?.errors!.errorText)
                     self.dismissProgressDialog()
                    
                })
            }else{
                Async.main({
                    log.error("error = \(error?.localizedDescription)")
                    self.view.makeToast(error?.localizedDescription)
                     self.dismissProgressDialog()
                })
            }
           
        })
    })
    
    }
    
    private  func getUserSession(){
        log.verbose("getUserSession = \(UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session))")
        let localUserSessionData = UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session)
        self.userId = localUserSessionData[Local.USER_SESSION.user_id] as! Int
        self.sessionId = localUserSessionData[Local.USER_SESSION.session_id] as! String
    }
   private func NavigationbarConfiguration(){
         self.tabBarController?.tabBar.isHidden = true
        self.title = "Chats"
        let color = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color ]
        self.navigationController?.navigationBar.tintColor = color
    }

}
extension ChatsVC:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Chats_TableCell") as? Chats_TableCell
        let chatObject = self.chatArray[indexPath.row]
        let profileImageURL = URL.init(string:chatObject.user!.avatar ?? "")
        cell?.profileImage.sd_setImage(with: profileImageURL , placeholderImage: UIImage(named: "maxresdefault"))
        cell?.profileImage.layer.cornerRadius = (cell?.profileImage.frame.height)! / 2
        if (chatObject.user!.firstName?.isEmpty)! && (chatObject.user!.lastName?.isEmpty)!{
             cell?.usernameLabel.text = chatObject.user!.username ?? ""
        }else{
            cell?.usernameLabel.text = chatObject.user!.firstName ?? "" + chatObject.user!.lastName!
        }
      
        log.verbose("names = \( chatObject.user!.firstName ?? "" + chatObject.user!.lastName!)")
        cell?.messageLabel.text = chatObject.getLastMessage!.text ?? ""
        cell?.timeLabel.text = chatObject.getLastMessage!.textTime ?? ""
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110.0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "UserChatVC") as! UserChatVC
        vc.recipentID = self.chatArray[indexPath.row].user?.id
        self.navigationController?.pushViewController(vc, animated: true)
  
    }
}


