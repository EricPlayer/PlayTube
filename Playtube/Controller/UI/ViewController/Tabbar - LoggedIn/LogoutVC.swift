//
//  LogoutVC.swift
//  Playtube


import UIKit
import PlaytubeSDK

class LogoutVC: BaseViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func okPressed(_ sender: Any) {
        self.showProgressDialog(text: "Loading...")
         let timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.update), userInfo: nil, repeats: false)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func update() {
        UserDefaults.standard.clearUserDefaults()
        let storyBoard = UIStoryboard(name: "Auth", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "Login")
        appDelegate.window?.rootViewController = vc
        self.dismiss(animated: true, completion: nil)
       
        
        
    }
    
}
