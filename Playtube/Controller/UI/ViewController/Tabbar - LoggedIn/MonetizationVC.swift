//
//  MonetizationVC.swift
//  Playtube
//
//  Created by Macbook Pro on 05/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import PlaytubeSDK
import Async
class MonetizationVC: BaseViewController {
    
    @IBOutlet weak var amountText: UITextField!
    @IBOutlet weak var amountLabel: UILabel!
    let appdelegate = UIApplication.shared.delegate as? AppDelegate
    
    var email:String? = ""
    private var userId:Int? = nil
    private var sessionId:String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func viewWillAppear(_ animated: Bool) {
        self.showData()
        self.NavigationbarConfiguration()
        let sendBtn = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(sendPressed))
        self.navigationItem.rightBarButtonItem  = sendBtn
    }
    @objc func sendPressed(){
        let amountValue = self.amountText.text?.toInt(defaultValue: 0)
        log.verbose("Ammount value = \(amountValue)")
        if amountValue ?? 0 >= 50{
            self.showProgressDialog(text: "Loading...")
            Async.background({
                MonetizationManager.instance.monetizeUser(User_id: self.userId ?? 0, Session_Token: self.sessionId ?? "" , Email:self.email ?? "" , Ammount: Int(amountValue ?? 0), completionBlock: { (success, sessionError, error) in
                    if success != nil{
                      Async.main({
                        log.debug("success = \(success?.message)")
                        self.view.makeToast(success?.message)
                        self.dismissProgressDialog()
                      })
                    }else if sessionError != nil{
                        Async.main({
                            log.error("sessionError = \(sessionError?.errors.errorText)")
                            self.view.makeToast(sessionError?.errors.errorText)
                            self.dismissProgressDialog()
                        })
                        
                    }else {
                        
                        Async.main({
                            log.error("error = \(error?.localizedDescription)")
                            self.view.makeToast(error?.localizedDescription)
                            self.dismissProgressDialog()
                            
                        })
                    }
                })
            })
        }else if amountValue == nil {
            self.view.makeToast("Please enter amount.")
        }
        else{
            self.view.makeToast("Amount shouldn't be less than 50.")
        }
    }
    private func showData(){
        let amountValue = appdelegate?.myChannelInfo?.balance
        self.amountLabel.text =  "$" + (amountValue?.floatValue.clean)!
    }
    private  func getUserSession(){
        log.verbose("getUserSession = \(UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session))")
        let localUserSessionData = UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session)
        self.userId = localUserSessionData[Local.USER_SESSION.user_id] as! Int
        self.sessionId = localUserSessionData[Local.USER_SESSION.session_id] as! String
    }
    private func NavigationbarConfiguration(){
        self.tabBarController?.tabBar.isHidden = true
        self.title = "Monetization"
        let color = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color ]
        self.navigationController?.navigationBar.tintColor = color
    }

}
