//
//  TopAndLatestVideosVC.swift
//  Playtube


import UIKit
import Async
import PlaytubeSDK

class TopAndLatestVideosVC: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var index:Int? = nil
    var getStringStatus:Bool? = false
    private var status:Bool? = false
    private var userId:Int? = nil
    private var sessionStatus:Bool? = false
    private var sessionId:String? = nil
    var topVidesArray = [Home.Featured]()
    var latestVideosArray = [Home.Featured]()
    private var appDelegate = UIApplication.shared.delegate as? AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
          self.view.backgroundColor = AppSettings.appColor
        self.tableView.separatorStyle = .none
        //        log.verbose("Videos = \(topVidesArray)")
        self.sessionStatus = UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session).isEmpty
        if sessionStatus!{
            self.fetchData(UserID: self.userId ?? 0, SessionID: self.sessionId ?? "")
            
        }else{
            self.getUserSession()
            self.fetchData(UserID: self.userId!, SessionID: self.sessionId!)
            
            
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.NavigationbarConfiguration()
    }
    //    override func viewWillDisappear(_ animated: Bool) {
    //        self.navigationController?.isNavigationBarHidden = true
    //    }
    //
    
    func fetchData(UserID:Int,SessionID:String){
        if Reachability.isConnectedToNetwork(){
            self.showProgressDialog(text: "Loading")
            Async.background{
                HomeManager.instance.getHomeDataWithLimit(User_id: UserID, Session_Token: SessionID, Limit: 15) { (Response, responseError, error) in
                    if error == nil{
                        Async.main{
                            if self.getStringStatus!{
                                self.topVidesArray = (Response?.data!.top)!
                                self.tableView.reloadData()
                                self.dismissProgressDialog()
                            }else{
                                self.latestVideosArray = (Response?.data!.latest)!
                                self.tableView.reloadData()
                                self.dismissProgressDialog()
                            }
                        }
                    }else if responseError != nil{
                        Async.main{
                            log.error("responseError = \(responseError?.errors!.errorText)")
                            self.view.makeToast(responseError?.errors!.errorText)
                            self.dismissProgressDialog()
                        }
                    }else {
                        log.error("error = \(error?.localizedDescription)")
                        self.view.makeToast(error?.localizedDescription)
                        self.dismissProgressDialog()
                    }
                }
            }
        }else{
            self.view.makeToast(InterNetError)
            self.dismissProgressDialog()
        }
    }
    
    private  func getUserSession(){
        log.verbose("getUserSession = \(UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session))")
        let localUserSessionData = UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session)
        self.userId = localUserSessionData[Local.USER_SESSION.user_id] as! Int
        self.sessionId = localUserSessionData[Local.USER_SESSION.session_id] as! String
    }
    private func NavigationbarConfiguration(){
        
        self.navigationController?.isNavigationBarHidden = false
        if self.getStringStatus!{
            self.title = "Top Videos"
        }else {
            self.title = "Latest Videos"
        }
        let color = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color ]
        self.navigationController?.navigationBar.tintColor = color
        
    }
    private func setWatchLater(index:Int){
        log.verbose("Check = \(UserDefaults.standard.getWatchLater(Key: Local.WATCH_LATER.watch_Later))")
        if !topVidesArray.isEmpty{
            let objectToEncode = self.topVidesArray[index]
            let data = try? PropertyListEncoder().encode(objectToEncode)
            var getWatchLaterData = UserDefaults.standard.getWatchLater(Key: Local.WATCH_LATER.watch_Later)
            if UserDefaults.standard.getWatchLater(Key: Local.WATCH_LATER.watch_Later).contains(data!){
                self.view.makeToast("Already added in watch later")
                
            }else{
                getWatchLaterData.append(data!)
                UserDefaults.standard.setWatchLater(value: getWatchLaterData, ForKey: Local.WATCH_LATER.watch_Later)
                self.view.makeToast("Added to watch later")
            }
        }else{
            
            let objectToEncode = self.latestVideosArray[index]
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
        
    }
    private func setNotInterested(index:Int){
        log.verbose("Check = \(UserDefaults.standard.getNotInterested(Key: Local.NOT_INTERESTED.not_interested))")
        if !self.topVidesArray.isEmpty{
            let objectToEncode = self.topVidesArray[index]
            let data = try? PropertyListEncoder().encode(objectToEncode)
            var getWatchLaterData = UserDefaults.standard.getNotInterested(Key: Local.NOT_INTERESTED.not_interested)
            getWatchLaterData.append(data!)
            UserDefaults.standard.setNotInterested(value: getWatchLaterData, ForKey: Local.NOT_INTERESTED.not_interested)
            self.topVidesArray.remove(at: index)
            self.tableView.reloadData()
            self.view.makeToast("Video removed from the list")
            
        }else{
            
            let objectToEncode = self.latestVideosArray[index]
            let data = try? PropertyListEncoder().encode(objectToEncode)
            var getWatchLaterData = UserDefaults.standard.getNotInterested(Key: Local.NOT_INTERESTED.not_interested)
            getWatchLaterData.append(data!)
            UserDefaults.standard.setNotInterested(value: getWatchLaterData, ForKey: Local.NOT_INTERESTED.not_interested)
            self.latestVideosArray.remove(at: index)
            self.tableView.reloadData()
            self.view.makeToast("Video removed from the list")
        }
        
        
        
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
        if !topVidesArray.isEmpty{
            let objectToEncode = self.topVidesArray[index]
            let data = try? PropertyListEncoder().encode(objectToEncode)
            var getWatchLaterData = UserDefaults.standard.getSharedVideos(Key: Local.SHARED_VIDEOS.shared_videos)
            if UserDefaults.standard.getSharedVideos(Key: Local.SHARED_VIDEOS.shared_videos).contains(data!){
                self.view.makeToast("Already added in shared videos")
                
            }else{
                getWatchLaterData.append(data!)
                UserDefaults.standard.setSharedVideos(value: getWatchLaterData, ForKey: Local.SHARED_VIDEOS.shared_videos)
                self.view.makeToast("Added to shared videos")
            }
            
        }else{
            let objectToEncode = self.latestVideosArray[index]
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
}
extension TopAndLatestVideosVC:UITableViewDelegate,UITableViewDataSource,ShowPresentControllerDelegate,IndexofCellDelegate,UISearchBarDelegate,ShowCreatePlayListDelegate{
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
                                if !self.topVidesArray.isEmpty{
                                    let vc = storyboard.instantiateViewController(withIdentifier: "SelectAPlaylistVC") as! SelectAPlaylistVC
                                    vc.playlistArray = (success?.myAllPlaylists)!
                                    vc.delegate = self
                                    vc.videoId = self.topVidesArray[Index].id
                                    self.present(vc, animated: true, completion: nil)
                                    
                                }else{
                                    
                                    let vc = storyboard.instantiateViewController(withIdentifier: "SelectAPlaylistVC") as! SelectAPlaylistVC
                                    vc.playlistArray = (success?.myAllPlaylists)!
                                    vc.delegate = self
                                    vc.videoId = self.latestVideosArray[Index].id
                                    self.present(vc, animated: true, completion: nil)
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
                log.verbose("Index = \(Index)")
            }
            
        case 2:
            setNotInterested(index: index!)
            log.verbose("Index = \(Index)")
        case 3:
            if getStringStatus! {
                self.shareVideo(stringURL: self.topVidesArray[self.index!].videoLocation!)
                self.setSharedVideos(index: index!)
            }else{
                self.shareVideo(stringURL: self.latestVideosArray[self.index!].videoLocation!)
                self.setSharedVideos(index: index!)
            }
            log.verbose("Index = \(Index)")
        case 4:
            if self.sessionStatus!{
                let vc = storyboard.instantiateViewController(withIdentifier: "ShowLoginPopVC") as! ShowLoginPopVC
                self.present(vc, animated: true, completion: nil)
            }else{
                log.verbose("Index = \(Index)")
                let vc = storyboard.instantiateViewController(withIdentifier: "ReportVideoVC") as! ReportVideoVC
                if !self.topVidesArray.isEmpty{
                    
                    vc.videoId = topVidesArray[Index].id
                    
                }else{
                    vc.videoId = latestVideosArray[Index].id
                    
                }
                self.present(vc, animated: true, completion: nil)
                
            }
        default:
            log.verbose("Something went wrong. Please try again Later!.")
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.getStringStatus!{
            return self.topVidesArray.count ?? 0
            
        }else{
            
            return self.latestVideosArray.count ?? 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.getStringStatus!{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopAndLatest_TableCell") as! TopAndLatest_TableCell
            cell.selectionStyle = .none
            cell.delegate = self
            cell.cellIndexDelegate = self
            cell.indexPath = indexPath.row
            let topVideosObject = topVidesArray[indexPath.row]
            cell.nameLabel.text = topVideosObject.title!.htmlAttributedString ?? ""
            cell.usernameLabel.text = topVideosObject.owner!.username!.htmlAttributedString ?? ""
            cell.viewsLabel.text = "\(topVideosObject.views!.roundedWithAbbreviations ?? "") Views"
            cell.durationLabel.text = topVideosObject.duration ?? ""
            cell.durationView?.sizeThatFits(CGSize(width: (cell.durationLabel.frame.width) + 10, height: (cell.durationLabel.frame.height)))
            let url = URL.init(string:topVideosObject.thumbnail!)
            cell.imageViewLabel.sd_setImage(with: url , placeholderImage: UIImage(named: "maxresdefault"))
            cell.imageViewLabel.layer.cornerRadius = 10
            cell.imageViewLabel.clipsToBounds = true
            if topVideosObject.owner!.verified == 1{
                cell.isVerifiedLabel.isHidden = true
            }else{
                cell.isVerifiedLabel.isHidden = false
            }
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopAndLatest_TableCell") as! TopAndLatest_TableCell
            cell.selectionStyle = .none
            cell.delegate = self
            cell.cellIndexDelegate = self
            cell.indexPath = indexPath.row
            let latestVideosObject = latestVideosArray[indexPath.row]
            cell.nameLabel.text = latestVideosObject.title!.htmlAttributedString ?? ""
            cell.usernameLabel.text = latestVideosObject.owner!.username!.htmlAttributedString ?? ""
            cell.viewsLabel.text = "\(latestVideosObject.views!.roundedWithAbbreviations ?? "") Views"
            cell.durationLabel.text = latestVideosObject.duration ?? ""
            cell.durationView?.sizeThatFits(CGSize(width: (cell.durationLabel.frame.width) + 10, height: (cell.durationLabel.frame.height)))
            let url = URL.init(string:latestVideosObject.thumbnail!)
            cell.imageViewLabel.sd_setImage(with: url , placeholderImage: UIImage(named: "maxresdefault"))
            cell.imageViewLabel.layer.cornerRadius = 10
            cell.imageViewLabel.clipsToBounds = true
            if latestVideosObject.owner!.verified == 1{
                cell.isVerifiedLabel.isHidden = true
            }else{
                cell.isVerifiedLabel.isHidden = false
            }
            
            return cell
            
        }
        
        
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "PlayVideoVC") as! PlayVideoVC
        if !self.topVidesArray.isEmpty{
            let  objectToEncode =  self.topVidesArray[indexPath.row]
            let data = try? PropertyListEncoder().encode(objectToEncode)
            vc.videoObject = data
            self.appDelegate!.videoId  = objectToEncode.videoID
            self.appDelegate!.commentVideoId = objectToEncode.id
            
        }else{
            let  objectToEncode =  self.latestVideosArray[indexPath.row]
            let data = try? PropertyListEncoder().encode(objectToEncode)
            vc.videoObject = data
            self.appDelegate!.videoId  = objectToEncode.videoID
            self.appDelegate!.commentVideoId = objectToEncode.id
            
        }
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
        
        
    }
    
    
}
