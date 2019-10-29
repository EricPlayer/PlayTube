//
//  MyChannelVC.swift
//  Playtube


import UIKit
import XLPagerTabStrip
import PlaytubeSDK
import ActionSheetPicker_3_0

class MyChannelVC: ButtonBarPagerTabStripViewController {
let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var avatarImage: UIImageView!
    override func viewDidLoad() {
        self.SetupPagerTab()
        super.viewDidLoad()
        self.view.backgroundColor = AppSettings.appColor

    self.showData()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
    self.navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func uploadPressed(_ sender: Any) {
        ActionSheetStringPicker.show(withTitle: "Upload", rows: ["Import", "Upload"], initialSelection: 1, doneBlock: { (picker, index, values) in
            print("values = \(values)")
            print("indexes = \(index)")
                            print("picker = \(picker)")
            
            let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
            let vc = storyBoard.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
            if index == 0{
                vc.boolStatus = false
            }else{
                vc.boolStatus = true
            }
            self.navigationController?.pushViewController(vc, animated: true)
                            return
          
        }, cancel: { ActionMultipleStringCancelBlock in return }, origin: sender)

        
    }
    
    @IBAction func editBtnPressed(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
        vc.settingsEmail = appDelegate?.myChannelInfo?.email
        vc.isverifed = appDelegate?.myChannelInfo?.verified
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func settingBtnPressed(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
         vc.settingsEmail = appDelegate?.myChannelInfo?.email
        vc.isverifed = appDelegate?.myChannelInfo?.verified
        self.navigationController?.pushViewController(vc, animated: true)
    }
    private func showData(){
        if Reachability.isConnectedToNetwork(){
            let myChannelInfo = self.appDelegate?.myChannelInfo
            if let avatar = URL.init(string:(myChannelInfo?.avatar)!){
                avatarImage.sd_setImage(with: avatar , placeholderImage: UIImage(named: "maxresdefault"))
            }
            if let cover = URL.init(string:(myChannelInfo?.cover)!){
                coverImage.sd_setImage(with: cover , placeholderImage: UIImage(named: "maxresdefault"))
            }
            self.userNameLabel.text = myChannelInfo?.username
        }else{
            self.view.makeToast(InterNetError)
        }
       
    }
    func SetupPagerTab(){
        let barColor = UIColor(red:76/255, green: 165/255, blue: 255/255, alpha: 1)
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = barColor
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 15)
        settings.style.selectedBarHeight = 3
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .blue
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        let color = UIColor(red:255/255, green: 255/255, blue: 255/255, alpha: 0.75)
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = color
            newCell?.label.textColor = .white
            print("OldCell",oldCell)
            print("NewCell",newCell)
        }
    }
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let storyBoard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
        let videosVC = storyBoard.instantiateViewController(withIdentifier: "VideosVC") as! VideosVC
        let playlistVC = storyBoard.instantiateViewController(withIdentifier: "PlaylistVC") as! PlaylistVC
         let aboutVC = storyBoard.instantiateViewController(withIdentifier: "AboutVC") as! AboutVC
        return [videosVC,playlistVC,aboutVC]
  
    }
    
}
