//
//  BaseViewController.swift
//  Playtube


import UIKit
import JGProgressHUD
import PlaytubeSDK
class BaseViewController: UIViewController {
    var hud : JGProgressHUD?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func showProgressDialog(text: String) {
        hud = JGProgressHUD(style: .extraLight)
        
        hud?.textLabel.text = text
        
        hud?.show(in: self.view)
    }
    
    func dismissProgressDialog() {
        hud?.dismiss()
    }
    
    func chnageViewController(storyBoardName:String,Indentifier:String){
        
        let storyBoard = UIStoryboard(name: storyBoardName, bundle: nil)
        let vc  = storyboard?.instantiateViewController(withIdentifier: Indentifier)
        self.present(vc!, animated: true, completion: nil)
    }
    
    
}
