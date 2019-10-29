//
//  TabbarVC.swift
//  Playtube
//


import UIKit
import SwipeableTabBarController
import PlaytubeSDK

class TabbarVC: UITabBarController {
let appDelegate = UIApplication.shared.delegate as? AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.appDelegate?.UserSession())!{
            log.verbose("UserSession = \(self.appDelegate?.UserSession())")
        }else{
            log.verbose("UserSession = \(self.appDelegate?.UserSession())")
            if let tabBarController = self.tabBarController {
                
                let indexToRemove = 3
                if indexToRemove < (tabBarController.viewControllers?.count)! {
                    var viewControllers = tabBarController.viewControllers
                    viewControllers?.remove(at: indexToRemove)
                    tabBarController.viewControllers = viewControllers
                }
            }
        }
      
 
    }

}
