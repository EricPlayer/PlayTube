//
//  Notifications-TableCell.swift
//  Playtube


import UIKit

class Notifications_TableCell: UITableViewCell {
    @IBOutlet weak var userNameLabel: UILabel!

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
