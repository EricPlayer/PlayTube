//
//  PlayVideo_NextToVC.swift
//  Playtube


import UIKit
import XLPagerTabStrip
import Async
import PlaytubeSDK

protocol PlayNextVideoDelegate {
   func playNextVideo(nextVideo:Data)
}

class PlayVideo_NextToVC: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var delegate:PlayNextVideoDelegate!
    var videoId:String? = nil
    private var index:Int? = nil
    private var userId:Int? = nil
    private var sessionId:String? = nil
    private var suggestedVideosArray = [PlayVideoModel.DataElement]()
    private let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
          self.view.backgroundColor = AppSettings.appColor
        self.tableView.separatorStyle = .none
        if UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session).isEmpty{
            log.verbose("getUserSession = \(UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session))")
            self.fetchData()
        }else{
            log.verbose("getUserSession = \(UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session))")
            self.getUserSession()
           self.fetchData()
        }
        
        
      
        log.verbose("videoId = \(videoId)")
        
    }
    private func fetchData(){
        if Reachability.isConnectedToNetwork(){
            self.videoId = self.appDelegate?.videoId
            log.verbose("self.appDelegate?.videoId = \(self.appDelegate?.videoId)")
            self.showProgressDialog(text: "Loading...")
            Async.background({
                PlayVideoManager.instance.getVideosDetailsByVideoId(User_id: self.userId ?? 0, Session_Token: self.sessionId ?? "", VideoId: self.videoId ?? "", completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            log.verbose("SUCCESS")
                            self.suggestedVideosArray = success?.data!.suggestedVideos ?? []
                            
                            if !self.suggestedVideosArray.isEmpty{
                                self.tableView.reloadData()
                                self.tableView.isHidden = false
                                self.dismissProgressDialog()
                            }else{
                                
                                self.tableView.isHidden = true
                                self.dismissProgressDialog()
                            }
                            
                        })
                    }else if sessionError != nil{ self.view.makeToast(sessionError?.errors!.errorText)
                        self.dismissProgressDialog()
                        
                    }else{ self.view.makeToast(error?.localizedDescription)
                        self.dismissProgressDialog()
                    }
                })
               
                
            })
        }else{
            self.view.makeToast(InterNetError)
        }
    }
    private  func getUserSession(){
        log.verbose("getUserSession = \(UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session))")
        let localUserSessionData = UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session)
        self.userId = localUserSessionData[Local.USER_SESSION.user_id] as! Int
        self.sessionId = localUserSessionData[Local.USER_SESSION.session_id] as! String
    }
    
    private func setWatchLater(index:Int){
        log.verbose("Check = \(UserDefaults.standard.getWatchLater(Key: Local.WATCH_LATER.watch_Later))")
        let objectToEncode = self.suggestedVideosArray[index]
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
        
        
        let objectToEncode = self.suggestedVideosArray[index]
        let data = try? PropertyListEncoder().encode(objectToEncode)
        var getWatchLaterData = UserDefaults.standard.getNotInterested(Key: Local.NOT_INTERESTED.not_interested)
        getWatchLaterData.append(data!)
        UserDefaults.standard.setNotInterested(value: getWatchLaterData, ForKey: Local.NOT_INTERESTED.not_interested)
        self.suggestedVideosArray.remove(at: index)
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
        let objectToEncode = self.suggestedVideosArray[index]
        let data = try? PropertyListEncoder().encode(objectToEncode)
        var getWatchLaterData = UserDefaults.standard.getSharedVideos(Key: Local.SHARED_VIDEOS.shared_videos)
        if UserDefaults.standard.getSharedVideos(Key: Local.SHARED_VIDEOS.shared_videos).contains(data!){
            self.view.makeToast("Already added in watch later")
            
        }else{
            getWatchLaterData.append(data!)
            UserDefaults.standard.setSharedVideos(value: getWatchLaterData, ForKey: Local.SHARED_VIDEOS.shared_videos)
            self.view.makeToast("Added to watch later")
        }
        
        
        
    }
    
}
extension PlayVideo_NextToVC:UITableViewDelegate,UITableViewDataSource,ShowPresentControllerDelegate,IndexofCellDelegate,UISearchBarDelegate,ShowCreatePlayListDelegate,IndicatorInfoProvider{
 
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
            log.verbose("Index = \(Index)")
            setWatchLater(index: index!)
            log.verbose("getWatchSettings = \(UserDefaults.standard.getWatchLater(Key: Local.WATCH_LATER.watch_Later).count)")
        case 1:
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
                            vc.videoId = self.suggestedVideosArray[Index].id
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
        case 2:
            setNotInterested(index: index!)
            log.verbose("Index = \(Index)")
        case 3:
            self.shareVideo(stringURL: self.suggestedVideosArray[self.index!].videoLocation!)
            self.setSharedVideos(index: index!)
            log.verbose("Index = \(Index)")
        case 4:
            log.verbose("Index = \(Index)")
            let vc = storyboard.instantiateViewController(withIdentifier: "ReportVideoVC") as! ReportVideoVC
            vc.videoId = suggestedVideosArray[Index].id
            
            self.present(vc, animated: true, completion: nil)
        default:
            log.verbose("Something went wrong. Please try again Later!.")
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.suggestedVideosArray.count ?? 0
    }
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayVideo_TableCell") as! PlayVideo_TableCell
        cell.selectionStyle = .none
        cell.delegate = self
        cell.cellIndexDelegate = self
        cell.indexPath = indexPath.row
        let suggestedVideosObject = suggestedVideosArray[indexPath.row]
        cell.nameLabel.text = suggestedVideosObject.title!.htmlAttributedString ?? ""
        cell.usernameLabel.text = suggestedVideosObject.owner!.username!.htmlAttributedString ?? ""
        cell.viewsLabel.text = "\(suggestedVideosObject.views!.roundedWithAbbreviations ?? "") Views"
        cell.durationLabel.text = suggestedVideosObject.duration
        cell.durationView?.sizeThatFits(CGSize(width: (cell.durationLabel.frame.width) + 10, height: (cell.durationLabel.frame.height)))
        let url = URL.init(string:suggestedVideosObject.thumbnail!)
        cell.imageViewLabel.sd_setImage(with: url , placeholderImage: UIImage(named: "maxresdefault"))
        cell.imageViewLabel.layer.cornerRadius = 10
        cell.imageViewLabel.clipsToBounds = true
        if suggestedVideosObject.owner!.verified == 1{
            cell.isVerifiedLabel.isHidden = true
        }else{
            cell.isVerifiedLabel.isHidden = false
        }
        
        return cell
        
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
//        let vc = storyBoard.instantiateViewController(withIdentifier: "PlayVideoVC") as! PlayVideoVC
        let  objectToEncode =  self.suggestedVideosArray[indexPath.row]
        let data = try? PropertyListEncoder().encode(objectToEncode)
        self.delegate.playNextVideo(nextVideo:data!)
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
        
        
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
         return IndicatorInfo(title: "NEXT TO")
    }
    
}
