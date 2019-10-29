//
//  Articles-TableCell.swift
//  Playtube
//
//  Created by Macbook Pro on 25/03/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
protocol ShowArticlesDetailsDelegate {
    func didShowArticlesDetails(index:Int)
}
protocol ShowProfileDelegate {
    func didShowProfileDetails(index:Int)
}

class Articles_TableCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var delegate:ShowArticlesDetailsDelegate!
    var indexPath:Int!
    var profileDelegate:ShowProfileDelegate!
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        self.profileDelegate.didShowProfileDetails(index: indexPath)
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    @IBAction func readMorePressed(_ sender: Any) {
        self.delegate.didShowArticlesDetails(index: self.indexPath)
    }
}
