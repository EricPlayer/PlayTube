//
//  Playlist-TableCell.swift
//  Playtube


import UIKit
import DropDown
class Playlist_TableCell: UITableViewCell {
    @IBOutlet weak var imageLabel: UIImageView!
    @IBOutlet weak var videosLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var videosCount: UILabel!
    @IBOutlet weak var moreButtonLabel: UIButton!
    
    var delegate:ShowPresentControllerDelegate!
    var cellIndexDelegate:IndexofCellDelegate!
    var indexPath:Int!
    let moreDropdown = DropDown()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        TemperatureDropDownFunc()
        // Configure the view for the selected state
    }
    @IBAction func moreButton(_ sender: Any) {
        moreDropdown.show()
        self.cellIndexDelegate.indexofCell(Index: indexPath)
    }
    private  func TemperatureDropDownFunc(){
        moreDropdown.dataSource = ["Edit", "Delete"]
        moreDropdown.anchorView = self.moreButtonLabel.superview
        moreDropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            if index == 0{
                self.delegate.showController(Index: index)
            }else{
                 self.delegate.showController(Index: index)
            }
            log.verbose("Selected item: \(item) at index: \(index)")
            
        }
        moreDropdown.bottomOffset = CGPoint(x: 312, y:60)
        moreDropdown.width = 200
        moreDropdown.direction = .any
    }
    
    
}
