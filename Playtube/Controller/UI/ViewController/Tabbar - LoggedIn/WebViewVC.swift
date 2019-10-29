//
//  WebViewVC.swift
//  Playtube
//
//  Created by Macbook Pro on 04/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import WebKit
import PlaytubeSDK
class WebViewVC: BaseViewController,WKNavigationDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    private var userId:Int? = nil
    private var sessionId:String? = nil
    var boolStatus:Bool? = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getUserSession()
         self.showProgressDialog(text: "Loading...")
        self.webView.navigationDelegate = self
        if boolStatus == false{
             webView.load(URLRequest(url: URL(string: API.baseURL + "/import-video-api&user_id=\(self.userId ?? 0)&cookie=\(self.sessionId ?? "")&mode=day")!))
        }else{
            webView.load(URLRequest(url: URL(string: API.baseURL + "/upload-api&user_id=\(self.userId ?? 0)&cookie=\(self.sessionId ?? "")&mode=day")!))
        }
       

    }
    override func viewWillAppear(_ animated: Bool) {
        self.NavigationbarConfiguration()
    }
    override func viewWillDisappear(_ animated: Bool) {
  self.tabBarController?.tabBar.isHidden = false
        
    }
    private  func getUserSession(){
        log.verbose("getUserSession = \(UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session))")
        let localUserSessionData = UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session)
        self.userId = localUserSessionData[Local.USER_SESSION.user_id] as! Int
        self.sessionId = localUserSessionData[Local.USER_SESSION.session_id] as! String
    }
    private func NavigationbarConfiguration(){
        self.tabBarController?.tabBar.isHidden = true
        if boolStatus == false{
            self.title = "Import Video"
        }else{
            self.title = "Upload Video"
        }
        
        let color = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color ]
        self.navigationController?.navigationBar.tintColor = color
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
     
         self.dismissProgressDialog()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.dismissProgressDialog()
    }
}
