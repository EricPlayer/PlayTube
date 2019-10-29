//
//  UserChat-TableCell1.swift
//  Playtube
//
//  Created by Macbook Pro on 01/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit

class UserChat_TableCell1: UITableViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
