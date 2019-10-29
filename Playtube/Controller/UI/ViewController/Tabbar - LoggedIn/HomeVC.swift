//
//  HomeVC.swift
//  Playtube


import UIKit
import Async
import MMPlayerView
import PlaytubeSDK

class HomeVC: BaseViewController {
    @IBOutlet weak var latestVideosStack: UIStackView!
    
    @IBOutlet weak var topVideosStack: UIStackView!
    @IBOutlet weak var collectionView3: BJAutoScrollingCollectionView!
    @IBOutlet weak var collectionView1: UICollectionView!
    @IBOutlet weak var collectionView4: UICollectionView!
    @IBOutlet weak var collectionView2: UICollectionView!
    @IBOutlet weak var collectionView3_FlowLayout: UICollectionViewFlowLayout!
    
    var x = 1
    var index:Int? = nil
    var featuredVideosArray = [Home.Featured]()
    var topVidesArray = [Home.Featured]()
    var latestVideosArray = [Home.Featured]()
    var otherVideosArray = [Home.Featured]()
    private var userId:Int? = nil
    private var sessionId:String? = nil
     private var sessionStatus:Bool? = false
    private let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    lazy var mmPlayerLayer: MMPlayerLayer = {
        let l = MMPlayerLayer()
        
        l.cacheType = .memory(count: 5)
        l.coverFitType = .fitToPlayerView
        l.videoGravity = AVLayerVideoGravity.resizeAspect
        l.replace(cover: CoverA.instantiateFromNib())
        return l
    }()
  
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.view.backgroundColor = AppSettings.appColor
          self.sessionStatus = UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session).isEmpty
        if UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session).isEmpty{
            log.verbose("getUserSession = \(UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session))")
            self.fetchData(UserID:  0, SessionID: "")
        }else{
            log.verbose("getUserSession = \(UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session))")
            self.getUserSession()
            self.fetchData(UserID: self.userId ?? 0, SessionID: sessionId ?? "")
        }
        
        self.collectionView3_FlowLayout.minimumInteritemSpacing = 0
        self.collectionView3_FlowLayout.minimumLineSpacing = 0
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    @IBAction func topVideosPressed(_ sender: Any) {
        log.verbose("TopVideosPresses")
        let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "TopAndLatestVideosVC") as! TopAndLatestVideosVC
//        vc.getStringStatus = true
//        vc.topVidesArray = self.topVidesArray
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func latestReleasedPressed(_ sender: Any) {
        log.verbose("latestReleasedPressed")
        let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "TopAndLatestVideosVC") as! TopAndLatestVideosVC
