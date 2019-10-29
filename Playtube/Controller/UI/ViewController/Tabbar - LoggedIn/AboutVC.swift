//
//  AboutVC.swift
//  Playtube


import UIKit
import XLPagerTabStrip
import Async
import PlaytubeSDK

class AboutVC: UIViewController,IndicatorInfoProvider {
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var emailIcon: UIImageView!
    var channelId:Int? = 0
    var emailCheck:Bool? = false
    private var userId:Int? = nil
    private var sessionId:String? = nil
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = AppSettings.appColor
        log.verbose("About Channel Id = \(channelId)")
        self.getUserSession()
        if channelId == 0{
            self.showData()
        }else{
            self.otherChannelsFetchData()
        }
    }
    func showData(){
        if self.appDelegate?.myChannelInfo != nil{
            
            let myChannelInfo = self.appDelegate?.myChannelInfo
            if (myChannelInfo?.about!.isEmpty)!{
                self.aboutLabel.text = "Empty"
            }else{
               self.aboutLabel.text =  myChannelInfo?.about
            }
            
            self.emailLabel.text = myChannelInfo?.email
            self.genderLabel.text = myChannelInfo?.gender
        }
        else {
            log.error(InterNetError)
        }
    }
    private func otherChannelsFetchData(){
        Async.background({
            MyChannelManager.instance.getChannelInfo(User_id:self.userId ?? 0 , Session_Token: self.sessionId ?? "", Channel_id: self.channelId ?? 0, completionBlock: { (success, sessionError, error) in
                if success != nil {
                    Async.main({
                        log.verbose("success = \(success?.data!.username)")
//                        self.emailLabel.text = success?.data.email
                        self.emailIcon.isHidden = true
                        self.aboutLabel.text = success?.data!.about
                        self.genderLabel.text = success?.data!.gender
                    })
                }else if sessionError != nil{
                    Async.main({
                        log.verbose("sessionError = \(sessionError?.errors!.errorText)")
                    })
                    
                }else {
                    Async.main({
                        log.error("error = \(error?.localizedDescription)")
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
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "ABOUT")
        
    }
    
    @IBAction func googlePlusPressed(_ sender: Any) {
        let googlePlus = URL(string: "https://plus.google.com/people")
        
        UIApplication.shared.openURL(googlePlus!)
    }
    
    @IBAction func facebookPressed(_ sender: Any) {
        let facebook = URL(string: "https://www.facebook.com")
        
        UIApplication.shared.openURL(facebook!)
    }
    
    @IBAction func twitterPressed(_ sender: Any) {
        let twitter = URL(string: "https://twitter.com/login?lang=en")
        
        UIApplication.shared.openURL(twitter!)
    }
}
