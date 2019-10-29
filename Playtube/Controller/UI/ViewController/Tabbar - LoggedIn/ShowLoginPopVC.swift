//
//  ShowLoginPopVC.swift
//  Playtube
//

import UIKit
import PlaytubeSDK

class ShowLoginPopVC: UIViewController {
let appDelegate = UIApplication.shared.delegate as? AppDelegate
    override func viewDidLoad() {
      
        super.viewDidLoad()
    }
    


    @IBAction func loginPressed(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Auth", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "Login")
        appDelegate!.window?.rootViewController = vc
    }
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
