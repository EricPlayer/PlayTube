//
//  ChannelDetailsVC.swift
//  Playtube


import UIKit
import XLPagerTabStrip
import Async
import PlaytubeSDK

class ChannelDetailsVC: ButtonBarPagerTabStripViewController {
    
    @IBOutlet weak var checkImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var subscribeBtn: UIButton!
    
    @IBOutlet weak var chatBtn: UIButton!
    var channelId:Int? = 0
    private var sessionStatus:Bool? = nil
    private var userId:Int? = nil
    private var sessionId:String? = nil
    private var appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    override func viewDidLoad() {
        
        self.SetupPagerTab()
        super.viewDidLoad()
          self.view.backgroundColor = AppSettings.appColor
        self.sessionStatus = UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session).isEmpty
        if sessionStatus!{
            self.fetchData()
        }else{
            self.getUserSession()
            self.fetchData()
        }
        log.verbose("Channel id = \(channelId ?? 0)")
    }
    @IBAction func chatPressed(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "UserChatVC") as! UserChatVC
        vc.recipentID = channelId!
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func subscribePressed(_ sender: Any) {
         let storyboard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        if sessionStatus!{
            let vc = storyboard.instantiateViewController(withIdentifier: "ShowLoginPopVC") as! ShowLoginPopVC
            self.present(vc, animated: true, completion: nil)
        }else{
            if Reachability.isConnectedToNetwork(){
                Async.background({
                    PlayVideoManager.instance.subUnsubChannel(User_id: self.userId ?? 0, Session_Token: self.sessionId ?? "", Channel_Id: self.channelId ?? 0) { (success, sessionError, error) in
                        if success != nil{
                            Async.main({
                                log.verbose("success \(success?.code) ")
                                
                                if success?.code == 0 {
                                    self.view.makeToast("Channel unsubscribe")
                                    self.subscribeBtn.setTitle("Subscribe", for: .normal)
                                    self.checkImage.image = UIImage(named: "add")
                                    self.subscribeBtn.setTitleColor(.black, for: .normal)
                                }else{
                                    self.view.makeToast("Channel subscribed")
                                    self.subscribeBtn.setTitle("Subscribed", for: .normal)
                                    self.checkImage.image = UIImage(named: "ic_action_check_mark")
                                    self.subscribeBtn.setTitleColor(.white, for: .normal)
                                }
                                
                            })
                            
                        }else if sessionError != nil{
                            log.verbose("sessionError = \(sessionError?.errors!.errorText)")
                            
                            self.view.makeToast(sessionError?.errors!.errorText)
                        }else{
                            log.verbose("error = \(error?.localizedDescription)")
                            
                        }
                        
                    }
                })
                
            }else{
                self.view.makeToast(InterNetError)
            }
        }
       
        
    }
    
    private func fetchData(){
        Async.background({
            MyChannelManager.instance.getChannelInfo(User_id:self.userId ?? 0 , Session_Token: self.sessionId ?? "", Channel_id: self.channelId ?? 0, completionBlock: { (success, sessionError, error) in
                if success != nil {
                    Async.main({
                        log.verbose("success = \(success?.data!.username)")
                        if let avatar = URL.init(string:(success?.data!.avatar)!){
                            self.avatarImage.sd_setImage(with: avatar , placeholderImage: UIImage(named: "maxresdefault"))
                        }
                        if let cover = URL.init(string:(success?.data!.cover)!){
                            self.coverImage.sd_setImage(with: cover , placeholderImage: UIImage(named: "maxresdefault"))
                        }
                        self.userNameLabel.text = success?.data!.username
                        if success?.data!.isSubscribedToChannel == 0{
                            self.subscribeBtn.setTitle("Subscribe", for: .normal)
                            self.checkImage.image = UIImage(named: "add")
                            self.subscribeBtn.setTitleColor(.black, for: .normal)
                        }else{
                            self.subscribeBtn.setTitle("Subscribed", for: .normal)
                            self.checkImage.image = UIImage(named: "ic_action_check_mark")
                            self.subscribeBtn.setTitleColor(.white, for: .normal)
                            
                        }
                        if self.appDelegate?.myChannelInfo?.username == success?.data?.username{
                            self.chatBtn.isHidden = true
                            self.subscribeBtn.isHidden = true
                            self.checkImage.isHidden = true
                            
                        }else{
                            self.chatBtn.isHidden = false
                            self.subscribeBtn.isHidden = false
                            self.checkImage.isHidden = false
                        }
                        
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
    func SetupPagerTab(){
        let barColor = UIColor(red:76/255, green: 165/255, blue: 255/255, alpha: 1)
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = barColor
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 15)
        settings.style.selectedBarHeight = 3
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .blue
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        let color = UIColor(red:255/255, green: 255/255, blue: 255/255, alpha: 0.75)
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = color
            newCell?.label.textColor = .white
            print("OldCell",oldCell)
            print("NewCell",newCell)
        }
    }
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        let videosVC = storyBoard.instantiateViewController(withIdentifier: "VideosVC") as! VideosVC
        videosVC.channelId = self.channelId
        let playlistVC = storyBoard.instantiateViewController(withIdentifier: "PlaylistVC") as! PlaylistVC
        playlistVC.channelId = self.channelId
        let aboutVC = storyBoard.instantiateViewController(withIdentifier: "AboutVC") as! AboutVC
         aboutVC.channelId = self.channelId
        return [videosVC,playlistVC,aboutVC]
        
    }
}
