//
//  ArticlesComment-TableCell.swift
//  Playtube
//
//  Created by Macbook Pro on 29/03/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit



class ArticlesComment_TableCell: UITableViewCell {
    
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
        self.delegate.disLikeComments(id: index, dislikebutton: disLikeBtn, likebutton: likeBtn, likeCount: likeCount, dislikeCount: dislikeCount, likeCountLabel: disLikeLabel, dislikeCountLabel: disLikeLabel)
    }
    
    @IBAction func replyRessed(_ sender: Any) {
        self.delegate.replyComments(index: indexPath)
    }
    
}

