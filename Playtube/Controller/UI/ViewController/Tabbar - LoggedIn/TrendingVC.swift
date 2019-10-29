//
//  TrendingVC.swift
//  Playtube


import UIKit
import Async
import SDWebImage
import DropDown
import CodableFirebase
import PlaytubeSDK

class TrendingVC: BaseViewController,UITextFieldDelegate {
    
    
    @IBOutlet weak var loginPersonBarBtn: UIBarButtonItem!
    @IBOutlet weak var SeachTableView: UITableView!
    @IBOutlet weak var TableView: UITableView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let moreDropdown = DropDown()
    var index:Int? = nil
    private var sessionStatus:Bool? = false
    
    private var status:Bool? = false
    private var trendingVideosArray = [TrendingModel.Datum]()
    private var searchVideosArray = [SearchModel.Datum]()
    private var userId:Int? = nil
    private var sessionId:String? = nil
    private var searchArray = [String]()
    private lazy var searchBar = UISearchBar(frame: .zero)
    private var searchActive:Bool? = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
         self.view.backgroundColor = AppSettings.appColor
        self.sessionStatus = UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session).isEmpty
        if sessionStatus!{
            self.fetchData()
            
        }else{
            self.getUserSession()
            self.fetchData()
        }
        
        
        self.TableView.separatorStyle = .none
        self.SeachTableView.separatorStyle = .none
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
       
        //        self.NavigationbarConfiguration()
        
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Keyboard Notifications
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            SeachTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.2, animations: {
            // For some reason adding inset in keyboardWillShow is animated by itself but removing is not, that's why we have to use animateWithDuration here
            self.SeachTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        })
    }
    
    
    @IBAction func loginPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ShowLoginPopVC") as! ShowLoginPopVC
            self.present(vc, animated: true, completion: nil)
    }
    @IBAction func chatsPressed(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        if self.sessionStatus!{
            let vc = storyboard.instantiateViewController(withIdentifier: "ShowLoginPopVC") as! ShowLoginPopVC
            self.present(vc, animated: true, completion: nil)
        }else{
            let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "ChatsVC") as! ChatsVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
       
        
    }
    private func fetchData(){
        for item in (self.appDelegate.appDelCategories?.keys)!{
            let singleValue = self.appDelegate.appDelCategories![item]
            self.searchArray.append(singleValue!)
        }
        if Reachability.isConnectedToNetwork(){
            self.showProgressDialog(text: "Loading...")
            Async.background({
                TrendingManager.instance.getTrendingData(User_id: self.userId ?? 0, Session_Token: self.sessionId ?? "") { (Success, AuthError, error) in
                    if Success != nil{
                        Async.main({
                            log.verbose("SUCCESS")
                            self.trendingVideosArray = Success?.data ?? []
                            self.TableView.reloadData()
                            self.dismissProgressDialog()
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
    private  func getUserSession(){
        log.verbose("getUserSession = \(UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session))")
        let localUserSessionData = UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session)
        self.userId = localUserSessionData[Local.USER_SESSION.user_id] as! Int
        self.sessionId = localUserSessionData[Local.USER_SESSION.session_id] as! String
    }
    private func searchVideos(searchText:String){
        self.trendingVideosArray.removeAll()
        self.TableView.reloadData()
        self.showProgressDialog(text: "Loading...")
        if Reachability.isConnectedToNetwork(){
            Async.background({
                SearchManager.instance.searchVideo(User_id: self.userId ?? 0, Session_Token: self.sessionId ?? "", SearchText: searchText) { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.SeachTableView.isHidden = true
                            self.TableView.isHidden = false
                            self.searchActive = true
                            self.searchVideosArray = (success?.data)!
                            self.TableView.reloadData()
                            self.dismissProgressDialog()
                        })
                        
                    }else if sessionError != nil{
                        Async.main({
                            self.SeachTableView.isHidden = true
                            self.TableView.isHidden = false
                            self.searchActive = false
                            self.dismissProgressDialog()
                            self.view.makeToast(sessionError?.errors!.errorText)
                        })
                        
                    }else{
                        Async.main({
                            self.SeachTableView.isHidden = true
                            self.TableView.isHidden = false
                            self.searchActive = false
                            self.dismissProgressDialog()
                            self.view.makeToast(error?.localizedDescription)
                        })
                    }
                }
                
            })
        }else{
            self.view.makeToast(InterNetError)
        }
        
        
    }
    private func setWatchLater(index:Int){
        log.verbose("Check = \(UserDefaults.standard.getWatchLater(Key: Local.WATCH_LATER.watch_Later))")
        if searchActive!{
                let objectToEncode = self.searchVideosArray[index]
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
            
                let objectToEncode = self.trendingVideosArray[index]
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
        if searchActive!{
            let objectToEncode = self.searchVideosArray[index]
            let data = try? PropertyListEncoder().encode(objectToEncode)
             var getWatchLaterData = UserDefaults.standard.getNotInterested(Key: Local.NOT_INTERESTED.not_interested)
                getWatchLaterData.append(data!)
                UserDefaults.standard.setNotInterested(value: getWatchLaterData, ForKey: Local.NOT_INTERESTED.not_interested)
            self.searchVideosArray.remove(at: index)
            self.SeachTableView.reloadData()
                self.view.makeToast("Video removed from the list")
            
        }else{
            
            let objectToEncode = self.trendingVideosArray[index]
            let data = try? PropertyListEncoder().encode(objectToEncode)
            var getWatchLaterData = UserDefaults.standard.getNotInterested(Key: Local.NOT_INTERESTED.not_interested)
            getWatchLaterData.append(data!)
            UserDefaults.standard.setNotInterested(value: getWatchLaterData, ForKey: Local.NOT_INTERESTED.not_interested)
            self.trendingVideosArray.remove(at: index)
            self.TableView.reloadData()
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
        if searchActive!{
            let objectToEncode = self.searchVideosArray[index]
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
            let objectToEncode = self.trendingVideosArray[index]
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
}
extension TrendingVC:UITableViewDelegate,UITableViewDataSource,ShowPresentControllerDelegate,IndexofCellDelegate,ShowCreatePlayListDelegate{
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
                                if self.searchActive!{
                                    let vc = storyboard.instantiateViewController(withIdentifier: "SelectAPlaylistVC") as! SelectAPlaylistVC
                                    vc.playlistArray = (success?.myAllPlaylists)!
                                    vc.delegate = self
                                    vc.videoId = self.searchVideosArray[Index].id
                                    self.present(vc, animated: true, completion: nil)
                                }else{
                                    let vc = storyboard.instantiateViewController(withIdentifier: "SelectAPlaylistVC") as! SelectAPlaylistVC
                                    vc.playlistArray = (success?.myAllPlaylists)!
                                    vc.delegate = self
                                    vc.videoId = self.trendingVideosArray[Index].id
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
            if searchActive!{
                self.shareVideo(stringURL: self.searchVideosArray[self.index!].videoLocation!)
                self.setSharedVideos(index: index!)
            }else{
                self.shareVideo(stringURL: self.trendingVideosArray[self.index!].videoLocation!)
                self.setSharedVideos(index: index!)
            }
            log.verbose("Index = \(Index)")
        case 4:
            log.verbose("Index = \(Index)")
            if sessionStatus!{
                let vc = storyboard.instantiateViewController(withIdentifier: "ShowLoginPopVC") as! ShowLoginPopVC
                self.present(vc, animated: true, completion: nil)
            }else{
                let vc = storyboard.instantiateViewController(withIdentifier: "ReportVideoVC") as! ReportVideoVC
                if searchActive!{
                    vc.videoId = self.searchVideosArray[Index].id
                }else{
                    vc.videoId = self.trendingVideosArray[Index].id
                }
                
                self.present(vc, animated: true, completion: nil)
            }
        default:
            log.verbose("Something went wrong. Please try again Later!.")
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive!{
            return self.searchVideosArray.count ?? 0
        }else{
            if tableView == TableView{
                
                return self.trendingVideosArray.count ?? 0
            }
            else{
                return self.searchArray.count ?? 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searchActive!{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Trending_TableCell") as! Trending_TableCell
            cell.selectionStyle = .none
            cell.delegate = self
            cell.cellIndexDelegate = self
            cell.indexPath = indexPath.row
            let searchVideosObject = searchVideosArray[indexPath.row]
            cell.nameLabel.text = searchVideosObject.title!.htmlAttributedString ?? ""
            cell.usernameLabel.text = searchVideosObject.owner!.username!.htmlAttributedString ?? ""
            cell.viewsLabel.text = "\(searchVideosObject.views!.roundedWithAbbreviations ?? "") Views"
            cell.durationLabel.text = searchVideosObject.duration ?? ""
              cell.durationView?.sizeThatFits(CGSize(width: (cell.durationLabel.frame.width) + 10, height: (cell.durationLabel.frame.height)))
            let url = URL.init(string:searchVideosObject.thumbnail!)
            cell.imageViewLabel.sd_setImage(with: url , placeholderImage: UIImage(named: "maxresdefault"))
            cell.imageViewLabel.layer.cornerRadius = 10
            cell.imageViewLabel.clipsToBounds = true
            if searchVideosObject.owner!.verified == 1{
                cell.isVerifiedLabel.isHidden = true
            }else{
                cell.isVerifiedLabel.isHidden = false
            }
            
            return cell
        }else{
            if tableView == TableView{
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "Trending_TableCell") as! Trending_TableCell
                cell.selectionStyle = .none
                cell.delegate = self
                cell.cellIndexDelegate = self
                cell.indexPath = indexPath.row
                let trendingVideosObject = trendingVideosArray[indexPath.row]
                cell.nameLabel.text = trendingVideosObject.title!.htmlAttributedString  ?? ""
                cell.usernameLabel.text = trendingVideosObject.owner!.username!.htmlAttributedString ?? ""
                cell.viewsLabel.text = "\(trendingVideosObject.views!.roundedWithAbbreviations ?? "") Views"
                cell.durationLabel.text = trendingVideosObject.duration ?? ""
                  cell.durationView?.sizeThatFits(CGSize(width: (cell.durationLabel.frame.width) + 10, height: (cell.durationLabel.frame.height)))
                let url = URL.init(string:trendingVideosObject.thumbnail!)
                cell.imageViewLabel.sd_setImage(with: url , placeholderImage: UIImage(named: "maxresdefault"))
                cell.imageViewLabel.layer.cornerRadius = 10
                cell.imageViewLabel.clipsToBounds = true
                if trendingVideosObject.owner!.verified == 1{
                    cell.isVerifiedLabel.isHidden = true
                }else{
                    cell.isVerifiedLabel.isHidden = false
                }
                
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "Search_TableCell") as! Search_TableCell
                let searchString = searchArray[indexPath.row]
                cell.nameLabel.text = searchString.htmlAttributedString
                return cell
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == SeachTableView{
            self.trendingVideosArray.removeAll()
            self.SeachTableView.isHidden = true
            self.TableView.isHidden = false
            searchBar.setShowsCancelButton(false, animated: true)
            searchBar.resignFirstResponder()
            let searchText = searchArray[indexPath.row].htmlAttributedString
           let converted = searchText?.replacingOccurrences(of: " ", with: "")
            self.searchVideos(searchText: converted!)
        }else{
            if searchActive!{
                log.verbose("Next Controller to view")
                let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
                let vc = storyBoard.instantiateViewController(withIdentifier: "PlayVideoVC") as! PlayVideoVC
                let  objectToEncode =  self.searchVideosArray[indexPath.row]
                let data = try? PropertyListEncoder().encode(objectToEncode)
                vc.videoObject = data
                self.appDelegate.videoId  = objectToEncode.videoID
                self.appDelegate.commentVideoId = objectToEncode.id
                self.navigationController?.pushViewController(vc, animated: true)
            }else{
                log.verbose("Next Controller to view")
                let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
                let vc = storyBoard.instantiateViewController(withIdentifier: "PlayVideoVC") as! PlayVideoVC
                let  objectToEncode =  self.trendingVideosArray[indexPath.row]
                let data = try? PropertyListEncoder().encode(objectToEncode)
                vc.videoObject = data
                self.appDelegate.videoId  = objectToEncode.videoID
                self.appDelegate.commentVideoId = objectToEncode.id
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
        }
        

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == TableView{
            return 110
        }else{
            return 60
        }
        
        
    }
}

extension TrendingVC: UISearchBarDelegate
{
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        //Show Cancel
        searchBar.setShowsCancelButton(true, animated: true)
        searchBar.tintColor = .white
        self.TableView.isHidden = true
        self.SeachTableView.isHidden = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
       
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        //Hide Cancel
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        self.TableView.isHidden = false
        self.SeachTableView.isHidden = true
        if searchBar.text!.count < 4{
            self.view.makeToast("Keyword should not be less than 4")
            
        }else{
             log.verbose("searchBar text = \(searchBar.text)")
            let searchText = searchBar.text ?? ""
            let converted = searchText.replacingOccurrences(of: " ", with: "")
            self.searchVideos(searchText:converted)
        }
      
       
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        //Hide Cancel
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = String()
        searchBar.resignFirstResponder()
        self.TableView.isHidden = false
        self.SeachTableView.isHidden = true
      
    }
}
