//
//  PlayVideo_Comments-TableCell.swift
//  Playtube


import UIKit
protocol LikeDisLikeDelegate{
    func likeComments(id:Int,likebutton:UIButton,dislikebutton:UIButton,likeCount:Int?,dislikeCount:Int?,likeCountLabel:UILabel,dislikeCountLabel:UILabel)
    func disLikeComments(id:Int,dislikebutton:UIButton,likebutton:UIButton,likeCount:Int?,dislikeCount:Int?,likeCountLabel:UILabel,dislikeCountLabel:UILabel)
    func replyComments(index:Int)
}
class PlayVideo_Comments_TableCell: UITableViewCell {
    
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var replyBtn: UIButton!
    @IBOutlet weak var disLikeBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var replyLabel: UILabel!
    @IBOutlet weak var disLikeLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var delegate:LikeDisLikeDelegate!
    var index:Int!
    var indexPath:Int!
    var likeCount:Int!
    var dislikeCount:Int!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func likePressed(_ sender: Any) {
        self.delegate.likeComments(id: index, likebutton: likeBtn, dislikebutton: disLikeBtn, likeCount: likeCount, dislikeCount: dislikeCount, likeCountLabel: likesLabel, dislikeCountLabel: disLikeLabel)
    }
    @IBAction func dislikePressed(_ sender: Any) {
        self.delegate.disLikeComments(id: index, dislikebutton: disLikeBtn, likebutton: likeBtn, likeCount: likeCount, dislikeCount: dislikeCount, likeCountLabel: likesLabel, dislikeCountLabel: disLikeLabel)
    }
    
    @IBAction func replyRessed(_ sender: Any) {
        self.delegate.replyComments(index: indexPath)
    }
    
}
