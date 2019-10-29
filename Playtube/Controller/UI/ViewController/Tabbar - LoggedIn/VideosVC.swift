//
//  VideosVC.swift
//  Playtube

import UIKit
import XLPagerTabStrip
import Async
import JGProgressHUD
import PlaytubeSDK

class VideosVC: UIViewController,IndicatorInfoProvider {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showStack: UIStackView!
    
    var index:Int? = nil
    var hud : JGProgressHUD?
    var channelId:Int? = 0
    var getStringStatus:Bool? = false
    private var status:Bool? = false
    private var userId:Int? = nil
    private var sessionId:String? = nil
    private var sessionStatus:Bool? = nil
    private var channelVideos = [MychannelModel.ChannelVideos.Datum]()
    private var appDelegate = UIApplication.shared.delegate as? AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = AppSettings.appColor
        self.tableView.separatorStyle = .none
        self.sessionStatus =  UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session).isEmpty
        if channelId == 0 {
            if UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session).isEmpty{
                self.myChannelfetchData()
            }else{
                self.getUserSession()
                self.myChannelfetchData()
            }
            
        }else{
            if UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session).isEmpty{
                self.otherChannelfetchData()
            }else{
                self.getUserSession()
                self.otherChannelfetchData()
            }
            
        }
        
    }
    
    private func myChannelfetchData(){
        if Reachability.isConnectedToNetwork(){
            self.showProgressDialog(text: "Loading...")
            Async.background({
                MyChannelManager.instance.getChannelVideos(User_id: self.userId!) { (Success, AuthError, error) in
                    if Success != nil{
                        Async.main({
                            log.verbose("SUCCESS")
                            self.channelVideos = Success?.data ?? []
                            if !self.channelVideos.isEmpty{
                                self.tableView.reloadData()
                                self.showStack.isHidden = true
                                self.tableView.isHidden = false
                                self.dismissProgressDialog()
                            }else{
                                self.showStack.isHidden = false
                                self.tableView.isHidden = true
                                self.dismissProgressDialog()
                            }
                            
                        })
                    }else if AuthError != nil{
                        self.view.makeToast(AuthError?.errors!.errorText)
                        self.dismissProgressDialog()
                        
                    }else{ self.view.makeToast(error?.localizedDescription)
                        self.dismissProgressDialog()
                    }
                }
                
            })
        }else{
            self.view.makeToast(InterNetError)
        }
    }
    private func otherChannelfetchData(){
        if Reachability.isConnectedToNetwork(){
            self.showProgressDialog(text: "Loading...")
            Async.background({
                
                MyChannelManager.instance.getChannelVideos(User_id: self.channelId!) { (Success, AuthError, error) in
                    if Success != nil{
                        Async.main({
                            log.verbose("SUCCESS")
                            self.channelVideos = Success?.data ?? []
                            if !self.channelVideos.isEmpty{
                                self.tableView.reloadData()
                                self.showStack.isHidden = true
                                self.tableView.isHidden = false
                                self.dismissProgressDialog()
                            }else{
                                self.showStack.isHidden = false
                                self.tableView.isHidden = true
                                self.dismissProgressDialog()
                            }
                            
                        })
                    }else if AuthError != nil{ self.view.makeToast(AuthError?.errors!.errorText)
                        self.dismissProgressDialog()
                        
                    }else{ self.view.makeToast(error?.localizedDescription)
                        self.dismissProgressDialog()
                    }
                }
                
            })
        }else{
            self.view.makeToast(InterNetError)
        }
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "VIDEOS")
        
    }
    private  func getUserSession(){
        log.verbose("getUserSession = \(UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session))")
        let localUserSessionData = UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session)
        self.userId = localUserSessionData[Local.USER_SESSION.user_id] as! Int
        self.sessionId = localUserSessionData[Local.USER_SESSION.session_id] as! String
    }
    private func setWatchLater(index:Int){
        log.verbose("Check = \(UserDefaults.standard.getWatchLater(Key: Local.WATCH_LATER.watch_Later))")
        let objectToEncode = self.channelVideos[index]
        let data = try? PropertyListEncoder().encode(objectToEncode)
        var getWatchLaterData = UserDefaults.standard.getWatchLater(Key: Local.WATCH_LATER.watch_Later)
        if UserDefaults.standard.getWatchLater(Key: Local.WATCH_LATER.watch_Later).contains(data!){
            self.view.makeToast("Already added in watch later")
            
        }else{
            getWatchLaterData.append(data!)
            UserDefaults.standard.setWatchLater(value: getWatchLaterData, ForKey: Local.WATCH_LATER.watch_Later)
            self.view.makeToast("Added to watch later")
        }
        
    }
    private func setNotInterested(index:Int){
        log.verbose("Check = \(UserDefaults.standard.getNotInterested(Key: Local.NOT_INTERESTED.not_interested))")
        
        
        let objectToEncode = self.channelVideos[index]
        let data = try? PropertyListEncoder().encode(objectToEncode)
        var getWatchLaterData = UserDefaults.standard.getNotInterested(Key: Local.NOT_INTERESTED.not_interested)
        getWatchLaterData.append(data!)
        UserDefaults.standard.setNotInterested(value: getWatchLaterData, ForKey: Local.NOT_INTERESTED.not_interested)
        self.channelVideos.remove(at: index)
        self.tableView.reloadData()
        self.view.makeToast("Video removed from the list")
    }
    private func shareVideo(stringURL:String){
        let someText:String = "Test Video"
        let objectsToShare:URL = URL(string: stringURL)!
        let sharedObjects:[AnyObject] = [objectsToShare as AnyObject,someText as AnyObject]
        let activityViewController = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook,UIActivity.ActivityType.postToTwitter,UIActivity.ActivityType.mail,UIActivity.ActivityType.postToTencentWeibo]
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    private func setSharedVideos(index:Int){
        log.verbose("Check = \(UserDefaults.standard.getSharedVideos(Key: Local.SHARED_VIDEOS.shared_videos))")
        let objectToEncode = self.channelVideos[index]
        let data = try? PropertyListEncoder().encode(objectToEncode)
        var getWatchLaterData = UserDefaults.standard.getSharedVideos(Key: Local.SHARED_VIDEOS.shared_videos)
        if UserDefaults.standard.getSharedVideos(Key: Local.SHARED_VIDEOS.shared_videos).contains(data!){
            self.view.makeToast("Already added in shared videos")
            
        }else{
            getWatchLaterData.append(data!)
            UserDefaults.standard.setSharedVideos(value: getWatchLaterData, ForKey: Local.SHARED_VIDEOS.shared_videos)
            self.view.makeToast("Added to shared videos")
        }
        
        
        
    }
    
}

