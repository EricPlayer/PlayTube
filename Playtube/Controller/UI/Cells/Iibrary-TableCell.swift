//
//  Iibrary-TableCell.swift
//  Playtube


import UIKit

class Iibrary_TableCell: UITableViewCell {

    
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var libraryNameLabel: UILabel!
    @IBOutlet weak var imageIconLabel: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
