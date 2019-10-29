//
//  Chats-TableCell.swift
//  Playtube
//
//  Created by Macbook Pro on 31/03/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class Chats_TableCell: UITableViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
