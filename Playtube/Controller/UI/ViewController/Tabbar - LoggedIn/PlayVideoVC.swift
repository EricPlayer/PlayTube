//
//  PlayVideoVC.swift
//  Playtube


import UIKit
import XLPagerTabStrip
import YouTubePlayer
import MediaPlayer
import MMPlayerView
import Async
import JGProgressHUD
import CircleProgressView
import DropDown
import PlaytubeSDK
import youtube_ios_player_helper

class PlayVideoVC: ButtonBarPagerTabStripViewController,YouTubePlayerDelegate {
    
    @IBOutlet weak var descriptionViewBottonConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionHeight: NSLayoutConstraint!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var publishDateLabel: UILabel!
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var progressView: CircleProgressView!
    @IBOutlet weak var subscribeBtn: UIButton!
    @IBOutlet weak var checkUncheckImage: UIImageView!
    @IBOutlet weak var scrollHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIView!
    @IBOutlet weak var showHideDec: UIButton!
    @IBOutlet weak var youtubeVpView: YTPlayerView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var isVerified: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var dislikeBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playView: UIView!
    @IBOutlet weak var disLikeCountLabel: UILabel!
    @IBOutlet weak var likesCountLabel: UILabel!
    
    var downloadObservation: MMPlayerObservation?
    fileprivate var playerLayer: MMPlayerLayer?
    let moreDropdown = DropDown()
    let addToDropdown = DropDown()
    var hud : JGProgressHUD?
    var videoObject:Data? = nil
    private var userId:Int? = nil
    private var sessionId:String? = nil
    private var sessionStatus:Bool? = false
    private var videoUrl:URL? = nil
    private var status:Bool? = nil
    private var convertedVideoObject:Datum? = nil
     var playListVideoConvertedObject:PlaylistVideosModel.Datum? = nil
    private var id:Int? = 0
    private var appDelegate = UIApplication.shared.delegate as? AppDelegate
    private var suggestedVideosArray = [PlayVideoModel.DataElement]()
    private var likeCount:Int? = 0
    private var dislikeCount:Int? = 0
    private var videoId:String = ""
    
    
    lazy var mmPlayerLayer: MMPlayerLayer = {
        let l = MMPlayerLayer()
        l.cacheType = .memory(count: 5)
        l.coverFitType = .fitToPlayerView
        l.videoGravity = AVLayerVideoGravity.resizeAspect
        l.replace(cover: CoverA.instantiateFromNib())
        return l
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.mmPlayerTransition.present.pass { (config) in
            config.duration = 0.3
        }
    }
    
    override func viewDidLoad() {
        self.SetupPagerTab()
        super.viewDidLoad()
        if AppSettings.ShowDownloadButton == false{
            
            self.downloadBtn.isHidden = true
            self.progressView.isHidden = true
        }else{
            
            self.downloadBtn.isHidden = false
            self.progressView.isHidden = false
        }
        self.view.backgroundColor = AppSettings.appColor
        self.sessionStatus = UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session).isEmpty
        if UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session).isEmpty{
            log.verbose("getUserSession = \(UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session))")
            self.fetchData(VideoObject: (videoObject ?? nil))
        }else{
            log.verbose("getUserSession = \(UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session))")
            self.getUserSession()
            self.fetchData(VideoObject: (videoObject ?? nil))
            
        }
        self.youtubeVpView.delegate = self
        self.downloadVideoOffline()
        self.configDropDownFunc()
        self.configAddtoDropdown()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(tapGestureRecognizer)
        
      
//        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
//        swipeDown.direction = .down
//        self.view.addGestureRecognizer(swipeDown)
        self.descriptionView.isHidden = true
        self.descriptionHeight.constant = 0
        
    }
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ChannelDetailsVC") as! ChannelDetailsVC
        vc.channelId = self.convertedVideoObject!.owner!.id
        self.navigationController?.pushViewController(vc, animated: true)
    }
