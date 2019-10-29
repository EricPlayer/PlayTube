//
//  LibrarySelectVC.swift
//  Playtube

import UIKit
import  Async
import PlaytubeSDK

class LibrarySelectVC: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var noVideosShowStack: UIStackView!
    var index:Int? = 0
    var getStringStatus:String? = nil
    private var userId:Int? = nil
    private var sessionId:String? = nil
    private var getLikedVideosArray = [LibraryModel.Datum]()
     private var getRecentlyWatchVideosArray = [RecentlyWatchModel.Datum]()
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
    self.showProgressDialog(text: "Loading...")
        if self.getStringStatus == "Watch later"{
       self.noVideosShowStack.isHidden = false
        }else if  self.getStringStatus == "Recently Watched"{
            Async.background({
            LibraryManager.instance.recentlyWatchedVideos(User_id: self.userId!, Session_Token: self.sessionId!, completionBlock: { (success, sessionError, error) in
                if success != nil {
                    Async.main({
                        
                        self.getRecentlyWatchVideosArray = (success?.data)!
                        if self.self.getRecentlyWatchVideosArray.isEmpty{
                            self.tableView.isHidden = true
                            self.noVideosShowStack.isHidden = false
                             self.dismissProgressDialog()
                        }else{
                            UserDefaults.standard.setRecentWatchImage(value: (success?.data?.last?.thumbnail)!, ForKey: "libraryRecentlyWatchedImage")
                            self.tableView.isHidden = false
                            self.noVideosShowStack.isHidden = true
                            self.dismissProgressDialog()
                           self.tableView.reloadData()
                        }
                       
                        
                    })
                }else if sessionError != nil{
                    Async.main{
                        log.error("sessionError = \(sessionError?.errors!.errorText)")
                        self.view.makeToast(sessionError?.errors!.errorText)
                        self.dismissProgressDialog()
                    }
                }else{
                    Async.main({
                        log.error("error = \(error?.localizedDescription)")
                        self.dismissProgressDialog()
                    })
                }
            })
        })
         
        }else{
            Async.background({
                LibraryManager.instance.getLikedVideos(User_id: self.userId!, Session_Token: self.sessionId!, completionBlock: { (success, sessionError, error) in
                    if success != nil {
                        Async.main({
                            self.getLikedVideosArray = (success?.data)!
                            if self.self.getLikedVideosArray.isEmpty{
                                self.tableView.isHidden = true
                                self.noVideosShowStack.isHidden = false
                                self.dismissProgressDialog()
                            }else{
                                UserDefaults.standard.setLikedImage(value: (self.getLikedVideosArray.last?.thumbnail)!, ForKey: "libraryLikedVideosImage")
                                self.tableView.isHidden = false
                                self.noVideosShowStack.isHidden = true
                                self.dismissProgressDialog()
                                self.tableView.reloadData()
                            }
                        })
                    }else if sessionError != nil{
                        Async.main{
                            log.error("sessionError = \(sessionError?.errors!.errorText)")
                            self.view.makeToast(sessionError?.errors!.errorText)
                            self.dismissProgressDialog()
                        }
                    }else{
                        Async.main({
                            log.error("error = \(error?.localizedDescription)")
                              self.dismissProgressDialog()
                        })
                    }
                })
            })
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
        if self.getStringStatus == "Watch later"{
            self.title = "Watch later Videos"
        }else if  self.getStringStatus == "Recently Watched"{
            self.title = "Recently Watched"
        }else{
            self.title = "Liked Videos"
        }
        let color = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color ]
        self.navigationController?.navigationBar.tintColor = color
        
    }
    private func setWatchLater(index:Int){
        log.verbose("Check = \(UserDefaults.standard.getWatchLater(Key: Local.WATCH_LATER.watch_Later))")
        if !getLikedVideosArray.isEmpty{
            let objectToEncode = self.getLikedVideosArray[index]
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
            
            let objectToEncode = self.getRecentlyWatchVideosArray[index]
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
        if !self.getLikedVideosArray.isEmpty{
            
            let objectToEncode = self.getLikedVideosArray[index]
            let data = try? PropertyListEncoder().encode(objectToEncode)
            var getWatchLaterData = UserDefaults.standard.getNotInterested(Key: Local.NOT_INTERESTED.not_interested)
            getWatchLaterData.append(data!)
            UserDefaults.standard.setNotInterested(value: getWatchLaterData, ForKey: Local.NOT_INTERESTED.not_interested)
            self.getLikedVideosArray.remove(at: index)
            self.tableView.reloadData()
            self.view.makeToast("Video removed from the list")
        }else{
           
            let objectToEncode = self.getRecentlyWatchVideosArray[index]
            let data = try? PropertyListEncoder().encode(objectToEncode)
            var getWatchLaterData = UserDefaults.standard.getNotInterested(Key: Local.NOT_INTERESTED.not_interested)
            getWatchLaterData.append(data!)
            UserDefaults.standard.setNotInterested(value: getWatchLaterData, ForKey: Local.NOT_INTERESTED.not_interested)
            self.getRecentlyWatchVideosArray.remove(at: index)
            self.tableView.reloadData()
            self.view.makeToast("Video removed from the list")
        }
        }
}
extension LibrarySelectVC:UITableViewDelegate,UITableViewDataSource,ShowPresentControllerDelegate,IndexofCellDelegate,UISearchBarDelegate,ShowCreatePlayListDelegate{
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
            log.verbose("Index = \(Index)")
        case 4:
            log.verbose("Index = \(Index)")
            let vc = storyboard.instantiateViewController(withIdentifier: "ReportVideoVC") as! ReportVideoVC
            if !self.getLikedVideosArray.isEmpty{
                vc.videoId = getLikedVideosArray[Index].id
            }else{
                vc.videoId =
                    getRecentlyWatchVideosArray[Index].id 
            }
            self.present(vc, animated: true, completion: nil)
        default:
            log.verbose("Something went wrong. Please try again Later!.")
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !self.getLikedVideosArray.isEmpty{
             return self.getLikedVideosArray.count ?? 0
        }else{
             return self.getRecentlyWatchVideosArray.count ?? 0
        }
        
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !self.getLikedVideosArray.isEmpty{
            let cell = tableView.dequeueReusableCell(withIdentifier: "LibrarySelect_TableCell") as! LibrarySelect_TableCell
            cell.selectionStyle = .none
            cell.delegate = self
            cell.cellIndexDelegate = self
            cell.indexPath = indexPath.row
            let getLikedVideosObject = getLikedVideosArray[indexPath.row]
            cell.nameLabel.text = getLikedVideosObject.title ?? ""
            cell.usernameLabel.text = getLikedVideosObject.owner!.username ?? ""
            cell.viewsLabel.text = "\(getLikedVideosObject.views!.roundedWithAbbreviations ?? "") Views"
            cell.durationLabel.text = getLikedVideosObject.duration ?? ""
              cell.durationView?.sizeThatFits(CGSize(width: (cell.durationLabel.frame.width) + 10, height: (cell.durationLabel.frame.height)))
            let url = URL.init(string:getLikedVideosObject.thumbnail!)
            cell.imageViewLabel.sd_setImage(with: url , placeholderImage: UIImage(named: "maxresdefault"))
            cell.imageViewLabel.layer.cornerRadius = 10
            cell.imageViewLabel.clipsToBounds = true
            if getLikedVideosObject.owner!.verified == 1{
                cell.isVerifiedLabel.isHidden = true
            }else{
                cell.isVerifiedLabel.isHidden = false
            }
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "LibrarySelect_TableCell") as! LibrarySelect_TableCell
            cell.selectionStyle = .none
            cell.delegate = self
            cell.cellIndexDelegate = self
            cell.indexPath = indexPath.row
            let getRecentlyWatchVideoOject = getRecentlyWatchVideosArray[indexPath.row]
            cell.nameLabel.text = getRecentlyWatchVideoOject.title ?? ""
            cell.usernameLabel.text = getRecentlyWatchVideoOject.owner!.username ?? ""
            cell.viewsLabel.text = "\(getRecentlyWatchVideoOject.views!.roundedWithAbbreviations ?? "") Views"
            cell.durationLabel.text = getRecentlyWatchVideoOject.duration ?? ""
            let url = URL.init(string:getRecentlyWatchVideoOject.thumbnail!)
            cell.imageViewLabel.sd_setImage(with: url , placeholderImage: UIImage(named: "maxresdefault"))
            cell.imageViewLabel.layer.cornerRadius = 10
            cell.imageViewLabel.clipsToBounds = true
            if getRecentlyWatchVideoOject.owner!.verified == 1{
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
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
        
        
    }
    
    
}
