//
//  SelectAPlaylistVC.swift
//  Playtube
//

import UIKit
import Async
import PlaytubeSDK

protocol ShowCreatePlayListDelegate {
    func showCreatePlaylist(Status:Bool)
}
class SelectAPlaylistVC: BaseViewController {
    
    @IBOutlet weak var TableView: UITableView!
    
    var videoId:Int? = nil
    var listId:String? = nil
    var playlistArray = [PlaylistModel.MyAllPlaylist]()
    var delegate:ShowCreatePlayListDelegate!
    private var userId:Int? = nil
    private var sessionId:String? = nil
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.getUserSession()
        log.verbose("list ID = \(listId)")
         log.verbose("vidio ID  = \(videoId)")
        self.TableView.separatorStyle = .none
    }
   
    @IBAction func createNewButton(_ sender: Any) {
        self.dismiss(animated: true) {
              self.delegate.showCreatePlaylist(Status: true)
        }
      
    }
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
     
    }
    private func selectPlaylist(listId:String,videoId:Int){
        self.showProgressDialog(text: "Loading...")
        Async.background({
            PlaylistManager.instance.addToPlaylist(User_id: self.userId ?? 0, Session_Token: self.sessionId ?? "", List_id: listId, Video_Id: videoId, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        log.debug(success?.message)
                        self.dismissProgressDialog()
                        self.view.makeToast(success?.message)
                        self.dismiss(animated: true, completion: nil)
                    })
                }else if sessionError != nil{
                    Async.main({
                        log.error(sessionError?.errors!.errorText)
                        self.dismissProgressDialog()
                        self.view.makeToast(sessionError?.errors!.errorText)
                    })
                }else{
                    Async.main({
                        self.dismissProgressDialog()
                        log.error(error?.localizedDescription)
                        self.view.makeToast(error?.localizedDescription)
                    })
                }
            })
        })
        
    }
    private  func getUserSession(){
        log.verbose("getUserSession = \(UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session))")
        let localUserSessionData = UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session)
        self.userId = localUserSessionData[Local.USER_SESSION.user_id] as! Int
        self.sessionId = localUserSessionData[Local.USER_SESSION.session_id] as! String
    }
    
    
}
extension SelectAPlaylistVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playlistArray.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell = tableView.dequeueReusableCell(withIdentifier: "SelectAPlaylist_TableCell") as! SelectAPlaylist_TableCell
        cell.selectionStyle = .none
        let playlist = self.playlistArray[indexPath.row]
        cell.playListNameLabel.text = playlist.name
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let playlistObject = self.playlistArray[indexPath.row]
        self.selectPlaylist(listId:playlistObject.listID! , videoId: self.videoId ?? 0)
    }
    
    
}
