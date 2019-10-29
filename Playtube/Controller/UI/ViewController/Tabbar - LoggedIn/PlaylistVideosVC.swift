//
//  PlaylistVideosVC.swift
//  Playtube


import UIKit
import Async
import PlaytubeSDK

class PlaylistVideosVC: BaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var showStack: UIStackView!
    var index:Int? = nil
    var listId:String? = ""
    var playlistName:String? = ""
    private var status:Bool? = false
    private var userId:Int? = nil
    private var sessionId:String? = nil
    private var playlistVideosArray = [PlaylistVideosModel.Datum]()
    private var appDelegate = UIApplication.shared.delegate as? AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
          self.view.backgroundColor = AppSettings.appColor
        self.getUserSession()
        self.fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NavigationbarConfiguration()
    }
    
    
    private func fetchData(){
        if Reachability.isConnectedToNetwork(){
            self.showProgressDialog(text: "Loading...")
            log.verbose("ListID for this is = \(listId)")
            Async.background({
                PlaylistManager.instance.getPlaylistVideos(User_id: self.userId!, Session_Token: self.sessionId!, List_Id: self.listId ?? "", Limit: 10, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            log.verbose("SUCCESS")
                            self.playlistVideosArray = success?.data ?? []
                            if !self.playlistVideosArray.isEmpty{
                                self.collectionView.reloadData()
                                self.showStack.isHidden = true
                                self.collectionView.isHidden = false
                                self.dismissProgressDialog()
                            }else{
                                self.showStack.isHidden = false
                                self.collectionView.isHidden = true
                                self.dismissProgressDialog()
                            }
                            
                        })
                    }else if sessionError != nil{
                        self.view.makeToast(sessionError?.errors!.errorText)
                        self.dismissProgressDialog()
                        
                    }else{
                        self.view.makeToast(error?.localizedDescription)
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
    private func NavigationbarConfiguration(){
        self.navigationController?.isNavigationBarHidden = false
        self.title = self.playlistName
        let color = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color ]
        self.navigationController?.navigationBar.tintColor = color
        
    }
    private func setWatchLater(index:Int){
        log.verbose("Check = \(UserDefaults.standard.getWatchLater(Key: Local.WATCH_LATER.watch_Later))")
        let objectToEncode = self.playlistVideosArray[index]
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
        
        
        let objectToEncode = self.playlistVideosArray[index]
        let data = try? PropertyListEncoder().encode(objectToEncode)
        var getWatchLaterData = UserDefaults.standard.getNotInterested(Key: Local.NOT_INTERESTED.not_interested)
        getWatchLaterData.append(data!)
        UserDefaults.standard.setNotInterested(value: getWatchLaterData, ForKey: Local.NOT_INTERESTED.not_interested)
        self.playlistVideosArray.remove(at: index)
        self.collectionView.reloadData()
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
        let objectToEncode = self.playlistVideosArray[index]
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
extension PlaylistVideosVC:UICollectionViewDelegate,UICollectionViewDataSource,ShowPresentControllerDelegate,IndexofCellDelegate,ShowCreatePlayListDelegate{
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
                            vc.videoId = self.playlistVideosArray[Index].id
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
            self.shareVideo(stringURL: self.playlistVideosArray[self.index!].videos!.videoLocation!)
            self.setSharedVideos(index: index!)
            log.verbose("Index = \(Index)")
        case 4:
            log.verbose("Index = \(Index)")
                        let vc = storyboard.instantiateViewController(withIdentifier: "ReportVideoVC") as! ReportVideoVC
            
                    vc.videoId = self.playlistVideosArray[self.index!].id
                    self.present(vc, animated: true, completion: nil)
        default:
            log.verbose("Something went wrong. Please try again Later!.")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return self.playlistVideosArray.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlaylistVideos_CollectionCell", for: indexPath) as? PlaylistVideos_CollectionCell
       
        cell!.delegate = self
        cell!.cellIndexDelegate = self
        cell!.indexPath = indexPath.row
        cell?.TemperatureDropDownFunc()
        let playlistVideossObject = self.playlistVideosArray[indexPath.row]
        cell?.nameLabel.text = playlistVideossObject.videos!.title!.htmlAttributedString ?? ""
        cell?.usernameLabel.text = playlistVideossObject.videos!.owner!.username!.htmlAttributedString ?? ""
        cell?.viewsLabel.text = "\(playlistVideossObject.videos!.views!.roundedWithAbbreviations ?? "") Views"
        cell!.durationLabel.text = playlistVideossObject.videos!.duration
        cell!.durationView?.sizeThatFits(CGSize(width: ((cell?.durationLabel.frame.width)!) + 10, height: ((cell?.durationLabel!.frame.height)!)))
        let url = URL.init(string:playlistVideossObject.videos!.thumbnail!)
        let urlProfile = URL.init(string:playlistVideossObject.videos!.owner!.avatar!)
        cell?.imageViewLabel.sd_setImage(with: url , placeholderImage: UIImage(named: "maxresdefault"))
        cell?.profileImageViewLabel.sd_setImage(with: urlProfile , placeholderImage: UIImage(named: "maxresdefault"))
        cell?.imageViewLabel.layer.cornerRadius = 10
        cell?.imageViewLabel.clipsToBounds = true
        cell?.profileImageViewLabel.layer.cornerRadius = (cell?.profileImageViewLabel.frame.height)! / 2
        cell?.profileImageViewLabel.clipsToBounds = true
        if playlistVideossObject.videos!.owner!.verified == 1{
            cell?.isVerifiedLabel.isHidden = true
        }else{
            cell?.isVerifiedLabel.isHidden = false
        }
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "PlayVideoVC") as! PlayVideoVC
        let  objectToEncode =  self.playlistVideosArray[indexPath.row]
//        log.verbose("ObjectToEncode = \(objectToEncode.videos)")
//        let data = try? PropertyListEncoder().encode(objectToEncode)
//        vc.videoObject = data
        vc.playListVideoConvertedObject = objectToEncode
        self.appDelegate!.videoId  = objectToEncode.videos?.videoID
        self.appDelegate!.commentVideoId = objectToEncode.videos?.id
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
