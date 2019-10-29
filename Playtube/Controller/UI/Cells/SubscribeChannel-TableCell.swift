//
//  SubscribeChannel-TableCell.swift
//  Playtube


import UIKit

protocol SubscribeChannelDelegate {
    func subscribeChannel(id:Int,subscribeBtn:UIButton)
}

class SubscribeChannel_TableCell: UITableViewCell {

    @IBOutlet weak var subscribeBtn: UIButton!
    @IBOutlet weak var isVerified: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    var delegate:SubscribeChannelDelegate!
    var id:Int!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func subscribePressed(_ sender: Any) {
        self.delegate.subscribeChannel(id: self.id, subscribeBtn: subscribeBtn)
    }
}
