//
//  RepliesVC.swift
//  Playtube


import UIKit
import Async
import PlaytubeSDK

class RepliesVC: BaseViewController {
    
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var norepliesLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var replyBtn: UIButton!
    @IBOutlet weak var repliesCountLabel: UILabel!
    @IBOutlet weak var dislikeBtnLabel: UILabel!
    @IBOutlet weak var dislikeBtn: UIButton!
    @IBOutlet weak var likeBtnLabel: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    var commentObject:CommentModel.Datum?
    var artilcesCommentObject:ArticlesCommentModel.Datum?
    private var sessionStatus:Bool? = nil
    private var userId:Int? = nil
    private var sessionId:String? = nil
    private var repliesArray = [RepliesModel.Datum]()
    private var id:Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
//          self.view.backgroundColor = AppSettings.appColor

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        self.view.addGestureRecognizer(tap)
        self.tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        self.sendBtn.layer.cornerRadius = self.sendBtn.frame.height / 2
//        self.id = commentObject!.id
        self.sessionStatus = UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session).isEmpty
        if UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session).isEmpty{
            log.verbose("getUserSession = \(UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session))")
           self.fetchReplies()
            
        }else{
            log.verbose("getUserSession = \(UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session))")
            self.getUserSession()
           self.fetchReplies()
            
        }
        self.textViewPlaceHolder()
        self.showCommentData()
        
        
        
    }
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        self.dismiss(animated: true, completion: nil)
    }
  

    @IBAction func sendPressed(_ sender: Any) {
        if Reachability.isConnectedToNetwork(){
            let commentText = self.commentTextView.text
            let videoId = commentObject!.videoID ?? 0
            log.verbose("COmment id= \(self.id)")
//            self.showProgressDialog(text: "Loading...")
            Async.background({
                PlayVideoManager.instance.addCommentReply(User_id: self.userId ?? 0, Session_Token: self.sessionId ?? "", VideoId:videoId ?? 0, Comment_Id: self.id ?? 0, Type: "reply", Comment_Text:commentText ?? "", completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            log.verbose("SUCCESS")
                            log.verbose("success = \(success?.message)")
                            self.repliesArray.removeAll()
                            self.fetchReplies()
                            self.dismissProgressDialog()
                        })
                    }else if sessionError != nil{ self.view.makeToast(sessionError?.errors!.errorText)
                        self.dismissProgressDialog()
                        
                    }else{ self.view.makeToast(error?.localizedDescription)
                        self.dismissProgressDialog()
                        self.dismissProgressDialog()
                    }
                })
                
            })
        }else{
            self.view.makeToast(InterNetError)
        }
    }
    
    @IBAction func likePressed(_ sender: Any) {
       
        Async.background({
            PlayVideoManager.instance.likeComments(User_id: self.userId ?? 0, Session_Token: self.sessionId ?? "", Type: "like", Comment_Id: self.id ?? 0) { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        
                        if success?.liked == 0 {
                            self.likeBtn.setImage(UIImage(named: "like"), for: .normal)
                            
                            
                        }else{
                            self.likeBtn.setImage(UIImage(named: "likeblue"), for: .normal)
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
        
        log.verbose("like")
    }
    
    @IBAction func dislikePressed(_ sender: Any) {
        Async.background({
            PlayVideoManager.instance.dislikeComments(User_id: self.userId ?? 0, Session_Token: self.sessionId ?? "", Type: "dislike", Comment_Id: self.id ?? 0) { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        
                        if success?.dislike == 0 {
                            self.dislikeBtn.setImage(UIImage(named: "dislike"), for: .normal)
                        }else{
                            self.dislikeBtn.setImage(UIImage(named: "dislikeblue-1"), for: .normal)
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
    @IBAction func replyPressed(_ sender: Any) {
       
    }
    
    
    private func showCommentData(){
        if self.commentObject != nil{
            commentLabel.text = commentObject!.text ?? ""
            timeLabel.text = commentObject!.textTime ?? ""
            let url = URL.init(string:commentObject!.commentUserData!.avatar ?? "")
            profileImage.sd_setImage(with: url , placeholderImage: UIImage(named: "maxresdefault"))
            likeBtnLabel.text =  "\(commentObject!.likes ?? 0)"
            dislikeBtnLabel.text =  "\(commentObject!.disLikes ?? 0)"
            repliesCountLabel.text = "\(commentObject!.repliesCount ?? 0)"
        }else{
            commentLabel.text = artilcesCommentObject!.text ?? ""
            timeLabel.text = artilcesCommentObject!.textTime ?? ""
            let url = URL.init(string:artilcesCommentObject!.commentUserData!.avatar ?? "")
            profileImage.sd_setImage(with: url , placeholderImage: UIImage(named: "maxresdefault"))
            likeBtnLabel.text =  "\(artilcesCommentObject!.likes ?? 0)"
            dislikeBtnLabel.text =  "\(artilcesCommentObject!.disLikes ?? 0)"
            repliesCountLabel.text = "\(artilcesCommentObject!.repliesCount ?? 0)"
        }
    }
    private func fetchReplies(){
        self.showProgressDialog(text: "Loading...")
        var commentId = 0
        if self.commentObject != nil{
            commentId = self.commentObject!.id ?? 0
        }else{
            commentId = self.artilcesCommentObject!.id ?? 0
        }
      
        Async.background({
            PlayVideoManager.instance.fetchReplies(User_id: self.userId ?? 0, Session_Token: self.sessionId ?? "", Type: "fetch_replies", Comment_Id: commentId, completionBlock: { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                        self.repliesArray = (success?.data)!
                        if self.repliesArray.isEmpty{
                            self.tableView.isHidden = true
                            self.norepliesLabel.isHidden = false
                            self.dismissProgressDialog()
                        }else{
                        self.tableView.isHidden = false
                            self.norepliesLabel.isHidden = true
                            self.tableView.reloadData()
                            self.dismissProgressDialog()
                        }
                        
                    })
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog()
                        log.error("SessionError = \(sessionError?.errors!.errorText)")
                        self.view.makeToast(sessionError?.errors!.errorText)
                    })
                }else{
                    Async.main({
                    self.dismissProgressDialog()
                    log.error("error = \(error?.localizedDescription)")
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
    private func textViewPlaceHolder(){
        commentTextView.delegate = self
        commentTextView.text = "Your Comment..."
        commentTextView.textColor = UIColor.lightGray
    }

}
extension RepliesVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.repliesArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Replies_TableCell") as? Replies_TableCell
        cell?.delegate = self
        
        let repliesObject = self.repliesArray[indexPath.row]
        cell?.index = repliesObject.id
        cell?.likeCount = repliesObject.replyLikes
        cell?.dislikeCount = repliesObject.replyDislikes
        cell?.commentsLabel.text = repliesObject.text
        cell?.timeLabel.text = repliesObject.textTime
        let url = URL.init(string:repliesObject.replyUserData!.avatar ?? "")
        cell?.profileImage.sd_setImage(with: url , placeholderImage: UIImage(named: "maxresdefault"))
        cell?.likesLabel.text =  "\(repliesObject.replyLikes)"
        cell?.disLikeLabel.text =  "\(repliesObject.replyDislikes)"
  
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension RepliesVC:UITextViewDelegate{
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
extension RepliesVC:LikeDisLikeDelegate{
 
    
    func likeComments(id: Int,likebutton: UIButton, dislikebutton: UIButton, likeCount: Int?, dislikeCount: Int?,likeCountLabel: UILabel, dislikeCountLabel: UILabel) {
        let storyboard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        if self.sessionStatus!{
            let vc = storyboard.instantiateViewController(withIdentifier: "ShowLoginPopVC") as! ShowLoginPopVC
            self.present(vc, animated: true, completion: nil)
        }else{
            
        }
        log.verbose("id for comment = \(id)")
        Async.background({
            PlayVideoManager.instance.likeCommentReplies(User_id: self.userId ?? 0, Session_Token: self.sessionId ?? "", Type: "like", Reply_Id: id) { (success, sessionError, error) in
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
    
    func disLikeComments(id: Int, dislikebutton: UIButton, likebutton: UIButton, likeCount: Int?, dislikeCount: Int?, likeCountLabel: UILabel, dislikeCountLabel: UILabel) {
        let storyboard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        if self.sessionStatus!{
            let vc = storyboard.instantiateViewController(withIdentifier: "ShowLoginPopVC") as! ShowLoginPopVC
            self.present(vc, animated: true, completion: nil)
        }else{
            
        }
        Async.background({
            PlayVideoManager.instance.dislikeCommentReplies(User_id: self.userId ?? 0, Session_Token: self.sessionId ?? "", Type: "dislike", Reply_id: id) { (success, sessionError, error) in
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
    
    
    func replyComments(index: Int) {
//        let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
//        let vc = storyBoard.instantiateViewController(withIdentifier: "RepliesVC") as! RepliesVC
//        vc.commentObject = self.commentsArray[index]
//        self.present(vc, animated: true, completion: nil)
        log.verbose("replycomment at Index = \(index)")
    }
}
