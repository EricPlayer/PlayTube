//
//  NotificationsVC.swift
//  Playtube
//


import UIKit
import Async
import SwiftIconFont
import PlaytubeSDK


class NotificationsVC: BaseViewController {
 
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showStack: UIStackView!
    
  
    private var userId:Int? = nil
    private var sessionId:String? = nil
    private var notificationsArray = [NotificationsModel.Notification]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = AppSettings.appColor
        self.tableView.separatorStyle = .none
        self.getUserSession()
        self.fetchData()

    }
    override func viewWillAppear(_ animated: Bool) {
        self.NavigationbarConfiguration()
        
        
    }
    override func viewWillDisappear(_ animated: Bool) {
//       self.tabBarController?.tabBar.isHidden = false
        
    }
    
    
    private func fetchData(){
    self.showProgressDialog(text: "Loading...")
        Async.background({
            NotificationsManager.instance.getNotifications(User_id: self.userId ?? 0, Session_Token: self.sessionId ?? "", completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        log.debug("Success")
                        if (success?.notifications!.isEmpty)!{
                             self.dismissProgressDialog()
                            self.tableView.isHidden = true
                            self.showStack.isHidden = false
                        }else{
                             self.dismissProgressDialog()
                            self.tableView.isHidden = false
                            self.showStack.isHidden = true
                            self.notificationsArray = (success?.notifications)!
                            
                            self.tableView.reloadData()
                        }
                    })
                }else if sessionError != nil{
                    Async.main({
                         self.dismissProgressDialog()
                        log.error("sessionError = \(sessionError?.errors!.errorText)")
                        self.dismissProgressDialog()
                        self.view.makeToast(sessionError?.errors!.errorText)
                    })
                }else{
                     self.dismissProgressDialog()
                    log.error("error = \(error?.localizedDescription)")
                    self.view.makeToast(error?.localizedDescription)
                }
            })
        })
        
    }
    func NavigationbarConfiguration(){
        self.navigationController?.isNavigationBarHidden = false
        self.title = "Notifications"
        let color = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color ]
        self.navigationController?.navigationBar.tintColor = color
    }
    private  func getUserSession(){
        log.verbose("getUserSession = \(UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session))")
        let localUserSessionData = UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session)
        self.userId = localUserSessionData[Local.USER_SESSION.user_id] as! Int
        self.sessionId = localUserSessionData[Local.USER_SESSION.session_id] as! String
    }
}
extension NotificationsVC:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Notifications_TableCell") as? Notifications_TableCell
        let notficationObject = self.notificationsArray[indexPath.row]
        let url = URL.init(string:notficationObject.userData!.avatar!)
       cell?.profileImage.sd_setImage(with: url , placeholderImage: UIImage(named: "maxresdefault"))
        cell?.userNameLabel.text = "\(notficationObject.userData!.firstName!) \(notficationObject.userData!.lastName!)"
        cell?.titleLabel.text = notficationObject.title!
        cell?.timeLabel.text = notficationObject.time!
      
        
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notificationObject = self.notificationsArray[indexPath.row]
        if (notificationObject.title?.contains("added"))! || (notificationObject.title?.contains("disliked"))! || (notificationObject.title?.contains("liked"))! || (notificationObject.title?.contains("commented"))! || (notificationObject.title?.contains("commented"))! {
            let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "PlayVideoVC") as! PlayVideoVC
            self.navigationController?.pushViewController(vc, animated: true)
        } else if (notificationObject.title?.contains("subscribed"))! || (notificationObject.title?.contains("unsubscribed"))!{
            log.verbose("true")
            let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "ChannelDetailsVC") as! ChannelDetailsVC
            vc.channelId = notificationObject.userData?.id
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else{
            log.verbose("false")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
}
