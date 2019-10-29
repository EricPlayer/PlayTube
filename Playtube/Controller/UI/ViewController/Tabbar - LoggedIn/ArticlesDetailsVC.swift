//
//  ArticlesDetailsVC.swift
//  Playtube
//
//  Created by Macbook Pro on 27/03/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import Async
import PlaytubeSDK

class ArticlesDetailsVC: BaseViewController {
    
    @IBOutlet weak var addCommentTextView: UITextView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var scrollHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dislikeCountLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var dislikeBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var categoryLabel: UIButton!
    @IBOutlet weak var thumbnailImage: UIImageView!
    
    
     var articlesObject:ArticlesModel.Datum!
    private var userId:Int? = nil
    private var sessionId:String? = nil
    private var artilcesCommentArray = [ArticlesCommentModel.Datum]()
    private var likeCount:Int? = 0
    private var dislikeCount:Int? = 0
    private var sessionStatus:Bool? = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        log.verbose("Object = \(articlesObject)")
        self.showData()
//        self.getUserSession()
        self.sessionStatus = UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session).isEmpty
        if sessionStatus!{
           self.fetchArticlesComments()
        }else{
            self.getUserSession()
            self.fetchArticlesComments()
        }
        
        self.tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        self.sendBtn.layer.cornerRadius = self.sendBtn.frame.height / 2
        self.textViewPlaceHolder()
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.NavigationbarConfiguration()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    @IBAction func sendPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        if self.sessionStatus!{
            let vc = storyboard.instantiateViewController(withIdentifier: "ShowLoginPopVC") as! ShowLoginPopVC
            self.present(vc, animated: true, completion: nil)
        }else{
            if Reachability.isConnectedToNetwork(){
                let commentText = addCommentTextView.text
                self.showProgressDialog(text: "Loading...")
                Async.background({
                    ArticlesManager.instance.addArtilcesComments(User_id: self.userId ?? 0, Session_Token: self.sessionId ?? "", Post_id:self.articlesObject.id ?? 0, Comment_Text:commentText ?? "", completionBlock: { (success, sessionError, error) in
                        if success != nil{
                            Async.main({
                                self.view.makeToast(success?.message)
                                log.verbose("SUCCESS")
                                log.verbose("success = \(success?.message)")
                                self.artilcesCommentArray.removeAll()
                                self.fetchArticlesComments()
                                self.dismissProgressDialog()
                                
                                
                            })
                        }else if sessionError != nil{ self.view.makeToast(sessionError?.errors?.errorText)
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
        
    }
    @IBAction func likePressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        if self.sessionStatus!{
            let vc = storyboard.instantiateViewController(withIdentifier: "ShowLoginPopVC") as! ShowLoginPopVC
            self.present(vc, animated: true, completion: nil)
        }else{
            Async.background({
                ArticlesManager.instance.likeDislikeArticles(User_id: self.userId ?? 0, Session_Token: self.sessionId ?? "", Artilce_id: self.articlesObject.id ?? 0, Like_Type: "like", completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            log.verbose("success \(success?.successType) ")
                            
                            if success?.successType == "added_like"{
                                self.likeBtn.setImage(UIImage(named: "likeblue"), for: .normal)
                                log.verbose("success = \(success?.successType)")
                                self.view.makeToast("Liked")
                                if self.likeBtn.imageView!.image == UIImage(named: "likeblue"){
                                    self.likeCount = self.likeCount! + 1
                                    self.likeCountLabel.text = "\(self.likeCount ?? 0)"
                                    
                                }
                                if self.dislikeBtn.imageView!.image == UIImage(named: "dislikeblue-1"){
                                    self.dislikeBtn.setImage(UIImage(named: "dislike"), for: .normal)
                                    self.dislikeCount = self.dislikeCount! - 1
                                    self.dislikeCountLabel.text = "\(self.dislikeCount ?? 0)"
                                    
                                }
                                self.dismissProgressDialog()
                            }else{
                                self.likeBtn.setImage(UIImage(named: "like"), for: .normal)
                                log.verbose("success = \(success?.successType)")
                                self.likeCount = self.likeCount! - 1
                                self.likeCountLabel.text = "\(self.likeCount ?? 0)"
                                self.dismissProgressDialog()
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
                    
                })
            })

            
        }
      
    }
    
    @IBAction func dislikePressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        if self.sessionStatus!{
            let vc = storyboard.instantiateViewController(withIdentifier: "ShowLoginPopVC") as! ShowLoginPopVC
            self.present(vc, animated: true, completion: nil)
        }else{
            
            Async.background({
                ArticlesManager.instance.likeDislikeArticles(User_id: self.userId ?? 0, Session_Token: self.sessionId ?? "", Artilce_id: self.articlesObject.id ?? 0, Like_Type: "dislike", completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            log.verbose("success \(success?.successType) ")
                            
                            if success?.successType == "added_dislike"{
                                self.dislikeBtn.setImage(UIImage(named: "dislikeblue-1"), for: .normal)
                                log.verbose("success = \(success?.successType)")
                                self.view.makeToast("Disliked")
                                if self.dislikeBtn.imageView!.image == UIImage(named: "dislikeblue-1"){
                                    self.dislikeCount = self.dislikeCount! + 1
                                    self.dislikeCountLabel.text = "\(self.dislikeCount ?? 0)"
                                    
                                }
                                if self.likeBtn.imageView!.image == UIImage(named: "likeblue"){
                                    self.likeBtn.setImage(UIImage(named: "like"), for: .normal)
                                    self.likeCount = self.likeCount! - 1
                                    self.likeCountLabel.text = "\(self.likeCount ?? 0)"
                                    
                                }
                                self.dismissProgressDialog()
                            }else{
                                self.dislikeBtn.setImage(UIImage(named: "dislike"), for: .normal)
                                log.verbose("success = \(success?.successType)")
                                self.dismissProgressDialog()
                                self.dislikeCount = self.dislikeCount! - 1
                                self.dislikeCountLabel.text = "\(self.dislikeCount ?? 0)"
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
                })
            })
        }
      

    }
    
    private func showData(){
        let thumbnailUrl = URL.init(string:articlesObject.image ?? "")
        thumbnailImage.sd_setImage(with: thumbnailUrl , placeholderImage: UIImage(named: "maxresdefault"))
        self.titleLabel.text = self.articlesObject.title!.htmlAttributedString ?? ""
        self.categoryLabel.setTitle(self.articlesObject.category, for: .normal)
        self.likeCountLabel.text = "\(self.articlesObject.likes ?? 0)"
        self.dislikeCountLabel.text = "\(self.articlesObject.dislikes ?? 0)"
        self.descriptionLabel.text = self.articlesObject.description
        self.timeLabel.text = self.articlesObject.textTime
        self.textLabel.text = self.articlesObject.text!.htmlAttributedString ?? ""
        let height = self.scrollHeightConstraint.constant + estimatedHeightOfLabel(text:self.textLabel.text ?? "") + estimatedHeightOfLabel(text:self.textLabel.text ?? "") + estimatedHeightOfLabel(text:self.textLabel.text ?? "")
        log.verbose("height  = \(height)")
        log.verbose("Text Height = \(self.textLabel.bounds.height)")
        self.scrollHeightConstraint.constant = height
        self.likeCount = articlesObject.likes ?? 0
        self.dislikeCount = articlesObject.dislikes ?? 0
        if self.articlesObject.liked == 0{
            self.likeBtn.setImage(UIImage(named: "like"), for: .normal)
        }else{
            self.likeBtn.setImage(UIImage(named: "likeblue"), for: .normal)
        }
        if self.articlesObject.disliked == 0{
            self.dislikeBtn.setImage(UIImage(named: "dislike"), for: .normal)
            
        }else{
            self.dislikeBtn.setImage(UIImage(named: "dislikeblue-1"), for: .normal)
        }
        
    }
    private func fetchArticlesComments(){
        
        Async.background({
            ArticlesManager.instance.getArticlesComments(User_id: self.userId ?? 0, Session_Token: self.sessionId ?? "", Limit: 0, Post_id: self.articlesObject.id ?? 0) { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        self.artilcesCommentArray = (success?.data)!
                        self.dismissProgressDialog()
                        log.verbose("success = \(self.artilcesCommentArray)")
                        self.tableView.reloadData()
                        self.dismissProgressDialog()
                    })
                    
                    
                }else if sessionError != nil{
                    Async.main({
                        self.view.makeToast(sessionError?.errors!.errorText)
                        self.dismissProgressDialog()
                        log.verbose("sessionError = \(sessionError?.errors!.errorText)")
                        
                    })
                    
                }else {
                    Async.main({
                        self.view.makeToast(error?.localizedDescription)
                        self.dismissProgressDialog()
                        log.verbose("sessionError = \(error?.localizedDescription)")
                        
                    })
                }
            }
            
        })
        
    }
    private  func NavigationbarConfiguration(){
        self.title = self.articlesObject.category
        self.tabBarController?.tabBar.isHidden = true
        let color = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color ]
        self.navigationController?.navigationBar.tintColor = color
    }
    func estimatedHeightOfLabel(text: String) -> CGFloat {
        
        let size = CGSize(width: view.frame.width - 16, height: 1000)
        
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10)]
        
        let rectangleHeight = String(text).boundingRect(with: size, options: options, attributes: attributes, context: nil).height
        
        return rectangleHeight
    }
    private  func getUserSession(){
        log.verbose("getUserSession = \(UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session))")
        let localUserSessionData = UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session)
        self.userId = localUserSessionData[Local.USER_SESSION.user_id] as! Int
        self.sessionId = localUserSessionData[Local.USER_SESSION.session_id] as! String
    }
    private func textViewPlaceHolder(){
        addCommentTextView.delegate = self
        addCommentTextView.text = "Your Comment..."
        addCommentTextView.textColor = UIColor.lightGray
    }
    
    
}
extension ArticlesDetailsVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.artilcesCommentArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticlesComment_TableCell") as? ArticlesComment_TableCell
        cell?.delegate = self
        let articleCommentObject = self.artilcesCommentArray[indexPath.row]
        cell?.index = articleCommentObject.id
        cell?.likeCount = articleCommentObject.likes
        cell?.dislikeCount = articleCommentObject.disLikes
        cell?.indexPath = indexPath.row
        cell?.commentsLabel.text = articleCommentObject.text
        cell?.timeLabel.text = articleCommentObject.textTime
        let url = URL.init(string:articleCommentObject.commentUserData!.avatar ?? "")
        cell?.profileImage.sd_setImage(with: url , placeholderImage: UIImage(named: "maxresdefault"))
        cell?.likesLabel.text =  "\(articleCommentObject.likes)"
        cell?.disLikeLabel.text =  "\(articleCommentObject.disLikes)"
        cell?.replyLabel.text = "\(articleCommentObject.repliesCount ?? 0)"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
