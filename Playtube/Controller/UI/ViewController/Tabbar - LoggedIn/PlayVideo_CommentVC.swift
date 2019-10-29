//
//  PlayVideo_CommentVC.swift
//  Playtube


import UIKit
import XLPagerTabStrip
import Async
import PlaytubeSDK

class PlayVideo_CommentVC: BaseViewController ,IndicatorInfoProvider{
    
    @IBOutlet weak var viewBottonConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showStack: UIStackView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var keyBoardView: UIView!
    
    var videoId:Int? = nil
    private var userId:Int? = nil
    private var sessionId:String? = nil
    private var sessionStatus:Bool? = nil
    private var commentsArray = [CommentModel.Datum]()
    private let appDelegate = UIApplication.shared.delegate as? AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
          self.view.backgroundColor = AppSettings.appColor
        self.tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        self.sendBtn.layer.cornerRadius = self.sendBtn.frame.height / 2
        self.textViewPlaceHolder()
        self.sessionStatus = UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session).isEmpty
        if UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session).isEmpty{
            log.verbose("getUserSession = \(UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session))")
            self.fetchData()
            
        }else{
            log.verbose("getUserSession = \(UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session))")
            self.getUserSession()
            self.fetchData()
           
        }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
       
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
      self.viewBottonConstraint.constant = 300
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.viewBottonConstraint.constant = 0
    }
 
    @IBAction func sendPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        if self.sessionStatus!{
            let vc = storyboard.instantiateViewController(withIdentifier: "ShowLoginPopVC") as! ShowLoginPopVC
            self.present(vc, animated: true, completion: nil)
        }else{
            if Reachability.isConnectedToNetwork(){
                let commentText = self.commentTextView.text
                self.videoId = appDelegate?.commentVideoId
                log.verbose("self.VideoId = \(self.videoId)")
                self.showProgressDialog(text: "Loading...")
                Async.background({
                    PlayVideoManager.instance.addComments(User_id: self.userId ?? 0, Session_Token: self.sessionId ?? "", VideoId:self.videoId ?? 0, Comment_Text:commentText ?? "", completionBlock: { (success, sessionError, error) in
                        if success != nil{
                            Async.main({
                                log.verbose("SUCCESS")
                                log.verbose("success = \(success?.message)")
                                self.commentsArray.removeAll()
                                self.fetchData()
                                
                                
                            })
                        }else if sessionError != nil{ self.view.makeToast(sessionError?.errors.errorText)
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
    
    @IBAction func smilePressed(_ sender: Any) {
      
        
    }
    private func fetchData(){
        if Reachability.isConnectedToNetwork(){
            self.videoId = appDelegate?.commentVideoId
            log.verbose("self.VideoId = \(self.videoId)")
//            self.showProgressDialog(text: "Loading...")
            Async.background({
                PlayVideoManager.instance.fetchComments(User_id: self.userId ?? 0, Session_Token: self.sessionId ?? "", VideoId: self.videoId ?? 0, completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            log.verbose("SUCCESS = \(success)")
                        
                            self.commentsArray = success?.data ?? []
                            if !self.commentsArray.isEmpty{
                                self.tableView.reloadData()
                                self.tableView.isHidden = false
                                self.showStack.isHidden = true
                                self.dismissProgressDialog()
                            }else{
                                
                                self.tableView.isHidden = true
                                self.showStack.isHidden = false
                                self.dismissProgressDialog()
                            }
                            
                        })
                    }else if sessionError != nil{ self.view.makeToast(sessionError?.errors!.errorText)
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
    
    private  func getUserSession(){
        log.verbose("getUserSession = \(UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session))")
        let localUserSessionData = UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session)
        self.userId = localUserSessionData[Local.USER_SESSION.user_id] as! Int
        self.sessionId = localUserSessionData[Local.USER_SESSION.session_id] as! String
    }
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "COMMENTS")
        
    }
    private func textViewPlaceHolder(){
        commentTextView.delegate = self
        commentTextView.text = "Your Comment..."
        commentTextView.textColor = UIColor.lightGray
    }
}
extension PlayVideo_CommentVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.commentsArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayVideo_Comments_TableCell") as? PlayVideo_Comments_TableCell
        cell?.delegate = self
       
        let commentObject = self.commentsArray[indexPath.row]
         cell?.index = commentObject.id
        cell?.likeCount = commentObject.likes
        cell?.dislikeCount = commentObject.disLikes
        cell?.indexPath = indexPath.row
        cell?.commentsLabel.text = commentObject.text
        cell?.timeLabel.text = commentObject.textTime
        let url = URL.init(string:commentObject.commentUserData!.avatar ?? "")
        cell?.profileImage.sd_setImage(with: url , placeholderImage: UIImage(named: "maxresdefault"))
        cell?.likesLabel.text =  "\(commentObject.likes)"
        cell?.disLikeLabel.text =  "\(commentObject.disLikes)"
        cell?.replyLabel.text = "\(commentObject.repliesCount)"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
extension PlayVideo_CommentVC:UITextViewDelegate{
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
extension PlayVideo_CommentVC:LikeDisLikeDelegate{
 
    func likeComments(id: Int,likebutton: UIButton, dislikebutton: UIButton, likeCount: Int?, dislikeCount: Int?, likeCountLabel: UILabel, dislikeCountLabel: UILabel) {
        let storyboard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        if self.sessionStatus!{
            let vc = storyboard.instantiateViewController(withIdentifier: "ShowLoginPopVC") as! ShowLoginPopVC
            self.present(vc, animated: true, completion: nil)
        }else{
            log.verbose("id for comment = \(id)")
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
    
    func disLikeComments(id: Int, dislikebutton: UIButton, likebutton: UIButton, likeCount: Int?, dislikeCount: Int?, likeCountLabel: UILabel, dislikeCountLabel: UILabel) {
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
        let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "RepliesVC") as! RepliesVC
        vc.commentObject = self.commentsArray[index]
        self.present(vc, animated: true, completion: nil)
           log.verbose("replycomment at Index = \(index)")
    }
}


