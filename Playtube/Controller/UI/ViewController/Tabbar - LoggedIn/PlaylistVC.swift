//
//  PlaylistVC.swift
//  Playtube

import UIKit
import XLPagerTabStrip
import JGProgressHUD
import Async
import PlaytubeSDK

class PlaylistVC: UIViewController,IndicatorInfoProvider {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showStack: UIStackView!
    
    var getStringStatus:Bool? = false
    var index:Int? = nil
    var channelId:Int? = 0
    private var userId:Int? = nil
    private var sessionId:String? = nil
    private var playlistsArray = [PlaylistModel.MyAllPlaylist]()
    var hud : JGProgressHUD?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = AppSettings.appColor
        self.tableView.separatorStyle = .none
       
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        if self.getStringStatus!{
            NavigationbarConfiguration()
            self.getUserSession()
            self.myChannelPlayListfetchData()
            log.verbose("From Library")
        }else{
             log.verbose("From user Channel")
            if self.channelId
                == 0{
                self.getUserSession()
                self.myChannelPlayListfetchData()
            }else{
                self.otherChannelPlayListfetchData()
            }
        }
    }
    private func myChannelPlayListfetchData(){
        if Reachability.isConnectedToNetwork(){
            self.showProgressDialog(text: "Loading...")
            Async.background({
                PlaylistManager.instance.getPlaylist(User_id: self.userId!, Session_Token: self.sessionId!, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            log.debug("success")
                            self.playlistsArray = (success?.myAllPlaylists)!
                            if !self.playlistsArray.isEmpty{
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
                    }else if sessionError != nil{
                        Async.main({
                            log.debug("sessionError = \(sessionError?.errors!.errorText)")
                            self.view.makeToast(sessionError?.errors!.errorText)
                            self.dismissProgressDialog()
                            
                        })
                    }else{
                        Async.main({
                            log.debug("error = \(error?.localizedDescription)")
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
    private func otherChannelPlayListfetchData(){
        if Reachability.isConnectedToNetwork(){
            self.showProgressDialog(text: "Loading...")
            Async.background({
                PlaylistManager.instance.getPlaylistWithChannelId(User_id: self.channelId!, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            log.debug("success")
                            self.playlistsArray = (success?.myAllPlaylists)!
                            if !self.playlistsArray.isEmpty{
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
                    }else if sessionError != nil{
                        Async.main({
                            log.debug("sessionError = \(sessionError?.errors!.errorText)")
                            self.view.makeToast(sessionError?.errors!.errorText)
                            self.dismissProgressDialog()
                            
                        })
                    }else{
                        Async.main({
                            log.debug("error = \(error?.localizedDescription)")
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
    private func NavigationbarConfiguration(){
        self.navigationController?.isNavigationBarHidden = false
       self.title = "PlayLists"
        let color = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color ]
        self.navigationController?.navigationBar.tintColor = color
        
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "PLAYLISTS")
        
    }
    
}

extension PlaylistVC:UITableViewDataSource,UITableViewDelegate,ShowPresentControllerDelegate,IndexofCellDelegate{
    func indexofCell(Index: Int) {
        log.verbose("Index = \(Index)")
        self.index = Index
    }
    
    func showController(Index: Int) {
        let storyboard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        switch Index{
        case 0:
            log.verbose("Index = \(Index)")
            let storyboard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "CreatePlaylistVC") as! CreatePlaylistVC
            vc.status = true
            vc.listId = self.playlistsArray[index!].listID
            vc.playlistObject = self.playlistsArray[index!]
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = storyboard.instantiateViewController(withIdentifier: "DeletePlayList") as! DeletePlayList
             vc.listid = self.playlistsArray[index!].listID
            self.present(vc, animated: true, completion: nil)
            log.verbose("Index = \(Index)")
            
        default:
            log.verbose("Something went wrong. Please try again Later!.")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playlistsArray.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Playlist_TableCell") as? Playlist_TableCell
        let playlistObject = self.playlistsArray[indexPath.row]
        cell?.selectionStyle = .none
        cell?.delegate = self
        cell?.cellIndexDelegate = self
        cell!.indexPath = indexPath.row
        cell?.imageLabel.downloaded(from: playlistObject.thumbnail ?? "")
        cell!.imageLabel.layer.cornerRadius = 10
        cell!.imageLabel.clipsToBounds = true
        cell?.videosCount.text = "\(playlistObject.count ?? 0)"
        cell?.titleLabel.text = playlistObject.name ?? ""
        cell?.videosLabel.text = "\(playlistObject.count ?? 0) Videos"
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "PlaylistVideosVC") as! PlaylistVideosVC
        vc.listId = self.playlistsArray[indexPath.row].listID
        vc.playlistName = self.playlistsArray[indexPath.row].name
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
extension PlaylistVC{
    
    func showProgressDialog(text: String) {
        hud = JGProgressHUD(style: .extraLight)
        hud?.textLabel.text = text
        hud?.show(in: self.view)
    }
    
    func dismissProgressDialog() {
        hud?.dismiss()
    }
}