extension VideosVC:UITableViewDelegate,UITableViewDataSource,ShowPresentControllerDelegate,IndexofCellDelegate,UISearchBarDelegate,ShowCreatePlayListDelegate{
    func showCreatePlaylist(Status: Bool) {
        if Status{
            let storyboard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "CreatePlaylistVC") as! CreatePlaylistVC
            vc.status = false
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            log.verbose("Status = \(Status)")
        }
    }
    
    func indexofCell(Index: Int) {
        self.index = Index
        
    }
    
    func showController(Index: Int) {
        let storyboard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        switch Index{
        case 0:
            if self.sessionStatus!{
                let vc = storyboard.instantiateViewController(withIdentifier: "ShowLoginPopVC") as! ShowLoginPopVC
                self.present(vc, animated: true, completion: nil)
            }else{
                log.verbose("Index = \(Index)")
                setWatchLater(index: index!)
                log.verbose("getWatchSettings = \(UserDefaults.standard.getWatchLater(Key: Local.WATCH_LATER.watch_Later).count)")
            }
            
        case 1:
            if self.sessionStatus!{
                let vc = storyboard.instantiateViewController(withIdentifier: "ShowLoginPopVC") as! ShowLoginPopVC
                self.present(vc, animated: true, completion: nil)
            }else{
                self.showProgressDialog(text: "Loading...")
                Async.background({
                    PlaylistManager.instance.getPlaylist(User_id: self.userId!, Session_Token: self.sessionId!) { (success, sessionError, error) in
                        if success != nil{
                            Async.main({
                                log.verbose("success \(success?.myAllPlaylists) ")
                                self.dismissProgressDialog()
                               
                                    let vc = storyboard.instantiateViewController(withIdentifier: "SelectAPlaylistVC") as! SelectAPlaylistVC
                                    vc.playlistArray = (success?.myAllPlaylists)!
                                    vc.delegate = self
                                    vc.videoId = self.channelVideos[Index].id
                                    self.present(vc, animated: true, completion: nil)
                                
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
                log.verbose("Index = \(Index)")
            }
            
        case 2:
            setNotInterested(index: index!)
            log.verbose("Index = \(Index)")
        case 3:
           
            self.shareVideo(stringURL: self.channelVideos[self.index!].videoLocation!)
            self.setSharedVideos(index: index!)
            log.verbose("Index = \(Index)")
        case 4:
            if self.sessionStatus!{
                let vc = storyboard.instantiateViewController(withIdentifier: "ShowLoginPopVC") as! ShowLoginPopVC
                self.present(vc, animated: true, completion: nil)
            }else{
                log.verbose("Index = \(Index)")
                let vc = storyboard.instantiateViewController(withIdentifier: "ReportVideoVC") as! ReportVideoVC
                    vc.videoId = channelVideos[Index].id
                    self.present(vc, animated: true, completion: nil)
                
                
            }
        default:
            log.verbose("Something went wrong. Please try again Later!.")
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.channelVideos.count ?? 0
    }
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Videos_TableCell") as! Videos_TableCell
        cell.selectionStyle = .none
        cell.delegate = self
        cell.cellIndexDelegate = self
        cell.indexPath = indexPath.row
        let channelVideossObject = channelVideos[indexPath.row]
        cell.nameLabel.text = channelVideossObject.title!.htmlAttributedString ?? ""
        cell.usernameLabel.text = channelVideossObject.owner!.username!.htmlAttributedString ?? ""
        cell.viewsLabel.text = "\(channelVideossObject.views!.roundedWithAbbreviations ?? "") Views"
        cell.durationLabel.text = channelVideossObject.duration ?? ""
        cell.durationView?.sizeThatFits(CGSize(width: (cell.durationLabel.frame.width) + 10, height: (cell.durationLabel.frame.height)))
        let url = URL.init(string:channelVideossObject.thumbnail!)
        cell.imageViewLabel.sd_setImage(with: url , placeholderImage: UIImage(named: "maxresdefault"))
        cell.imageViewLabel.layer.cornerRadius = 10
        cell.imageViewLabel.clipsToBounds = true
        if channelVideossObject.owner!.verified == 1{
            cell.isVerifiedLabel.isHidden = true
        }else{
            cell.isVerifiedLabel.isHidden = false
        }
        
        return cell
        
        
        
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "PlayVideoVC") as! PlayVideoVC
        let  objectToEncode =  self.channelVideos[indexPath.row]
        let data = try? PropertyListEncoder().encode(objectToEncode)
        vc.videoObject = data
        self.appDelegate!.videoId  = objectToEncode.videoID
        self.appDelegate!.commentVideoId = objectToEncode.id
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
        
        
    }
    
    
}
extension VideosVC{
    func showProgressDialog(text: String) {
        hud = JGProgressHUD(style: .extraLight)
        hud?.textLabel.text = text
        hud?.show(in: self.view)
    }
    
    func dismissProgressDialog() {
        hud?.dismiss()
    }
}
