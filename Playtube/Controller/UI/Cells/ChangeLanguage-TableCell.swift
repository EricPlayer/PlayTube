//
//  ChangeLanguage-TableCell.swift
//  Playtube
//
//  Created by Macbook Pro on 07/03/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
protocol SelectLanguageDelegate {
    func selectLanguage(index:Int,Button:UIButton)
}
class ChangeLanguage_TableCell: UITableViewCell {
    @IBOutlet weak var languageLabel: UILabel!
    
    @IBOutlet weak var selectBtn: UIButton!
    var delegate:SelectLanguageDelegate!
    var indexPath:Int!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    @IBAction func selectBtnPressed(_ sender: Any) {
        self.delegate.selectLanguage(index: indexPath, Button: selectBtn)
    }
    
}