//    @objc func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
//        if gesture.direction == UISwipeGestureRecognizer.Direction.down {
//            //            print("Swipe Down")
//            (self.presentationController as? MMPlayerPassViewPresentatinController)?.shrinkView()
//        }
//    }
//    
    override func viewWillAppear(_ animated: Bool) {
        self.NavigationbarConfiguration()
        
    }
    
    private func fetchData(VideoObject:Data?){
        if VideoObject == nil{
           
            self.id = playListVideoConvertedObject?.id
            if playListVideoConvertedObject?.videos!.source == "YouTube"{
                self.youtubeVideoPlayerSetup(urlString: (playListVideoConvertedObject?.videos!.videoLocation ?? ""))
            }else{
                self.customVideoPlayerSetup(urlString: (playListVideoConvertedObject?.videos!.videoLocation ?? ""))
            }
            self.titleLabel.text = (self.playListVideoConvertedObject?.videos?.title!.htmlAttributedString) ?? ""
            if let avatar = URL.init(string:(playListVideoConvertedObject?.videos?.owner!.avatar)!){
                profileImage.sd_setImage(with: avatar , placeholderImage: UIImage(named: "maxresdefault"))
                self.usernameLabel.text = self.playListVideoConvertedObject?.videos!.owner!.username!.htmlAttributedString ?? ""
                self.timeLabel.text = self.playListVideoConvertedObject?.videos?.timeAgo
                if let viewsCount = self.playListVideoConvertedObject?.videos?.views!.roundedWithAbbreviations{
                    self.viewsLabel.text = "\(viewsCount) Views"
                }
            }
            self.descriptionLabel.text = playListVideoConvertedObject?.videos?.description!.htmlAttributedString
            self.categoryLabel.text = playListVideoConvertedObject?.videos?.categoryName
            self.videoId = self.playListVideoConvertedObject?.videos?.videoID ?? ""
        }else{
            convertedVideoObject = try? PropertyListDecoder().decode(Datum.self,from: VideoObject!)
            log.verbose("videoObject = \(convertedVideoObject)")
            self.id = convertedVideoObject?.id
            if convertedVideoObject?.source == "YouTube"{
                self.youtubeVideoPlayerSetup(urlString: (convertedVideoObject?.videoLocation ?? ""))
            }else{
                self.customVideoPlayerSetup(urlString: (convertedVideoObject?.videoLocation ?? ""))
            }
            self.titleLabel.text = (self.convertedVideoObject?.title?.htmlAttributedString) ?? ""
            if let avatar = URL.init(string:(convertedVideoObject?.owner!.avatar)!){
                profileImage.sd_setImage(with: avatar , placeholderImage: UIImage(named: "maxresdefault"))
                self.usernameLabel.text = self.convertedVideoObject?.owner!.username!.htmlAttributedString ?? ""
                self.timeLabel.text = self.convertedVideoObject?.timeAgo
                if let viewsCount = self.convertedVideoObject?.views!.roundedWithAbbreviations{
                    self.viewsLabel.text = "\(viewsCount) Views"
                }
            }
            self.descriptionLabel.text = convertedVideoObject?.description!.htmlAttributedString
            self.categoryLabel.text = convertedVideoObject?.categoryName
            self.videoId = self.convertedVideoObject?.videoID ?? ""
        }
       
        if Reachability.isConnectedToNetwork(){
            
            log.verbose("self.appDelegate?.videoId = \(self.appDelegate?.videoId)")
            self.showProgressDialog(text: "Loading...")
            Async.background({
                PlayVideoManager.instance.getVideosDetailsByVideoId(User_id: self.userId ?? 0, Session_Token: self.sessionId ?? "", VideoId: self.videoId ?? "", completionBlock: { (success, sessionError, error) in
                    if success != nil{
                        Async.main({
                            self.likeCount = success!.data!.likes
                            self.dislikeCount = success!.data!.dislikes
                            self.likesCountLabel.text = "\(self.likeCount ?? 0)"
                            self.disLikeCountLabel.text = "\(success!.data!.dislikes ?? 0)"
                            if self.appDelegate?.myChannelInfo?.username == self.convertedVideoObject?.owner?.username{
                                self.subscribeBtn.isHidden = true
                            }else{
                                self.subscribeBtn.isHidden = false
                            }
                            
                            if success?.data!.isLiked == 0{
                                self.likeBtn.setImage(UIImage(named: "like"), for: .normal)
                                
                            }else{
                                self.likeBtn.setImage(UIImage(named: "likeblue"), for: .normal)
                            }
                            if success?.data!.isDisliked == 0{
                                self.dislikeBtn.setImage(UIImage(named: "dislike"), for: .normal)
                            }else{
                                self.dislikeBtn.setImage(UIImage(named: "dislikeblue-1"), for: .normal)
                            }
                            log.verbose("subscribe = \(success?.data!.isSubscribed)")
                            log.verbose("like = \(success?.data!.isLiked)")
                            log.verbose("dislike = \(success?.data!.isDisliked)")
                           
                            if success?.data!.isSubscribed == 0{
                                self.subscribeBtn.setTitle("    SUBSCRIBE", for: .normal)
                                self.checkUncheckImage.image = UIImage(named: "add")
                                self.subscribeBtn.setTitleColor(.white, for: .normal)
                            }else{
                                self.subscribeBtn.setTitle("      SUBSCRIBED", for: .normal)
                                self.checkUncheckImage.image = UIImage(named: "ic_action_check_mark")
                                self.subscribeBtn.setTitleColor(.white, for: .normal)
                                
                            }
                            //                            self.suggestedVideosArray = success?.data.suggestedVideos ?? []
                            
                            
                            log.verbose("SUCCESS")
                            self.dismissProgressDialog()
                            
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
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = false
         mmPlayerLayer.player?.pause()
    }
    
    @IBAction func likePressed(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        if self.sessionStatus!{
            let vc = storyboard.instantiateViewController(withIdentifier: "ShowLoginPopVC") as! ShowLoginPopVC
            self.present(vc, animated: true, completion: nil)
        }else{
            Async.background({
                PlayVideoManager.instance.likeDislikeVideos(User_id: self.userId ?? 0, Session_Token: self.sessionId ??
                    "", Video_Id: self.id ?? 0, Like_Type: "like", completionBlock: { (success, sessionError, error) in
                        if success != nil{
                            Async.main({
                                log.verbose("success \(success?.successType) ")
                                
                                if success?.successType == "added_like"{
                                    self.likeBtn.setImage(UIImage(named: "likeblue"), for: .normal)
                                    log.verbose("success = \(success?.successType)")
                                    self.view.makeToast("Liked")
                                    if self.likeBtn.imageView!.image == UIImage(named: "likeblue"){
                                        self.likeCount = self.likeCount! + 1
                                        self.likesCountLabel.text = "\(self.likeCount ?? 0)"
                                        
                                    }
                                    if self.dislikeBtn.imageView!.image == UIImage(named: "dislikeblue-1"){
                                        self.dislikeBtn.setImage(UIImage(named: "dislike"), for: .normal)
                                        self.dislikeCount = self.dislikeCount! - 1
                                        self.disLikeCountLabel.text = "\(self.dislikeCount ?? 0)"
                                        
                                    }
                                    self.dismissProgressDialog()
                                }else{
                                    self.likeBtn.setImage(UIImage(named: "like"), for: .normal)
                                    log.verbose("success = \(success?.successType)")
                                    self.likeCount = self.likeCount! - 1
                                    self.likesCountLabel.text = "\(self.likeCount ?? 0)"
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
    
    
    @IBAction func disLikePressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        if self.sessionStatus!{
            let vc = storyboard.instantiateViewController(withIdentifier: "ShowLoginPopVC") as! ShowLoginPopVC
            self.present(vc, animated: true, completion: nil)
        }else{
            Async.background({
                PlayVideoManager.instance.likeDislikeVideos(User_id: self.userId ?? 0, Session_Token: self.sessionId ??
                    "", Video_Id: self.id ?? 0, Like_Type: "dislike", completionBlock: { (success, sessionError, error) in
                        if success != nil{
                            Async.main({
                                log.verbose("success \(success?.successType) ")
                                
                                if success?.successType == "added_dislike"{
                                    self.dislikeBtn.setImage(UIImage(named: "dislikeblue-1"), for: .normal)
                                    log.verbose("success = \(success?.successType)")
                                    self.view.makeToast("Disliked")
                                    if self.dislikeBtn.imageView!.image == UIImage(named: "dislikeblue-1"){
                                        self.dislikeCount = self.dislikeCount! + 1
                                        self.disLikeCountLabel.text = "\(self.dislikeCount ?? 0)"
                                        
                                    }
                                    if self.likeBtn.imageView!.image == UIImage(named: "likeblue"){
                                        self.likeBtn.setImage(UIImage(named: "like"), for: .normal)
                                        self.likeCount = self.likeCount! - 1
                                        self.likesCountLabel.text = "\(self.likeCount ?? 0)"
                                        
                                    }
                                    self.dismissProgressDialog()
                                }else{
                                    self.dislikeBtn.setImage(UIImage(named: "dislike"), for: .normal)
                                    log.verbose("success = \(success?.successType)")
                                    self.dismissProgressDialog()
                                    self.dislikeCount = self.dislikeCount! - 1
                                    self.disLikeCountLabel.text = "\(self.dislikeCount ?? 0)"
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
    
    @IBAction func morePressed(_ sender: Any) {
        moreDropdown.show()
    }
    @IBAction func downloadPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        if self.sessionStatus!{
            let vc = storyboard.instantiateViewController(withIdentifier: "ShowLoginPopVC") as! ShowLoginPopVC
            self.present(vc, animated: true, completion: nil)
        }else{
            self.setOfflineDownload()
            if #available(iOS 11.0, *) {
                guard let downloadURL = self.convertedVideoObject?.videoLocation else {
                    return
                }
                let url = URL(string: downloadURL)
                if let info = MMPlayerDownloader.shared.localFileFrom(url: url!)  {
                    MMPlayerDownloader.shared.deleteVideo(info)
                    let alert = UIAlertController(title: "Delete completed", message: "", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                DispatchQueue.main.async {
                    MMPlayerDownloader.shared.download(url: url!)
                }
            }
            else {
                let alert = UIAlertController(title: "download only for ios 11", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            log.verbose("Download Button Pressed")
        }
        
      
    }
    
    @IBAction func sharePressed(_ sender: Any) {
        self.shareVideo(stringURL: (convertedVideoObject?.videoLocation)!)
    }
    
    
    @IBAction func addToPressed(_ sender: Any) {
        addToDropdown.show()
    }
    @IBAction func subscribeBtnPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        if self.sessionStatus!{
            let vc = storyboard.instantiateViewController(withIdentifier: "ShowLoginPopVC") as! ShowLoginPopVC
            self.present(vc, animated: true, completion: nil)
        }else{
            var channelId:Int? = 0
            if self.convertedVideoObject == nil{
                channelId = playListVideoConvertedObject?.videos!.owner!.id
            }else{
                channelId = convertedVideoObject?.owner!.id
            }
            
            log.verbose("channelId = \(channelId)")
            if Reachability.isConnectedToNetwork(){
                Async.background({
                    PlayVideoManager.instance.subUnsubChannel(User_id: self.userId ?? 0, Session_Token: self.sessionId ?? "", Channel_Id: channelId ?? 0) { (success, sessionError, error) in
                        if success != nil{
                            Async.main({
                                log.verbose("success \(success?.code) ")
                                self.dismissProgressDialog()
                                if success?.code == 1{
                                    self.subscribeBtn.setTitle("      SUBSCRIBED", for: .normal)
                                    self.checkUncheckImage.image = UIImage(named: "ic_action_check_mark")
                                    self.view.makeToast("Channel Subscribed")
                                    
                                }else{
                                    self.subscribeBtn.setTitle("    SUBSCRIBE", for: .normal)
                                    self.checkUncheckImage.image = UIImage(named: "add")
                                    self.view.makeToast("Channel Unscubscribed")
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
                
            }else{
                self.view.makeToast(InterNetError)
            }
            
        }
      
        
        
    }
   
    var statusDec:Bool? = false
    @IBAction func showDecPressed(_ sender: Any) {
//                statusDec = !statusDec!
//                if statusDec!{
//                    self.descriptionView.isHidden = false
//                    self.showHideDec.setImage(UIImage(named: "uparrow"), for: .normal)
//                    let height = estimatedHeightOfLabel(text: self.descriptionLabel.text!)
//                    self.descriptionHeight.constant = height
//        //            self.heightContraint.constant = self.descriptionLabel.frame.height
//                    self.scrollHeight.constant = self.scrollHeight.constant + height + height
//                    self.descriptionViewBottonConstraint.constant = height + height + height
//                }else{
//                    self.descriptionView.isHidden = true
//                    self.descriptionHeight.constant = 0
//                    self.descriptionViewBottonConstraint.constant = 8
//
//                }
    }
    func estimatedHeightOfLabel(text: String) -> CGFloat {
        
        let size = CGSize(width: view.frame.width - 16, height: 1000)
        
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10)]
        
        let rectangleHeight = String(text).boundingRect(with: size, options: options, attributes: attributes, context: nil).height
        
        return rectangleHeight
    }
    
    fileprivate func downloadVideoOffline() {
        
        guard let downloadURL = self.convertedVideoObject?.videoLocation else {
            return
        }
        let url = URL(string: downloadURL)
        if #available(iOS 11.0, *) {
            downloadObservation = MMPlayerDownloader.shared.observe(downloadURL: url!) { [weak self] (status) in
                switch status {
                case .downloadWillStart:
                    self?.downloadBtn.isHidden = true
                    self?.progressView.isHidden = false
                    self?.progressView.progress = 0
                case .cancelled:
                    print("Canceld")
                case .completed:
                    DispatchQueue.main.async {
                        self?.downloadBtn.setImage(UIImage(named: "downloaded"), for: .normal)
                        self?.downloadBtn.isHidden = false
                        self?.progressView.isHidden = true
                    }
                case .downloading(let value):
                    self?.downloadBtn.isHidden = true
                    self?.progressView.isHidden = false
                    self?.progressView.progress = Double(value)
                    print("Exporting \(value) \(downloadURL)")
                case .failed(let err):
                    DispatchQueue.main.async {
                        //                        self?.downloadBtn.setTitle("Download", for: .normal)
                        self!.downloadBtn.setImage(UIImage(named: "download"), for: .normal)
                    }
                    
                    self?.downloadBtn.isHidden = false
                    self?.progressView.isHidden = true
                    print("Download Failed \(err)")
                case .none:
                    DispatchQueue.main.async {
                        //                        self?.downloadBtn.setTitle("Download", for: .normal)
                        self?.downloadBtn.setImage(UIImage(named: "download"), for: .normal)
                    }
                    self?.downloadBtn.isHidden = false
                    self?.progressView.isHidden = true
                case .exist:
                    DispatchQueue.main.async {
                        self?.downloadBtn.setImage(UIImage(named: "downloaded"), for: .normal)
                    }
                    self?.downloadBtn.isHidden = false
                    self?.progressView.isHidden = true
                }
            }
        } else {
            let alert = UIAlertController(title: "download only for ios 11", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    private func setOfflineDownload(){
      
        let objectToEncode = convertedVideoObject
        let data = try? PropertyListEncoder().encode(objectToEncode)
        var getWatchLaterData = UserDefaults.standard.getOfflineDownload(Key: Local.OFFLINE_DOWNLOAD.offline_download)
        if UserDefaults.standard.getOfflineDownload(Key: Local.OFFLINE_DOWNLOAD.offline_download).contains(data!){
            self.view.makeToast("Already Downloaded")
        }else{
            getWatchLaterData.append(data!)
            UserDefaults.standard.setOfflineDownload(value: getWatchLaterData, ForKey: Local.OFFLINE_DOWNLOAD.offline_download)
            self.view.makeToast("downloading...")
        }
        
        
        
    }
 
    private func NavigationbarConfiguration(){
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = false
        //        self.title = "Settings"
        let color = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color ]
        self.navigationController?.navigationBar.tintColor = color
    }
    private func youtubeVideoPlayerSetup(urlString:String){
        //        self.appDelegate?.videoId = convertedVideoObject?.videoID
        self.playView.isHidden = true
        self.youtubeVpView.isHidden = false

        let playerVars = ["playsinline": 1, "autohide": 1, "showinfo": 0, "controls":1, "origin" : "http://youtube.com"] as [String : Any] // 0: will play video in fullscreen
        let strYoutubeKey = extractYoutubeIdFromLink(link: urlString)
        if(strYoutubeKey != nil){
            self.youtubeVpView.load(withVideoId: strYoutubeKey!, playerVars: playerVars)
        }
    }
    private func customVideoPlayerSetup(urlString:String){
        self.playView.isHidden = false
        self.youtubeVpView.isHidden = true
        //        self.appDelegate?.videoId = convertedVideoObject?.videoID
        mmPlayerLayer.playView = playView
        mmPlayerLayer.getStatusBlock { [weak self] (status) in
            switch status {
            case .failed(let err):
                let alert = UIAlertController(title: "err", message: err.description, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            case .ready:
                print("Ready to Play")
            case .playing:
                print("Playing")
            case .pause:
                print("Pause")
            case .end:
                print("End")
            default: break
            }
        }
        let url = URL(string: urlString)
        mmPlayerLayer.set(url: url)
        mmPlayerLayer.resume()
    }
    private func SetupPagerTab(){
        let barColor = UIColor(red:76/255, green: 165/255, blue: 255/255, alpha: 1)
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = barColor
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 15)
        settings.style.selectedBarHeight = 3
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .blue
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
//        settings.style.buttonBarLeftContentInset = 0
//        settings.style.buttonBarRightContentInset = 0
        let color = UIColor(red:154/255, green: 154/255, blue: 154/255, alpha: 0.75)
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = color
            newCell?.label.textColor = .black
            print("OldCell",oldCell)
            print("NewCell",newCell)
        }
    }
    private  func configDropDownFunc(){
        moreDropdown.dataSource = ["Report","Help & Feedback", "Make Video Offline"]
        moreDropdown.anchorView = self.moreBtn.superview
        moreDropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            if index == 0{
                let storyboard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
                if self.sessionStatus!{
                    let vc = storyboard.instantiateViewController(withIdentifier: "ShowLoginPopVC") as! ShowLoginPopVC
                    self.present(vc, animated: true, completion: nil)
                }else{
                    let storyboard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "ReportVideoVC") as! ReportVideoVC
                    vc.videoId = self.convertedVideoObject!.id
                    self.present(vc, animated: true, completion: nil)
                }
                
            }else if index == 1{
                let termOfUseURL = URL(string: API.WEBSITE_URL.HelpAndFeedback)
                
                UIApplication.shared.openURL(termOfUseURL!)
                
            }else{
            }
            log.verbose("Selected item: \(item) at index: \(index)")
            
        }
        moreDropdown.bottomOffset = CGPoint(x: 312, y:40)
        moreDropdown.width = 170
        moreDropdown.direction = .any
    }
    private  func configAddtoDropdown(){
        addToDropdown.dataSource = ["Watch later", "Playlist"]
        addToDropdown.anchorView = self.moreBtn.superview
        addToDropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            if index == 0{
                
                let storyboard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
                if self.sessionStatus!{
                    let vc = storyboard.instantiateViewController(withIdentifier: "ShowLoginPopVC") as! ShowLoginPopVC
                    self.present(vc, animated: true, completion: nil)
                }else{
                    self.setWatchLater()
                }
               
            }else{
                
                let storyboard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
                if self.sessionStatus!{
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
                                    
                                    let vc = storyboard.instantiateViewController(withIdentifier: "SelectAPlaylistVC") as! SelectAPlaylistVC
                                    vc.playlistArray = (success?.myAllPlaylists)!
                                    vc.delegate = self
                                    vc.videoId = self.convertedVideoObject?.id
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
                    
                }
            }
            log.verbose("Selected item: \(item) at index: \(index)")
            
        }
        addToDropdown.bottomOffset = CGPoint(x: 312, y:400)
        addToDropdown.width = 170
        addToDropdown.direction = .any
    }
    private func setWatchLater(){
        log.verbose("Check = \(UserDefaults.standard.getWatchLater(Key: Local.WATCH_LATER.watch_Later))")
        let objectToEncode = convertedVideoObject
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
    private func shareVideo(stringURL:String){
        let someText:String = "Test Video"
        let objectsToShare:URL = URL(string: stringURL)!
        let sharedObjects:[AnyObject] = [objectsToShare as AnyObject,someText as AnyObject]
        let activityViewController = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook,UIActivity.ActivityType.postToTwitter,UIActivity.ActivityType.mail,UIActivity.ActivityType.postToTencentWeibo]
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    private  func getUserSession(){
        log.verbose("getUserSession = \(UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session))")
        let localUserSessionData = UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session)
        self.userId = localUserSessionData[Local.USER_SESSION.user_id] as! Int
        self.sessionId = localUserSessionData[Local.USER_SESSION.session_id] as! String
    }
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        let nextToVC = storyBoard.instantiateViewController(withIdentifier: "PlayVideo_NextToVC") as! PlayVideo_NextToVC
        nextToVC.delegate = self
        //        nextToVC.suggestedVideosArray = self.suggestedVideosArray
        //        nextToVC.videoId = convertedVideoObject?.videoID
        let commentVC = storyBoard.instantiateViewController(withIdentifier: "PlayVideo_CommentVC") as! PlayVideo_CommentVC
        
        return [nextToVC,commentVC]
        
    }
    func playerReady(_ videoPlayer: YouTubePlayerView) {
        log.verbose("Player is ready ...")
    }
    func extractYoutubeIdFromLink(link: String) -> String? {
        let pattern = "((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)"
        guard let regExp = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return nil
        }
        let nsLink = link as NSString
        let options = NSRegularExpression.MatchingOptions(rawValue: 0)
        let range = NSRange(location: 0, length: nsLink.length)
        let matches = regExp.matches(in: link as String, options:options, range:range)
        if let firstMatch = matches.first {
            return nsLink.substring(with: firstMatch.range)
        }
        return nil
    }
}
extension PlayVideoVC: MMPlayerToProtocol {
    func transitionCompleted(player: MMPlayerLayer) {
        self.playerLayer = player
    }
    var ContainerView: UIView {
        get {
            return playView
        }
    }
}
extension PlayVideoVC{
    func showProgressDialog(text: String) {
        hud = JGProgressHUD(style: .extraLight)
        hud?.textLabel.text = text
        hud?.show(in: self.view)
    }
    
    func dismissProgressDialog() {
        hud?.dismiss()
    }
}
extension PlayVideoVC:ShowCreatePlayListDelegate{
 
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
        
    
    
    
}
extension PlayVideoVC:PlayNextVideoDelegate{
    func playNextVideo(nextVideo: Data) {
        mmPlayerLayer.player?.pause()
        self.fetchData(VideoObject: nextVideo)
    }
    
   
    
}


extension PlayVideoVC: YTPlayerViewDelegate{
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        //  print(state)
    }
    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float) {
        //  print(playTime)
    }
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        // print(playerView)
    }
}
