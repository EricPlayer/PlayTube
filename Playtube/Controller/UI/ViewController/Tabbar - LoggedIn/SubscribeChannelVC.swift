//
//  SubscribeChannelVC.swift
//  Playtube


import UIKit
import Async
import PlaytubeSDK

class SubscribeChannelVC: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var ChannelsArray = [SubscriptionModel.Datum]()
    private var userId:Int? = nil
    private var sessionId:String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
          self.view.backgroundColor = AppSettings.appColor
        self.tableView.separatorStyle = .none
        self.getUserSession()

    }
    override func viewWillAppear(_ animated: Bool) {
        self.NavigationbarConfiguration()
    }
    private func NavigationbarConfiguration(){        self.navigationController?.isNavigationBarHidden = false
        self.title = "All channels"
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

extension SubscribeChannelVC:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ChannelsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubscribeChannel_TableCell") as? SubscribeChannel_TableCell
        cell?.delegate = self
      
        let subscribedChannelObject = self.ChannelsArray[indexPath.row]
          cell?.id = subscribedChannelObject.id
        cell?.profileImage.downloaded(from: subscribedChannelObject.avatar!)
        cell?.profileImage.cornerRadiusV = (cell?.profileImage.frame.height)! / 2
        cell?.subscribeBtn.cornerRadiusV = (cell?.subscribeBtn.frame.height)! / 2
        cell?.usernameLabel.text = subscribedChannelObject.username!.htmlAttributedString
        if subscribedChannelObject.verified == 1{
            cell?.isVerified.isHidden = false
        }else{
            cell?.isVerified.isHidden = true
        }
        cell?.subscribeBtn.backgroundColor = UIColor(hexFromString: "0096FF", alpha: 1)

        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ChannelDetailsVC") as! ChannelDetailsVC
        vc.channelId = self.ChannelsArray[indexPath.row].id
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension SubscribeChannelVC:SubscribeChannelDelegate{
    func subscribeChannel(id: Int, subscribeBtn: UIButton) {
        if Reachability.isConnectedToNetwork(){
            Async.background({
                PlayVideoManager.instance.subUnsubChannel(User_id: self.userId ?? 0, Session_Token: self.sessionId ?? "", Channel_Id: id ?? 0) { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            log.verbose("success \(success?.code) ")
                            self.dismissProgressDialog()
                            if success?.code == 0 {
                                self.view.makeToast("Channel unsubscribe")
                                subscribeBtn.backgroundColor = .white
                                subscribeBtn.borderColor = UIColor(hexFromString: "0096FF", alpha: 1)
                                subscribeBtn.borderWidth = 1
                                subscribeBtn.setTitleColor(.black, for: .normal)
                                subscribeBtn.setTitle("Subscribe", for: .normal)
                            }else{
                                self.view.makeToast("Channel subscribed")
                                subscribeBtn.backgroundColor =  UIColor(hexFromString: "0096FF", alpha: 1)
                               subscribeBtn.setTitleColor(.white, for: .normal)
                                 subscribeBtn.setTitle("Subscribed", for: .normal)
                            }
                           
                        })
                        
                    }else if sessionError != nil{
                        log.verbose("sessionError = \(sessionError?.errors!.errorText)")
                        self.dismissProgressDialog()
                        self.view.makeToast(sessionError?.errors!.errorText)
                    }else{
                        log.verbose("error = \(error?.localizedDescription)")
                        self.dismissProgressDialog()
                    }
                    
                }
            })
            
        }else{
            self.view.makeToast(InterNetError)
        }
        
    }
    
    
}
