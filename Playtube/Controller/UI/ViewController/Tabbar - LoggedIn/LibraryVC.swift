//
//  LibraryVC.swift
//  Playtube


import UIKit
import PlaytubeSDK
import SDWebImage
class LibraryVC: UIViewController {
    var libraryNameArray =  [String]()
    var libraryImageArray = [String]()
    
    @IBOutlet weak var TableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if AppSettings.ShowDownloadButton == false{
            
            self.libraryNameArray =  [
                "Subscriptions",
                "Watch Later",
                "Recently Watched",
                "Playlists",
                "Liked",
                "Shared"
                
            ]
           self.libraryImageArray = [
                "checkmark",
                "watch_Later",
                "recently_watched",
                "playlist",
                "heart",
                "lib_share"
            ]
        }else{
             self.libraryNameArray =  [
                "Subscriptions",
                "Watch Later",
                "Recently Watched",
                "Watch offline",
                "Playlists",
                "Liked",
                "Shared"
                
            ]
           self.libraryImageArray = [
                "checkmark",
                "watch_Later",
                "recently_watched",
                "download",
                "playlist",
                "heart",
                "lib_share"
            ]
            
        }
      
        self.view.backgroundColor = AppSettings.appColor
        self.TableView.separatorStyle = .none
    }
    override func viewWillAppear(_ animated: Bool) {
        self.TableView.reloadData()
    }
    @IBAction func notificationBtnPressed(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "NotificationsVC") as! NotificationsVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
extension LibraryVC:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return libraryNameArray.count ?? libraryImageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TableView.dequeueReusableCell(withIdentifier: "Iibrary_TableCell") as! Iibrary_TableCell
        cell.selectionStyle = .none
        let libraryName = libraryNameArray[indexPath.row]
        let libraryImage = libraryImageArray[indexPath.row]
        cell.imageIconLabel.image = UIImage(named: libraryImage)
        cell.libraryNameLabel.text = libraryName
        if indexPath.row == 0 {
            if  UserDefaults.standard.getSubscriptionImage(Key: "librarySubscrptionImage") != ""{
                log.verbose("image = \( UserDefaults.standard.getSubscriptionImage(Key: "librarySubscrptionImage"))")
                let backImage =  UserDefaults.standard.getSubscriptionImage(Key: "librarySubscrptionImage")
                let url = URL.init(string:backImage)
                cell.backImage.sd_setImage(with: url , placeholderImage: UIImage(named: ""))
            }else {
                log.verbose("No iamge to show ")
                
            }
        }else if indexPath.row == 1{
           
            
            if  UserDefaults.standard.getWatchLaterImage(Key: "libraryWatchLaterImage") != ""{
                log.verbose("image = \( UserDefaults.standard.getWatchLaterImage(Key: "libraryWatchLaterImage"))")
                let backImage =  UserDefaults.standard.getWatchLaterImage(Key: "libraryWatchLaterImage")
                let url = URL.init(string:backImage)
                cell.backImage.sd_setImage(with: url , placeholderImage: UIImage(named: ""))
            }else {
                log.verbose("No iamge to show ")
                
            }
            
        }else if indexPath.row == 2{
            if  UserDefaults.standard.getRecentWatchImage(Key: "libraryRecentlyWatchedImage") != ""{
                log.verbose("image = \( UserDefaults.standard.getRecentWatchImage(Key: "libraryRecentlyWatchedImage"))")
                let backImage =  UserDefaults.standard.getRecentWatchImage(Key: "libraryRecentlyWatchedImage")
                let url = URL.init(string:backImage)
                cell.backImage.sd_setImage(with: url , placeholderImage: UIImage(named: ""))
            }else {
                log.verbose("No iamge to show ")
                
            }
            
            
        }else if indexPath.row == 3{
            
            if  UserDefaults.standard.getOfflineImage(Key: "libraryOfflineDownloadImage") != ""{
                log.verbose("image = \( UserDefaults.standard.getOfflineImage(Key: "libraryOfflineDownloadImage"))")
                let backImage =  UserDefaults.standard.getOfflineImage(Key: "libraryOfflineDownloadImage")
                let url = URL.init(string:backImage)
                cell.backImage.sd_setImage(with: url , placeholderImage: UIImage(named: ""))
            }else {
                log.verbose("No iamge to show ")
                
            }
        }else if indexPath.row == 4{
            
        }else if indexPath.row == 5 {
            
            
            if  UserDefaults.standard.getLikedImage(Key: "libraryLikedVideosImage") != ""{
                log.verbose("image = \( UserDefaults.standard.getLikedImage(Key: "libraryLikedVideosImage"))")
                let backImage =  UserDefaults.standard.getLikedImage(Key: "libraryLikedVideosImage")
                let url = URL.init(string:backImage)
                cell.backImage.sd_setImage(with: url , placeholderImage: UIImage(named: ""))
            }else {
                log.verbose("No iamge to show ")
                
            }
        }
  
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130.0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        let librarySelectVc = storyBoard.instantiateViewController(withIdentifier: "LibrarySelectVC") as! LibrarySelectVC
        let subcriptionVc = storyBoard.instantiateViewController(withIdentifier: "SubscriptionVC") as! SubscriptionVC
        let watchLaterVc = storyBoard.instantiateViewController(withIdentifier: "WatchLaterVC") as! WatchLaterVC
         let playlistVc = storyBoard.instantiateViewController(withIdentifier: "PlaylistVC") as! PlaylistVC
        if indexPath.row == 0 {
               self.navigationController?.pushViewController(subcriptionVc, animated: true)
        }else if indexPath.row == 1{
            watchLaterVc.getStringStatus = Local.WATCH_LATER.watch_Later
            self.navigationController?.pushViewController(watchLaterVc, animated: true)
        }else if indexPath.row == 2{
            librarySelectVc.index = indexPath.row
            librarySelectVc.getStringStatus = libraryNameArray[indexPath.row]
            self.navigationController?.pushViewController(librarySelectVc, animated: true)
            
        }else if indexPath.row == 3{
            watchLaterVc.getStringStatus = Local.OFFLINE_DOWNLOAD.offline_download
        self.navigationController?.pushViewController(watchLaterVc, animated: true)
            
        }else if indexPath.row == 4{
            playlistVc.getStringStatus = true
            self.navigationController?.pushViewController(playlistVc, animated: true)
        }else if indexPath.row == 5{
            librarySelectVc.index = indexPath.row
             librarySelectVc.getStringStatus = libraryNameArray[indexPath.row]
            self.navigationController?.pushViewController(librarySelectVc, animated: true)
            
        }else{
            
            watchLaterVc.getStringStatus = Local.SHARED_VIDEOS.shared_videos
            self.navigationController?.pushViewController(watchLaterVc, animated: true)
        }
    }
}
