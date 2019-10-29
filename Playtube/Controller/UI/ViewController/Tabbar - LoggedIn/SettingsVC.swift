//
//  SettingsVC.swift
//  Playtube


import UIKit
import PlaytubeSDK
import Async
class SettingsVC: UIViewController {
    
    @IBOutlet weak var languageView: UIView!
    
    var settingsEmail:String? = nil
    var isverifed:Int? = 0
    private var userId:Int? = nil
    private var sessionId:String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getUserSession()
          self.view.backgroundColor = AppSettings.appColor
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
      // This is not required
        languageView.addGestureRecognizer(tap)
        
        // Do any additional setup after loading the view.
    }
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        
        let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ChangeLanguageVC") as! ChangeLanguageVC
      self.present(vc, animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.NavigationbarConfiguration()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = false
    }
    
    
    @IBAction func monetizationPressed(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "MonetizationVC") as! MonetizationVC
        vc.email = settingsEmail ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func verificationPressed(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        if isverifed == 0{
            let vc = storyBoard.instantiateViewController(withIdentifier: "VerificationVC") as! VerificationVC
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            let vc = storyBoard.instantiateViewController(withIdentifier: "VerifiedVC") as! VerifiedVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
      
        
    }
    
    @IBAction func changePasswordBtnPressed(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ChangePasswordVC") as! ChangePasswordVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func enterMyChannelBtnPressed(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "EditMyChannelVC") as! EditMyChannelVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clearHistoryBtnPressed(_ sender: Any) {
        Async.background({
            MyChannelManager.instance.clearWatchHistory(User_id:self.userId ?? 0, Session_Token: self.sessionId ?? "", completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                       log.debug("success = \(success?.message)")
                        self.view.makeToast("Done!")
                        
                    })
                    
                }else if sessionError != nil{
                    Async.main({
                        log.error("sessionError = \(sessionError?.errors.errorText)")
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
    @IBAction func pauseWatchHistoryBtnPressed(_ sender: Any) {
        self.view.makeToast("Done!!")
    }
    @IBAction func clearCacheBtnPressed(_ sender: Any) {
        URLCache.shared.removeAllCachedResponses()
        self.view.makeToast("Cache Removed")
    }
    
    
    @IBAction func helpPressed(_ sender: Any) {
        let helpURL = URL(string: "")
        
        UIApplication.shared.openURL(helpURL!)
    }
    @IBAction func termsOfUsePressed(_ sender: Any) {
        let termOfUseURL = URL(string: "")
        
        UIApplication.shared.openURL(termOfUseURL!)
    }
    @IBAction func aboutUsPressed(_ sender: Any) {
        let aboutUsURL = URL(string: "")
        UIApplication.shared.openURL(aboutUsURL!)
    }
    @IBAction func deleteAccountPressed(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "DeleteAccountVC") as! DeleteAccountVC
      self.present(vc, animated: true, completion: nil)
        
    }
    @IBAction func logoutPressed(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "LogoutVC") as! LogoutVC
        self.present(vc, animated: true, completion: nil)
    }
    private  func getUserSession(){
        log.verbose("getUserSession = \(UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session))")
        let localUserSessionData = UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session)
        self.userId = localUserSessionData[Local.USER_SESSION.user_id] as! Int
        self.sessionId = localUserSessionData[Local.USER_SESSION.session_id] as! String
    }
   private func NavigationbarConfiguration(){
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = false
        self.title = "Settings"
        let color = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color ]
        self.navigationController?.navigationBar.tintColor = color
    }
    
}
