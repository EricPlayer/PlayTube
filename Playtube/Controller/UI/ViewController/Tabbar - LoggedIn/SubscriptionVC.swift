//
//  SubscriptionVC.swift
//  Playtube


import UIKit
import Async
import PlaytubeSDK

class SubscriptionVC: BaseViewController {
    
    @IBOutlet weak var showStack: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    var index:Int? = 0
    private var userId:Int? = nil
    private var sessionId:String? = nil
    private var subscribedChannelArray = [SubscriptionModel.Datum]()
    private var subscribedChannelVideosArray = [SubscribedChannelVideosModel.Datum]()
    private var appDelegate = UIApplication.shared.delegate as? AppDelegate
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
        self.tabBarController?.tabBar.isHidden = false
    }
    @IBAction func showChannelsPressed(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "SubscribeChannelVC") as! SubscribeChannelVC
        vc.ChannelsArray = subscribedChannelArray
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func fetchData(){
        if Reachability.isConnectedToNetwork(){
            self.showProgressDialog(text: "Loading...")
            Async.background({
                LibraryManager.instance.getSubscribedChannels(User_id: self.userId!, Session_Token: self.sessionId!, ChannelId: 1, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.subscribedChannelArray = (success?.data)!
                            self.collectionView.reloadData()
                            Async.background({
                                LibraryManager.instance.getSubscribedChannelsVideos(User_id: self.userId!, Session_Token: self.sessionId!, ChannelId: false,Limit:20, completionBlock: { (successV, sessionErrorV, errorV) in
                                    if successV != nil{
                                        
                                        Async.main({
                                            if self.subscribedChannelArray.isEmpty && self.subscribedChannelVideosArray.isEmpty{
                                                self.tableView.isHidden = true
                                                self.showStack.isHidden = false
                                            }else{
                                                log.verbose("success")
                                                self.subscribedChannelVideosArray = (successV?.data)!
                                               
                                                UserDefaults.standard.setSubscriptionImage(value: (successV?.data?.last?.thumbnail)!, ForKey: "librarySubscrptionImage")
                                            
                                                self.tableView.reloadData()
                                                self.dismissProgressDialog()
                                            }
                                            
                                            
                                            
                                        })
                                    }else if sessionErrorV != nil{
                                        Async.main({
                                            self.dismissProgressDialog()
                                            log.error("sessionError = \(sessionErrorV?.errors!.errorText)")
                                            self.view.makeToast(sessionErrorV?.errors!.errorText)
                                        })
                                        
                                    }else{
                                        Async.main({
                                            log.error("error = \(errorV?.localizedDescription)")
                                            self.view.makeToast(errorV?.localizedDescription)
                                            self.dismissProgressDialog()
                                        })
                                    }
                                })
                            })
                            log.debug("Success")
                        })
                    }else if sessionError != nil{
                        
                        Async.main({
                            self.dismissProgressDialog()
                            log.error("sessionError = \(sessionError?.errors!.errorText)")
                            self.view.makeToast(sessionError?.errors!.errorText)
                        })
                    }else {
                        Async.main({
                            log.error("error = \(error?.localizedDescription)")
                            self.view.makeToast(error?.localizedDescription)
                            self.dismissProgressDialog()
                        })
                        
                    }
                    
                })
                
            })
        }else {
            self.view.makeToast(InterNetError)
        }
        
    }
    private  func getUserSession(){
        log.verbose("getUserSession = \(UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session))")
        let localUserSessionData = UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session)
        self.userId = localUserSessionData[Local.USER_SESSION.user_id] as! Int
        self.sessionId = localUserSessionData[Local.USER_SESSION.session_id] as! String
    }
    private func NavigationbarConfiguration(){        self.navigationController?.isNavigationBarHidden = false
        self.title = "Subscription"
        let color = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color ]
        self.navigationController?.navigationBar.tintColor = color
        
    }
    private func setWatchLater(index:Int){
        log.verbose("Check = \(UserDefaults.standard.getWatchLater(Key: Local.WATCH_LATER.watch_Later))")
        let objectToEncode = self.subscribedChannelVideosArray[index]
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
      
            
            let objectToEncode = self.subscribedChannelVideosArray[index]
            let data = try? PropertyListEncoder().encode(objectToEncode)
            var getWatchLaterData = UserDefaults.standard.getNotInterested(Key: Local.NOT_INTERESTED.not_interested)
            getWatchLaterData.append(data!)
            UserDefaults.standard.setNotInterested(value: getWatchLaterData, ForKey: Local.NOT_INTERESTED.not_interested)
            self.subscribedChannelVideosArray.remove(at: index)
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
        
    
}
extension SubscriptionVC:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.subscribedChannelArray.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Subscription_CollectionCell", for: indexPath) as? Subscription_CollectionCell
        let subscribedChannelObject = self.subscribedChannelArray[indexPath.row]
        cell?.imageViewLabel.downloaded(from: subscribedChannelObject.avatar!)
        cell?.imageViewLabel.cornerRadiusV = (cell?.imageViewLabel.frame.height)! / 2
        cell?.usernameLabel.text = subscribedChannelObject.username!.htmlAttributedString
        if subscribedChannelObject.verified == 1{
            cell?.isVerifiedLabel.isHidden = false
        }else{
            cell?.isVerifiedLabel.isHidden = true
        }
        
        return cell!
    }
    
    func collectionView(collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let  cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Subscription_CollectionCell", for: indexPath) as? Subscription_CollectionCell
        return CGSize(width: (cell?.userNameStack.frame.width)!, height: 82)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ChannelDetailsVC") as! ChannelDetailsVC
        vc.channelId = self.subscribedChannelArray[indexPath.row].id
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
extension SubscriptionVC:UITableViewDelegate,UITableViewDataSource,ShowPresentControllerDelegate,IndexofCellDelegate,ShowCreatePlayListDelegate{
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
                            vc.videoId = self.subscribedChannelArray[Index].id
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
            self.shareVideo(stringURL: self.subscribedChannelVideosArray[self.index!].videoLocation!)
            log.verbose("Index = \(Index)")
        case 4:
            log.verbose("Index = \(Index)")
            let vc = storyboard.instantiateViewController(withIdentifier: "ReportVideoVC") as! ReportVideoVC
            
            vc.videoId = subscribedChannelVideosArray[Index].id
            self.present(vc, animated: true, completion: nil)
        default:
            log.verbose("Something went wrong. Please try again Later!.")
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.subscribedChannelVideosArray.count ?? 0
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Subscription_TableCell") as! Subscription_TableCell
        cell.selectionStyle = .none
        cell.delegate = self
        cell.cellIndexDelegate = self
        cell.indexPath = indexPath.row
        let subscribedChannelVideosObject = subscribedChannelVideosArray[indexPath.row]
        cell.nameLabel.text = subscribedChannelVideosObject.title!.htmlAttributedString ?? ""
        cell.usernameLabel.text = subscribedChannelVideosObject.owner!.username!.htmlAttributedString ?? ""
        cell.viewsLabel.text = "\(subscribedChannelVideosObject.views!.roundedWithAbbreviations ?? "") Views"
        cell.durationLabel.text = subscribedChannelVideosObject.duration ?? ""
          cell.durationView?.sizeThatFits(CGSize(width: (cell.durationLabel.frame.width) + 10, height: (cell.durationLabel.frame.height)))
        let url = URL.init(string:subscribedChannelVideosObject.thumbnail!)
        cell.imageViewLabel.sd_setImage(with: url , placeholderImage: UIImage(named: "maxresdefault"))
        cell.imageViewLabel.layer.cornerRadius = 10
        cell.imageViewLabel.clipsToBounds = true
        if subscribedChannelVideosObject.owner!.verified == 1{
            cell.isVerifiedLabel.isHidden = true
        }else{
            cell.isVerifiedLabel.isHidden = false
        }
        
        
        return cell
        
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "PlayVideoVC") as! PlayVideoVC
        let  objectToEncode =  self.subscribedChannelVideosArray[indexPath.row]
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
