//
//  VerifiedVC.swift
//  Playtube
//
//  Created by Macbook Pro on 08/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class VerifiedVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func viewWillAppear(_ animated: Bool) {
        
        self.NavigationbarConfiguration()
    }
    private func NavigationbarConfiguration(){
        self.tabBarController?.tabBar.isHidden = true
        self.title = "Verification"
        let color = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color ]
        self.navigationController?.navigationBar.tintColor = color
    }
}