extension ArticlesDetailsVC:UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Playlist Description"
            textView.textColor = UIColor.lightGray
        }
    }
}
extension ArticlesDetailsVC:LikeDisLikeDelegate{
    func likeComments(id: Int,likebutton: UIButton, dislikebutton: UIButton, likeCount: Int?, dislikeCount: Int?, likeCountLabel: UILabel, dislikeCountLabel: UILabel) {
        let storyboard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        if self.sessionStatus!{
            let vc = storyboard.instantiateViewController(withIdentifier: "ShowLoginPopVC") as! ShowLoginPopVC
            self.present(vc, animated: true, completion: nil)
        }else{
            Async.background({
                PlayVideoManager.instance.likeComments(User_id: self.userId ?? 0, Session_Token: self.sessionId ?? "", Type: "like", Comment_Id: id) { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            log.verbose("success \(success?.successType) ")
                            
                            if success?.liked == 1{
                                likebutton.setImage(UIImage(named: "likeblue"), for: .normal)
                                log.verbose("success = \(success?.successType)")
                                self.view.makeToast("Liked")
                                if likebutton.imageView!.image == UIImage(named: "likeblue"){
                                    var likeCountValues = likeCount
                                    likeCountValues = likeCountValues! + 1
                                    likeCountLabel.text = "\(likeCountValues ?? 0)"
                                    
                                }
                                if dislikebutton.imageView!.image == UIImage(named: "dislikeblue-1"){
                                    dislikebutton.setImage(UIImage(named: "dislike"), for: .normal)
                                    var dislikeCountValues = dislikeCount
                                    dislikeCountValues = dislikeCountValues! - 1
                                    dislikeCountLabel.text = "\(dislikeCountValues ?? 0)"
                                    
                                }
                                self.dismissProgressDialog()
                            }else{
                                likebutton.setImage(UIImage(named: "like"), for: .normal)
                                log.verbose("success = \(success?.successType)")
                                var likeCountValues = likeCount
                                likeCountValues = likeCountValues! - 1
                                likeCountLabel.text = "\(likeCountValues ?? 0)"
                                self.dismissProgressDialog()
                            }
                        })
                        //
                    }else if sessionError != nil{
                        Async.main{
                            log.error("sessionError = \(sessionError?.errors!.errorText)")
                            self.view.makeToast(sessionError?.errors!.errorText)
                        }
                    }else{
                        log.error("error = \(error?.localizedDescription)")
                        self.view.makeToast(error?.localizedDescription)
                        
                    }
                }
            })
            
            log.verbose("like")
        }
        
        
        
    }
    
    func disLikeComments(id: Int, dislikebutton: UIButton, likebutton: UIButton, likeCount: Int?, dislikeCount: Int?,likeCountLabel: UILabel, dislikeCountLabel: UILabel) {
        let storyboard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        if self.sessionStatus!{
            let vc = storyboard.instantiateViewController(withIdentifier: "ShowLoginPopVC") as! ShowLoginPopVC
            self.present(vc, animated: true, completion: nil)
        }else{
            Async.background({
                PlayVideoManager.instance.dislikeComments(User_id: self.userId ?? 0, Session_Token: self.sessionId ?? "", Type: "dislike", Comment_Id: id) { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            log.verbose("success \(success?.successType) ")
                            
                            if success?.dislike == 1{
                                dislikebutton.setImage(UIImage(named: "dislikeblue-1"), for: .normal)
                                log.verbose("success = \(success?.successType)")
                                self.view.makeToast("Disliked")
                                if dislikebutton.imageView!.image == UIImage(named: "dislikeblue-1"){
                                    var dislikeCountvalues = dislikeCount
                                    dislikeCountvalues = dislikeCountvalues! + 1
                                    dislikeCountLabel.text = "\(dislikeCountvalues ?? 0)"
                                    
                                }
                                if likebutton.imageView!.image == UIImage(named: "likeblue"){
                                    likebutton.setImage(UIImage(named: "like"), for: .normal)
                                    var likeCountValues = likeCount
                                    likeCountValues = likeCountValues! - 1
                                    likeCountLabel.text = "\(likeCountValues ?? 0)"
                                    
                                }
                                self.dismissProgressDialog()
                            }else{
                                dislikebutton.setImage(UIImage(named: "dislike"), for: .normal)
                                log.verbose("success = \(success?.successType)")
                                self.dismissProgressDialog()
                                var dislikeCountValues = dislikeCount
                                dislikeCountValues = dislikeCountValues! - 1
                                dislikeCountLabel.text = "\(dislikeCountValues ?? 0)"
                            }
                        })
                        
                    }else if sessionError != nil{
                        Async.main{
                            log.error("sessionError = \(sessionError?.errors!.errorText)")
                            self.view.makeToast(sessionError?.errors!.errorText)
                        }
                    }else{
                        log.error("error = \(error?.localizedDescription)")
                        self.view.makeToast(error?.localizedDescription)
                        
                    }
                }
            })
            log.verbose("dislike")
        }
        
        
        
    }
    
    
    func replyComments(index: Int) {
        let storyboard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        if self.sessionStatus!{
            let vc = storyboard.instantiateViewController(withIdentifier: "ShowLoginPopVC") as! ShowLoginPopVC
            self.present(vc, animated: true, completion: nil)
        }else{
            let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "RepliesVC") as! RepliesVC
            vc.artilcesCommentObject = self.artilcesCommentArray[index]
            self.present(vc, animated: true, completion: nil)
            log.verbose("replycomment at Index = \(index)")
        }
        
    }
}
