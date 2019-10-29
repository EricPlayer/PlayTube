//
//  WatchLaterVC.swift
//  Playtube


import UIKit
import Async
import PlaytubeSDK

class WatchLaterVC: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showStack: UIStackView!
    
    var index:Int? = nil
    var getStringStatus:String? = ""
    private var status:Bool? = false
    private var userId:Int? = nil
    private var sessionId:String? = nil
    private var watchLaterVideos = [UserDefaultModel.Datum]()
    private var offlineDownloadVideos = [UserDefaultModel.Datum]()
     private var sharedVideosArray = [UserDefaultModel.Datum]()
    private var appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
          self.view.backgroundColor = AppSettings.appColor
        self.tableView.separatorStyle = .none
        getUserSession()
        fetchData()
    }
    override func viewWillAppear(_ animated: Bool) {
        NavigationbarConfiguration()
    }
    
    private func fetchData(){
        if getStringStatus == Local.WATCH_LATER.watch_Later{
            var allData =  UserDefaults.standard.getWatchLater(Key: Local.WATCH_LATER.watch_Later)
            if allData.isEmpty{
                self.tableView.isHidden = true
                self.showStack.isHidden = false
            }else{
                self.tableView.isHidden = false
                self.showStack.isHidden = true
                log.verbose("all data = \(allData)")
                for data in allData{
                    let videoObject = try? PropertyListDecoder().decode(UserDefaultModel.Datum.self ,from: data)
                    if videoObject != nil{
                        log.verbose("videoObject = \(videoObject?.id)")
                        self.watchLaterVideos.append(videoObject!)
                         UserDefaults.standard.setWatchLaterImage(value: (watchLaterVideos.last?.thumbnail)!, ForKey: "libraryWatchLaterImage")
                    }else{
                        log.verbose("Nil values cannot be append in Array!")
                    }
                    
                }
            }
        }else if getStringStatus == Local.OFFLINE_DOWNLOAD.offline_download{
            var allData =  UserDefaults.standard.getOfflineDownload(Key: Local.OFFLINE_DOWNLOAD.offline_download)
            if allData.isEmpty{
                self.tableView.isHidden = true
                self.showStack.isHidden = false
            }else{
                self.tableView.isHidden = false
                self.showStack.isHidden = true
                for data in allData{
                    let videoObject = try? PropertyListDecoder().decode(UserDefaultModel.Datum.self ,from: data)
                    if videoObject != nil{
                        log.verbose("videoObject = \(videoObject?.id)")
                        self.offlineDownloadVideos.append(videoObject!)
                        UserDefaults.standard.setOfflineImage(value: (offlineDownloadVideos.last?.thumbnail)!, ForKey: "libraryOfflineDownloadImage")
                    }else{
                        log.verbose("Nil values cannot be append in Array!")
                    }
                    
                }
            }
        }else{
            var allData =  UserDefaults.standard.getSharedVideos(Key: Local.SHARED_VIDEOS.shared_videos)
            if allData.isEmpty{
                self.tableView.isHidden = true
                self.showStack.isHidden = false
            }else{
                self.tableView.isHidden = false
                self.showStack.isHidden = true
                for data in allData{
                    let videoObject = try? PropertyListDecoder().decode(UserDefaultModel.Datum.self ,from: data)
                    if videoObject != nil{
                        log.verbose("videoObject = \(videoObject?.id)")
                        self.sharedVideosArray.append(videoObject!)
//                        UserDefaults.standard.setOfflineImage(value: (offlineDownloadVideos.last?.thumbnail)!, ForKey: "libraryOfflineDownloadImage")
                    }else{
                        log.verbose("Nil values cannot be append in Array!")
                    }
                    
                }
            }

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
        if getStringStatus == Local.WATCH_LATER.watch_Later{
            self.title = "Watch Later"
        }else if getStringStatus == Local.OFFLINE_DOWNLOAD.offline_download{
            self.title = "Offline Downloads"
        }else{
            self.title = "Shared Videos"
        }
        
        let color = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color ]
        self.navigationController?.navigationBar.tintColor = color
        
    }
    private func setNotInterested(index:Int){
        if !watchLaterVideos.isEmpty{
            log.verbose("Check = \(UserDefaults.standard.getNotInterested(Key: Local.NOT_INTERESTED.not_interested))")
            
            
            let objectToEncode = self.watchLaterVideos[index]
            let data = try? PropertyListEncoder().encode(objectToEncode)
            var getWatchLaterData = UserDefaults.standard.getNotInterested(Key: Local.NOT_INTERESTED.not_interested)
            getWatchLaterData.append(data!)
            UserDefaults.standard.setNotInterested(value: getWatchLaterData, ForKey: Local.NOT_INTERESTED.not_interested)
            self.watchLaterVideos.remove(at: index)
            self.tableView.reloadData()
            self.view.makeToast("Video removed from the list")
        }else if !offlineDownloadVideos.isEmpty{
            log.verbose("Check = \(UserDefaults.standard.getNotInterested(Key: Local.NOT_INTERESTED.not_interested))")
            
            
            let objectToEncode = self.offlineDownloadVideos[index]
            let data = try? PropertyListEncoder().encode(objectToEncode)
            var getWatchLaterData = UserDefaults.standard.getNotInterested(Key: Local.NOT_INTERESTED.not_interested)
            getWatchLaterData.append(data!)
            UserDefaults.standard.setNotInterested(value: getWatchLaterData, ForKey: Local.NOT_INTERESTED.not_interested)
            self.watchLaterVideos.remove(at: index)
            self.tableView.reloadData()
            self.view.makeToast("Video removed from the list")
        }else{
            log.verbose("Check = \(UserDefaults.standard.getNotInterested(Key: Local.NOT_INTERESTED.not_interested))")
            
            
            let objectToEncode = self.sharedVideosArray[index]
            let data = try? PropertyListEncoder().encode(objectToEncode)
            var getWatchLaterData = UserDefaults.standard.getNotInterested(Key: Local.NOT_INTERESTED.not_interested)
            getWatchLaterData.append(data!)
            UserDefaults.standard.setNotInterested(value: getWatchLaterData, ForKey: Local.NOT_INTERESTED.not_interested)
            self.watchLaterVideos.remove(at: index)
            self.tableView.reloadData()
            self.view.makeToast("Video removed from the list")
        }
    
    }
    private func removeFromList(index:Int){
        if !watchLaterVideos.isEmpty{
            var objectTomap = [Data]()
            var allData =  UserDefaults.standard.getWatchLater(Key: Local.WATCH_LATER.watch_Later)
            self.watchLaterVideos.remove(at: index)
            for object in self.watchLaterVideos{
                let data = try? PropertyListEncoder().encode(object)
                objectTomap.append(data!)
            }
            UserDefaults.standard.setWatchLater(value: objectTomap, ForKey: Local.WATCH_LATER.watch_Later)
            self.tableView.reloadData()
            self.view.makeToast("removed from list")
        }else if !offlineDownloadVideos.isEmpty{
            var objectTomap = [Data]()
            var allData =  UserDefaults.standard.getOfflineDownload(Key: Local.OFFLINE_DOWNLOAD.offline_download)
            self.watchLaterVideos.remove(at: index)
            for object in self.offlineDownloadVideos{
                let data = try? PropertyListEncoder().encode(object)
                objectTomap.append(data!)
            }
            UserDefaults.standard.setOfflineDownload(value: objectTomap, ForKey: Local.OFFLINE_DOWNLOAD.offline_download)
            self.tableView.reloadData()
            self.view.makeToast("removed from list")
        }else{
            var objectTomap = [Data]()
            var allData =  UserDefaults.standard.getSharedVideos(Key: Local.SHARED_VIDEOS.shared_videos)
            self.watchLaterVideos.remove(at: index)
            for object in self.sharedVideosArray{
                let data = try? PropertyListEncoder().encode(object)
                objectTomap.append(data!)
            }
            UserDefaults.standard.setSharedVideos(value: objectTomap, ForKey: Local.SHARED_VIDEOS.shared_videos)
            self.tableView.reloadData()
            self.view.makeToast("removed from list")
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
        if !watchLaterVideos.isEmpty{
            log.verbose("Check = \(UserDefaults.standard.getSharedVideos(Key: Local.SHARED_VIDEOS.shared_videos))")
            let objectToEncode = self.watchLaterVideos[index]
            let data = try? PropertyListEncoder().encode(objectToEncode)
            var getWatchLaterData = UserDefaults.standard.getSharedVideos(Key: Local.SHARED_VIDEOS.shared_videos)
            if UserDefaults.standard.getSharedVideos(Key: Local.SHARED_VIDEOS.shared_videos).contains(data!){
                self.view.makeToast("Already added in shared videos")
                
            }else{
                getWatchLaterData.append(data!)
                UserDefaults.standard.setSharedVideos(value: getWatchLaterData, ForKey: Local.SHARED_VIDEOS.shared_videos)
                self.view.makeToast("Added to shared videos")
            }
        }else if !offlineDownloadVideos.isEmpty{
            log.verbose("Check = \(UserDefaults.standard.getSharedVideos(Key: Local.SHARED_VIDEOS.shared_videos))")
            let objectToEncode = self.offlineDownloadVideos[index]
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
            log.verbose("Check = \(UserDefaults.standard.getSharedVideos(Key: Local.SHARED_VIDEOS.shared_videos))")
            let objectToEncode = self.sharedVideosArray[index]
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
extension WatchLaterVC:UITableViewDelegate,UITableViewDataSource,ShowPresentControllerDelegate,IndexofCellDelegate,UISearchBarDelegate,ShowCreatePlayListDelegate{
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
        log.verbose("Index = \(Index)")
        self.index = Index
    }
    
    func showController(Index: Int) {
        let storyboard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        switch Index{
        case 0:
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
                            vc.videoId = self.watchLaterVideos[Index].id
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
        case 1:
            setNotInterested(index: index!)
            log.verbose("Index = \(Index)")
        case 2:
            self.shareVideo(stringURL: self.watchLaterVideos[self.index!].videoLocation!)
            self.setSharedVideos(index: index!)
            log.verbose("Index = \(Index)")
        case 3:
            let vc = storyboard.instantiateViewController(withIdentifier: "ReportVideoVC") as! ReportVideoVC
            vc.videoId = watchLaterVideos[Index].id
            self.present(vc, animated: true, completion: nil)
            log.verbose("Index = \(Index)")
        case 4:
            removeFromList(index: index!)
            log.verbose("Index = \(Index)")
            
        default:
            log.verbose("Something went wrong. Please try again Later!.")
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if getStringStatus == Local.WATCH_LATER.watch_Later{
             return self.watchLaterVideos.count ?? 0
        }else if getStringStatus == Local.OFFLINE_DOWNLOAD.offline_download{
             return self.offlineDownloadVideos.count ?? 0
        }else{
             return self.sharedVideosArray.count ?? 0
        }
       
    }
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if getStringStatus == Local.WATCH_LATER.watch_Later{
            let cell = tableView.dequeueReusableCell(withIdentifier: "WatchLater_TableCell") as! WatchLater_TableCell
            cell.selectionStyle = .none
            cell.delegate = self
            cell.cellIndexDelegate = self
            cell.indexPath = indexPath.row
            let watchLaterVideosObject = watchLaterVideos[indexPath.row]
            cell.nameLabel.text = watchLaterVideosObject.title!.htmlAttributedString ?? ""
            cell.usernameLabel.text = watchLaterVideosObject.owner!.username!.htmlAttributedString ?? ""
            cell.viewsLabel.text = "\(watchLaterVideosObject.views!.roundedWithAbbreviations ?? "") Views"
            cell.durationLabel.text = watchLaterVideosObject.duration ?? ""
              cell.durationView?.sizeThatFits(CGSize(width: (cell.durationLabel.frame.width) + 10, height: (cell.durationLabel.frame.height)))
            let url = URL.init(string:watchLaterVideosObject.thumbnail!)
            cell.imageViewLabel.sd_setImage(with: url , placeholderImage: UIImage(named: "maxresdefault"))
            cell.imageViewLabel.layer.cornerRadius = 10
            cell.imageViewLabel.clipsToBounds = true
            if watchLaterVideosObject.owner!.verified == 1{
                cell.isVerifiedLabel.isHidden = true
            }else{
                cell.isVerifiedLabel.isHidden = false
            }
            
            return cell
            
        }else if getStringStatus == Local.OFFLINE_DOWNLOAD.offline_download{
            let cell = tableView.dequeueReusableCell(withIdentifier: "WatchLater_TableCell") as! WatchLater_TableCell
            cell.selectionStyle = .none
            cell.delegate = self
            cell.cellIndexDelegate = self
            cell.indexPath = indexPath.row
            let offlineDownloadVideosObject = offlineDownloadVideos[indexPath.row]
            cell.nameLabel.text = offlineDownloadVideosObject.title!.htmlAttributedString ?? ""
            cell.usernameLabel.text = offlineDownloadVideosObject.owner!.username!.htmlAttributedString ?? ""
            cell.viewsLabel.text = "\(offlineDownloadVideosObject.views!.roundedWithAbbreviations ?? "") Views"
            cell.durationLabel.text = offlineDownloadVideosObject.duration ?? ""
              cell.durationView?.sizeThatFits(CGSize(width: (cell.durationLabel.frame.width) + 10, height: (cell.durationLabel.frame.height)))
            let url = URL.init(string:offlineDownloadVideosObject.thumbnail!)
            cell.imageViewLabel.sd_setImage(with: url , placeholderImage: UIImage(named: "maxresdefault"))
            cell.imageViewLabel.layer.cornerRadius = 10
            cell.imageViewLabel.clipsToBounds = true
            if offlineDownloadVideosObject.owner!.verified == 1{
                cell.isVerifiedLabel.isHidden = true
            }else{
                cell.isVerifiedLabel.isHidden = false
            }
            
            return cell
            
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "WatchLater_TableCell") as! WatchLater_TableCell
            cell.selectionStyle = .none
            cell.delegate = self
            cell.cellIndexDelegate = self
            cell.indexPath = indexPath.row
            let sharedVideosObject = sharedVideosArray[indexPath.row]
            cell.nameLabel.text = sharedVideosObject.title!.htmlAttributedString ?? ""
            cell.usernameLabel.text = sharedVideosObject.owner!.username!.htmlAttributedString ?? ""
            cell.viewsLabel.text = "\(sharedVideosObject.views!.roundedWithAbbreviations ?? "") Views"
            cell.durationLabel.text = sharedVideosObject.duration ?? ""
            cell.durationView?.sizeThatFits(CGSize(width: (cell.durationLabel.frame.width) + 10, height: (cell.durationLabel.frame.height)))
            let url = URL.init(string:sharedVideosObject.thumbnail!)
            cell.imageViewLabel.sd_setImage(with: url , placeholderImage: UIImage(named: "maxresdefault"))
            cell.imageViewLabel.layer.cornerRadius = 10
            cell.imageViewLabel.clipsToBounds = true
            if sharedVideosObject.owner!.verified == 1{
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
        let playNextToVc = storyBoard.instantiateViewController(withIdentifier: "PlayVideo_NextToVC") as! PlayVideo_NextToVC
        if getStringStatus == Local.WATCH_LATER.watch_Later{
            let  objectToEncode =  self.watchLaterVideos[indexPath.row]
            let data = try? PropertyListEncoder().encode(objectToEncode)
            vc.videoObject = data
            self.appDelegate?.videoId = objectToEncode.videoID
            self.appDelegate?.commentVideoId = objectToEncode.id
            //            playNextToVc.videoId = objectToEncode.videoID
        }else if getStringStatus == Local.OFFLINE_DOWNLOAD.offline_download {
            let  objectToEncode =  self.offlineDownloadVideos[indexPath.row]
            let data = try? PropertyListEncoder().encode(objectToEncode)
            vc.videoObject = data
            //            playNextToVc.videoId = objectToEncode.videoID
            self.appDelegate?.videoId  = objectToEncode.videoID
            self.appDelegate?.commentVideoId = objectToEncode.id
        }else{
            let  objectToEncode =  self.sharedVideosArray[indexPath.row]
            let data = try? PropertyListEncoder().encode(objectToEncode)
            vc.videoObject = data
            //            playNextToVc.videoId = objectToEncode.videoID
            self.appDelegate?.videoId  = objectToEncode.videoID
            self.appDelegate?.commentVideoId = objectToEncode.id
        }
        self.navigationController?.pushViewController(vc, animated: true)
        //        self.present(vc, animated: true, completion: nil)
    
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
        
        
    }
    
    
}
