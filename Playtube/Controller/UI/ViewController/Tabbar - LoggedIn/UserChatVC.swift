//
//  UserChatVC.swift
//  Playtube
//
//  Created by Macbook Pro on 01/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import PlaytubeSDK
import DropDown
class UserChatVC: BaseViewController {
    
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let moreDropdown = DropDown()
    var recipentID:Int? = 0
    private var userId:Int? = nil
    private var sessionId:String? = nil
    private var userChatsObject:UserChatModel.DataClass?
    var timer:Timer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage(named: "ic_action_more"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(self.moreBtnPressed), for: UIControl.Event.touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 53, height: 51)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
        self.tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        self.sendBtn.layer.cornerRadius = self.sendBtn.frame.height / 2
        self.getUserSession()
        self.fetchUserChats()
        self.userChatDropDown(button: button)
        self.textViewPlaceHolder()
        
        
        timer = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        
    }
   
    override func viewWillAppear(_ animated: Bool) {
        self.NavigationbarConfiguration()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        timer?.invalidate()
    }
    @objc func moreBtnPressed() {
        moreDropdown.show()
    }

    @objc func update() {
        self.fetchUserChats()
    }
    
    @IBAction func sendPressed(_ sender: Any) {
        let randomNumber = Int(arc4random_uniform(UInt32(100000)))
        log.verbose("let diceRoll = Int(arc4random_uniform(UInt32(6))) = \(randomNumber)")
        let message = self.messageTextView.text
        
        Async.background({
            ChatManager.instance.sendUserMessage(User_id: self.userId ?? 0 , Session_Token: self.sessionId ?? "", Recipient_id: self.recipentID ?? 0, Hash_id: randomNumber, Text: message!, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        log.debug("success = \(success?.data?.text)")
                        if (self.userChatsObject?.messages?.isEmpty)!{
                            log.verbose("Show message ")
                        }else{
                             self.scrollToBottomOfChat()
                        }
                       
                        self.messageTextView.text = ""
                        
                    })
                    
                }else if sessionError != nil{
                    Async.main({
                         log.error("sessionError  = \(sessionError?.errors.errorText)")
                        self.view.makeToast(sessionError?.errors.errorText)
                    })
                    
                }else{
                    Async.main({
                        log.error("error = \(error?.localizedDescription)")
                        self.view.makeToast(error?.localizedDescription)
                    })
                }
            })
        })
        
    }
    private func fetchUserChats(){
        //        self.showProgressDialog(text: "Loading Chats....")
        Async.background({
            ChatManager.instance.getUserChats(User_id: self.userId ?? 0, Session_Token: self.sessionId ?? "", First_id: 0, Last_id: 0, Recipient_id: self.recipentID!, Limit: 0, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main{
                        self.userChatsObject?.messages?.removeAll()
                        self.userChatsObject = success?.data
                        self.dismissProgressDialog()
                        self.tableView.reloadData()
                        //                        self.scrollToBottomOfChat()
                        log.debug("success = \(self.userChatsObject)")
                        
                    }
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog()
                        log.error("sessionError = \(sessionError?.errors!.errorText)")
                        self.view.makeToast(sessionError?.errors!.errorText
                        )
                        
                    })
                    
                }else {
                    Async.main{
                        self.dismissProgressDialog()
                        log.error("sessionError = \(error?.localizedDescription)")
                        self.view.makeToast(error?.localizedDescription)
                    }
                }
            })
        })
        
    }
    private func timerFetchUserData(){
        //        self.showProgressDialog(text: "Loading Chats....")
        Async.background({
            ChatManager.instance.getUserChats(User_id: self.userId ?? 0, Session_Token: self.sessionId ?? "", First_id: 0, Last_id: 0, Recipient_id: self.recipentID!, Limit: 0, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main{
                        self.userChatsObject?.messages?.removeAll()
                        self.userChatsObject = success?.data
                        self.dismissProgressDialog()
                        self.tableView.reloadData()
                       
                        //                        self.scrollToBottomOfChat()
                        log.debug("success = \(self.userChatsObject)")
                        
                    }
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog()
                        log.error("sessionError = \(sessionError?.errors!.errorText)")
                        self.view.makeToast(sessionError?.errors!.errorText
                        )
                        
                    })
                    
                }else {
                    Async.main{
                        self.dismissProgressDialog()
                        log.error("sessionError = \(error?.localizedDescription)")
                        self.view.makeToast(error?.localizedDescription)
                    }
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
        self.title = userChatsObject?.userData!.firstName
        let color = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color ]
        self.navigationController?.navigationBar.tintColor = color
    }
    private  func scrollToBottomOfChat(){
        let indexPath = IndexPath(row: (userChatsObject?.messages!.count)! - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
    }
    private  func userChatDropDown(button:UIButton){
        moreDropdown.dataSource = ["Clear Chat"]
        moreDropdown.anchorView = button.superview
        moreDropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            if index == 0{
                self.showProgressDialog(text: "Loading...")
                Async.background({
                    ChatManager.instance.removeUserChats(User_id: self.userId ?? 0, Session_Token: self.sessionId ?? "", Recipient_id: self.recipentID ?? 0, completionBlock: { (success, sessionError, error) in
                        if success != nil{
                            Async.main({
                                self.view.makeToast(success?.message)
                                log.verbose("success = \(success?.message)")
                                self.dismissProgressDialog()
                            })
                            
                        }else if sessionError != nil{
                            Async.main({
                                self.view.makeToast(sessionError?.errors!.errorText)
                                log.verbose("sessionError = \(sessionError?.errors!.errorText)")
                                self.dismissProgressDialog()
                            })
                            
                        }else {
                            Async.main({
                                self.view.makeToast(error?.localizedDescription)
                                log.verbose("error = \(error?.localizedDescription)")
                                self.dismissProgressDialog()
                            })
                        }
                    })
                })
               
            }
            log.verbose("Selected item: \(item) at index: \(index)")
            
        }
        moreDropdown.bottomOffset = CGPoint(x: 312, y:-240)
        moreDropdown.width = 200
        moreDropdown.direction = .any
    }
    private func textViewPlaceHolder(){
        messageTextView.delegate = self
        messageTextView.text = "Your Message here..."
        messageTextView.textColor = UIColor.lightGray
    }
    
}

extension UserChatVC:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.userChatsObject?.messages!.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let messageObject = self.userChatsObject?.messages![indexPath.row]
        if messageObject?.position!.rawValue == "right"{
          
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserChat_TableCell2") as? UserChat_TableCell2
            cell?.messageLabel.text =  messageObject?.text
            cell?.timeLabel.text = messageObject?.textTime
            
            cell?.messageView?.sizeThatFits(CGSize(width: ((cell?.messageLabel.frame.width)!) + 10, height: (cell!.messageLabel.frame.height)))
            return cell!
            
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserChat_TableCell1") as? UserChat_TableCell1
            cell?.messageLabel.text =  messageObject?.text
            cell?.timeLabel.text = messageObject?.textTime
            
            cell?.messageView?.sizeThatFits(CGSize(width: ((cell?.messageLabel.frame.width)!) + 10, height: (cell!.messageLabel.frame.height)))
            return cell!
          
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
extension UserChatVC:UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Your message here..."
            textView.textColor = UIColor.lightGray
        }
    }
}
