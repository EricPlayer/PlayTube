//
//  ArticlesVC.swift
//  Playtube
//
//  Created by Macbook Pro on 25/03/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import PlaytubeSDK
class ArticlesVC: BaseViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    private var articlesArray = [ArticlesModel.Datum]()
    private var userId:Int? = nil
    private var sessionId:String? = nil
    private let appdelegate = UIApplication.shared.delegate as? AppDelegate
    private var sessionStatus:Bool? = false
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.getUserSession()
//        self.fetchData()
//        self.NavigationbarConfiguration()
        self.tableView.separatorStyle = .none
        self.sessionStatus = UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session).isEmpty
        if sessionStatus!{
            self.fetchData()
        }else{
            self.getUserSession()
            self.fetchData()
        }
    }
    
    private func fetchData(){
        self.showProgressDialog(text: "Loading...")
        Async.background({
            ArticlesManager.instance.getTrendingData(User_id: self.userId ?? 0, Session_Token: self.sessionId ?? "", completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        log.verbose("Success = \(success?.data)")
                        self.articlesArray = (success?.data)!
                        self.dismissProgressDialog()
                        self.tableView.reloadData()
                        
                    })
                    
                }else if sessionError != nil{
                    Async.main({
                        log.error(sessionError?.errors!.errorText ?? "")
                        self.view.makeToast(sessionError?.errors!.errorText)
                        self.dismissProgressDialog()
                    })
                    
                }else{
                    Async.main({
                        log.error("error = \(error?.localizedDescription)")
                        self.view.makeToast(error?.localizedDescription)
                        self.dismissProgressDialog()
                        
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
    func NavigationbarConfiguration(){
       
        self.title = "Explore Articales"
        let color = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color ]
        self.navigationController?.navigationBar.tintColor = color
    }
    
}
extension ArticlesVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.articlesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Articles_TableCell") as? Articles_TableCell
        let articleObject = self.articlesArray[indexPath.row]
        cell!.delegate = self
        cell?.profileDelegate = self
        cell?.indexPath = indexPath.row
        cell?.selectionStyle = .none
        let thumbnailUrl = URL.init(string:articleObject.image ?? "")
        let profileImageURL = URL.init(string:articleObject.userData!.avatar ?? "")
        cell?.thumbnailImage.sd_setImage(with: thumbnailUrl , placeholderImage: UIImage(named: "maxresdefault"))
        cell?.profileImage.sd_setImage(with: profileImageURL , placeholderImage: UIImage(named: "maxresdefault"))
        cell?.profileImage.layer.cornerRadius = (cell?.profileImage.frame.height)! / 2
        cell?.titleLabel.text = articleObject.title!.htmlAttributedString ?? ""
        cell!.descriptionLabel.text = articleObject.description
        cell?.usernameLabel.text = articleObject.userData!.username ?? ""
        cell?.timeLabel.text = articleObject.textTime
       
        cell?.categoryLabel.text = articleObject.category
        
        
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ArticlesDetailsVC") as! ArticlesDetailsVC
        vc.articlesObject = self.articlesArray[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
extension ArticlesVC:ShowArticlesDetailsDelegate{
    func didShowArticlesDetails(index: Int) {
        let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ArticlesDetailsVC") as! ArticlesDetailsVC
        vc.articlesObject = self.articlesArray[index]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
}
extension ArticlesVC:ShowProfileDelegate{
    func didShowProfileDetails(index: Int) {
        let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ChannelDetailsVC") as! ChannelDetailsVC
        vc.channelId = self.articlesArray[index].userData?.id
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
  
    
    
    
}