//        vc.getStringStatus = false
//        vc.latestVideosArray = self.latestVideosArray
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func fetchData(UserID:Int,SessionID:String){
        if Reachability.isConnectedToNetwork(){
            self.showProgressDialog(text: "Loading")
            Async.background{
                HomeManager.instance.getHomeDataWithLimit(User_id: UserID, Session_Token: SessionID, Limit: 20) { (Response, responseError, error) in
                    if Response != nil{
                        Async.main{
                            self.featuredVideosArray = (Response?.data!.featured)!
                            
                            for video in (Response?.data!.featured)!{
                                    if (self.featuredVideosArray.count) <= 13{
                                        self.featuredVideosArray.append(video)
                                    }else{
                                         self.otherVideosArray.append(video)
                                    }
                                   
                                }
                            for video in (Response?.data!.top)!{
                                if (self.topVidesArray.count) <= 13{
                                    self.topVidesArray.append(video)
                                }else{
                                    self.otherVideosArray.append(video)
                                }
                                
                            }
                            for video in (Response?.data!.latest)!{
                                if (self.latestVideosArray.count) <= 13{
                                    self.latestVideosArray.append(video)
                                }else{
                                    self.otherVideosArray.append(video)
                                }
                                
                            }
                            
//                            self.topVidesArray = (Response?.data.top)!
//                            self.latestVideosArray = (Response?.data.latest)!
                            self.collectionView1.reloadData()
                            self.collectionView2.reloadData()
                            self.collectionView3.reloadData()
                            self.collectionView4.reloadData()
                            self.dismissProgressDialog()
                            self.topVideosStack.isHidden = false
                            self.latestVideosStack.isHidden = false
                            self.setTimer()
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
    
    func setTimer() {
        let _ = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(HomeVC.autoScroll), userInfo: nil, repeats: true)
    }
    
    
    
    @objc func autoScroll() {
        if self.x < self.featuredVideosArray.count {
            let indexPath = IndexPath(item: x, section: 0)
            self.collectionView3.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            self.x = self.x + 1
        } else {
            self.x = 0
            self.collectionView3.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
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
        let objectToEncode = self.otherVideosArray[index]
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
    private func setSharedVideos(index:Int){
        log.verbose("Check = \(UserDefaults.standard.getSharedVideos(Key: Local.SHARED_VIDEOS.shared_videos))")
        let objectToEncode = self.otherVideosArray[index]
        let data = try? PropertyListEncoder().encode(objectToEncode)
        var getWatchLaterData = UserDefaults.standard.getSharedVideos(Key: Local.SHARED_VIDEOS.shared_videos)
        if UserDefaults.standard.getSharedVideos(Key: Local.SHARED_VIDEOS.shared_videos).contains(data!){
            self.view.makeToast("Already added in shared Videos")
            
        }else{
            getWatchLaterData.append(data!)
            UserDefaults.standard.setSharedVideos(value: getWatchLaterData, ForKey: Local.SHARED_VIDEOS.shared_videos)
            self.view.makeToast("Added to shared Vides")
        }
        
        
        
    }
    
    private func setNotInterested(index:Int){
        log.verbose("Check = \(UserDefaults.standard.getNotInterested(Key: Local.NOT_INTERESTED.not_interested))")
        
        
        let objectToEncode = self.otherVideosArray[index]
        let data = try? PropertyListEncoder().encode(objectToEncode)
        var getWatchLaterData = UserDefaults.standard.getNotInterested(Key: Local.NOT_INTERESTED.not_interested)
        getWatchLaterData.append(data!)
        UserDefaults.standard.setNotInterested(value: getWatchLaterData, ForKey: Local.NOT_INTERESTED.not_interested)
        self.otherVideosArray.remove(at: index)
        self.collectionView4.reloadData()
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
    
}
extension HomeVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,ShowPresentControllerDelegate,IndexofCellDelegate,ShowCreatePlayListDelegate{
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
            if sessionStatus!{
                let vc = storyboard.instantiateViewController(withIdentifier: "ShowLoginPopVC") as! ShowLoginPopVC
                self.present(vc, animated: true, completion: nil)
            }else{
                log.verbose("Index = \(Index)")
                setWatchLater(index: index!)
                log.verbose("getWatchSettings = \(UserDefaults.standard.getWatchLater(Key: Local.WATCH_LATER.watch_Later).count)")
            }
        case 1:
            if sessionStatus!{
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
                                    vc.videoId = self.otherVideosArray[Index].id
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
           
            self.shareVideo(stringURL: self.otherVideosArray[self.index!].videoLocation!)
            self.setSharedVideos(index: index!)
            
            log.verbose("Index = \(Index)")
        case 4:
            log.verbose("Index = \(Index)")
            if sessionStatus!{
                let vc = storyboard.instantiateViewController(withIdentifier: "ShowLoginPopVC") as! ShowLoginPopVC
                self.present(vc, animated: true, completion: nil)
            }else{
                let vc = storyboard.instantiateViewController(withIdentifier: "ReportVideoVC") as! ReportVideoVC
               
                    vc.videoId = self.otherVideosArray[Index].id
                
                
                self.present(vc, animated: true, completion: nil)
            }
        default:
            log.verbose("Something went wrong. Please try again Later!.")
        }
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionView1{
            return self.topVidesArray.count ?? 0
        }else if collectionView == collectionView2{
            return self.latestVideosArray.count ?? 0
        }else if collectionView == collectionView3{
            return self.featuredVideosArray.count ?? 0
        }else{
            return self.otherVideosArray.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collectionView1{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Home_CollectionCell", for: indexPath) as! Home_CollectionCell
            let singleVideoObject = topVidesArray[indexPath.row]
            cell.nameLabel.text = singleVideoObject.title!.htmlAttributedString
            cell.imageViewLabel.downloaded(from: singleVideoObject.thumbnail!)
            cell.viewsLabel.text = "\(singleVideoObject.views!.roundedWithAbbreviations) Views"
            cell.userNamelabel.text = singleVideoObject.owner!.username!.htmlAttributedString
            cell.durationLabel.text = singleVideoObject.duration
             cell.durationView?.sizeThatFits(CGSize(width: (cell.durationLabel.frame.width) + 10, height: (cell.durationLabel.frame.height)))
            if singleVideoObject.owner!.verified == 1{
                cell.isVerifiedLabel.isHidden = true
            }else{
                cell.isVerifiedLabel.isHidden = false
            }
            
            return cell
        }else if collectionView == collectionView2{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Home_CollectionCell2", for: indexPath) as! Home_CollectionCell2
            let singleVideoObject = latestVideosArray[indexPath.row]
            cell.nameLabel.text = singleVideoObject.title!.htmlAttributedString
            cell.imageViewLabel.downloaded(from: singleVideoObject.thumbnail!)
            cell.viewsLabel.text = "\(singleVideoObject.views!.roundedWithAbbreviations) Views"
            cell.userNamelabel.text = singleVideoObject.owner!.username!.htmlAttributedString
            cell.durationLabel.text = singleVideoObject.duration
            cell.durationView?.sizeThatFits(CGSize(width: (cell.durationLabel.frame.width) + 10, height: (cell.durationLabel.frame.height)))
            if singleVideoObject.owner!.verified == 1{
                cell.isVerifiedLabel.isHidden = true
            }else{
                cell.isVerifiedLabel.isHidden = false
            }
            return cell
        }else if collectionView == collectionView3{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Home_CollectionCell3", for: indexPath) as! Home_CollectionCell3
            let singleVideoObject = featuredVideosArray[indexPath.row]
            cell.nameLabel.text = singleVideoObject.title!.htmlAttributedString
            cell.imageViewLabel.downloaded(from: singleVideoObject.thumbnail!)
            cell.profileImageViewLabel.downloaded(from: singleVideoObject.owner!.avatar!)
            cell.userNamelabel.text = singleVideoObject.owner!.username!.htmlAttributedString
            
            return cell
            
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Home_CollectionCell4", for: indexPath) as? Home_CollectionCell4
            
            cell!.delegate = self
            cell!.cellIndexDelegate = self
            cell!.indexPath = indexPath.row
            cell?.TemperatureDropDownFunc()
            let otherVideossObject = self.otherVideosArray[indexPath.row]
            cell?.nameLabel.text = otherVideossObject.title!.htmlAttributedString ?? ""
            cell?.usernameLabel.text = otherVideossObject.owner!.username!.htmlAttributedString ?? ""
            cell?.viewsLabel.text = "\(otherVideossObject.views!.roundedWithAbbreviations ?? "") Views"
            cell?.durationLabel.text = otherVideossObject.duration ?? ""
            cell?.viewsLabel.sizeThatFits(CGSize(width: (cell?.durationLabel.frame.width)! + 10, height: (cell?.durationLabel.frame.height)!))
            let url = URL.init(string:otherVideossObject.thumbnail!)
            let urlProfile = URL.init(string:otherVideossObject.owner!.avatar!)
            cell?.imageViewLabel.sd_setImage(with: url , placeholderImage: UIImage(named: "maxresdefault"))
            cell?.profileImageViewLabel.sd_setImage(with: urlProfile , placeholderImage: UIImage(named: "maxresdefault"))
            cell?.imageViewLabel.layer.cornerRadius = 10
            cell?.imageViewLabel.clipsToBounds = true
            cell?.profileImageViewLabel.layer.cornerRadius = (cell?.profileImageViewLabel.frame.height)! / 2
            cell?.profileImageViewLabel.clipsToBounds = true
            if otherVideossObject.owner!.verified == 1{
                cell?.isVerifiedLabel.isHidden = true
            }else{
                cell?.isVerifiedLabel.isHidden = false
            }
            return cell!
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == collectionView1{
            return CGSize(width: 160.0, height: 247.0)
        }else if collectionView == collectionView2{
            return CGSize(width: 160.0, height: 247.0)
            
        }else {
            return CGSize(width: 372.0, height: 295.0)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "PlayVideoVC") as! PlayVideoVC
        let playNextToVc = storyBoard.instantiateViewController(withIdentifier: "PlayVideo_NextToVC") as! PlayVideo_NextToVC
        if collectionView == collectionView1{
            let  objectToEncode =  self.topVidesArray[indexPath.row]
            let data = try? PropertyListEncoder().encode(objectToEncode)
            vc.videoObject = data
            self.appDelegate?.videoId = objectToEncode.videoID
            self.appDelegate?.commentVideoId = objectToEncode.id
//            playNextToVc.videoId = objectToEncode.videoID
        }else if collectionView == collectionView2{
            let  objectToEncode =  self.latestVideosArray[indexPath.row]
            let data = try? PropertyListEncoder().encode(objectToEncode)
            vc.videoObject = data
            self.appDelegate?.videoId  = objectToEncode.videoID
            self.appDelegate?.commentVideoId = objectToEncode.id
            
//            playNextToVc.videoId = objectToEncode.videoID
        }else if collectionView == collectionView3{
            let  objectToEncode =  self.featuredVideosArray[indexPath.row]
            let data = try? PropertyListEncoder().encode(objectToEncode)
            vc.videoObject = data
//            playNextToVc.videoId = objectToEncode.videoID
            self.appDelegate?.videoId  = objectToEncode.videoID
          self.appDelegate?.commentVideoId = objectToEncode.id
        }else{
            let  objectToEncode =  self.otherVideosArray[indexPath.row]
            let data = try? PropertyListEncoder().encode(objectToEncode)
            vc.videoObject = data
            //            playNextToVc.videoId = objectToEncode.videoID
            self.appDelegate?.videoId  = objectToEncode.videoID
            self.appDelegate?.commentVideoId = objectToEncode.id
            
        }
       self.navigationController?.pushViewController(vc, animated: true)
//        self.present(vc, animated: true, completion: nil)
    }
    
}
extension HomeVC: MMPlayerFromProtocol {
    var passPlayer: MMPlayerLayer {
        return self.mmPlayerLayer
    }
   
    
    // when second controller pop or dismiss, this help to put player back to where you want
    // original was player last view ex. it will be nil because of this view on reuse view
    func backReplaceSuperView(original: UIView?) -> UIView? {
        return original
    }

//    // add layer to temp view and pass to another controller
//    var passPlayer: MMPlayerLayer {
//        return self.mmPlayerLayer
//    }
//    // current playview is cell.image hide prevent ui error
    func transitionWillStart() {
//        self.mmPlayerLayer.playView?.isHidden = true
    }
    // show cell.image
    func transitionCompleted() {
//        self.mmPlayerLayer.playView?.isHidden = false
    }
  
    func presentedView(isShrinkVideo: Bool) {
        self.collectionView2.visibleCells.forEach {
            if ($0 as? Home_CollectionCell2)?.imageViewLabel.isHidden == true && isShrinkVideo {
                ($0 as? Home_CollectionCell2)?.imageViewLabel.isHidden = false
               
            }
        }
    }


}
