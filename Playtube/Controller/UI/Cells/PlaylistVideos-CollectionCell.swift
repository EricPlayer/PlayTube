//
//  PlaylistVideos-CollectionCell.swift
//  Playtube


import UIKit
import DropDown
class PlaylistVideos_CollectionCell: UICollectionViewCell {
    @IBOutlet weak var imageViewLabel: UIImageView!
     @IBOutlet weak var profileImageViewLabel: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var moreButtonLabel: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var isVerifiedLabel: UIImageView!
    
    @IBOutlet weak var durationView: UIView!
    
    var delegate:ShowPresentControllerDelegate!
    var cellIndexDelegate:IndexofCellDelegate!
    var indexPath:Int!
    let moreDropdown = DropDown()
    @IBAction func moreButton(_ sender: Any) {
        moreDropdown.show()
        self.cellIndexDelegate.indexofCell(Index: indexPath)
    }
      func TemperatureDropDownFunc(){
        moreDropdown.dataSource = ["Add to Watch Later", "Delete From list","Not interested","Share","Report"]
        moreDropdown.anchorView = self.moreButtonLabel.superview
        moreDropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            if index == 0{
                self.delegate.showController(Index: index)
            }else if index == 1{
//                self.delegate.showController(Index: index)
                
            }else if index == 2{
                 self.delegate.showController(Index: index)
            }else if index == 3{
                
                 self.delegate.showController(Index: index)
            }else{
                self.delegate.showController(Index: index)
            }
            log.verbose("Selected item: \(item) at index: \(index)")
            
        }
        moreDropdown.bottomOffset = CGPoint(x: 312, y:230)
        moreDropdown.width = 200
        moreDropdown.direction = .any
    }
    
   
}
