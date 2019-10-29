//
//  CommentModel.swift
//  Playtube


import Foundation
class CommentModel{
   
    struct CommentSuccessModel: Codable {
        let apiStatus, apiVersion, successType: String?
        let data: [Datum]?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case successType = "success_type"
            case data
        }
    }
    struct CommentErrorModel: Codable {
        let apiStatus, apiVersion: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case errors
        }
    }
    
    struct Errors: Codable {
        let errorID, errorText: String?
        enum CodingKeys: String, CodingKey {
            case errorID = "error_id"
            case errorText = "error_text"
        }
    }

    struct Datum: Codable {
        let id, userID, videoID, postID: Int?
        let text: String?
        let time: Int?
        let pinned: String?
        let likes, disLikes, isLikedComment: Int?
        let isCommentOwner: Bool?
        let repliesCount: Int?
        let commentReplies: [CommentReply]?
        let isDislikedComment: Int?
        let commentUserData: UserData?
        let textTime: String?
        
        enum CodingKeys: String, CodingKey {
            case id
            case userID = "user_id"
            case videoID = "video_id"
            case postID = "post_id"
            case text, time, pinned, likes
            case disLikes = "dis_likes"
            case isLikedComment = "is_liked_comment"
            case isCommentOwner = "is_comment_owner"
            case repliesCount = "replies_count"
            case commentReplies = "comment_replies"
            case isDislikedComment = "is_disliked_comment"
            case commentUserData = "comment_user_data"
            case textTime = "text_time"
        }
    }
    
    struct CommentReply: Codable {
        let id, userID, commentID, videoID: Int?
        let postID: Int?
        let text, time: String?
        let isReplyOwner: Bool?
        let replyUserData: UserData?
        let isLikedReply, isDislikedReply, replyLikes, replyDislikes: Int?
        let textTime: String?
        
        enum CodingKeys: String, CodingKey {
            case id
            case userID = "user_id"
            case commentID = "comment_id"
            case videoID = "video_id"
            case postID = "post_id"
            case text, time
            case isReplyOwner = "is_reply_owner"
            case replyUserData = "reply_user_data"
            case isLikedReply = "is_liked_reply"
            case isDislikedReply = "is_disliked_reply"
            case replyLikes = "reply_likes"
            case replyDislikes = "reply_dislikes"
            case textTime = "text_time"
        }
    }
    
    struct UserData: Codable {
        let id: Int?
        let username, email, ipAddress, firstName: String?
        let lastName: String?
        let gender: String?
        let emailCode, deviceID: String?
        let language: String?
        let avatar: String?
        let cover: String?
        let src: String?
        let countryID, age: Int?
        let about: String?
        let google: String?
        let facebook: String?
        let twitter: String?
        let instagram: String?
        let active, admin, verified, lastActive: Int?
        let registered: String?
        let isPro, imports, uploads: Int?
        let wallet, balance: String?
        let videoMon, ageChanged: Int?
        let donationPaypalEmail: String?
        let userUploadLimit: String?
        let twoFactor: Int?
        let lastMonth, name: String?
        let url: String?
        let aboutDecoded: String?
        let balanceOr, nameV, countryName: String?
        let genderText: String?
        let isSubscribedToChannel: Int?
        
        enum CodingKeys: String, CodingKey {
            case id, username, email
            case ipAddress = "ip_address"
            case firstName = "first_name"
            case lastName = "last_name"
            case gender
            case emailCode = "email_code"
            case deviceID = "device_id"
            case language, avatar, cover, src
            case countryID = "country_id"
            case age, about, google, facebook, twitter, instagram, active, admin, verified
            case lastActive = "last_active"
            case registered
            case isPro = "is_pro"
            case imports, uploads, wallet, balance
            case videoMon = "video_mon"
            case ageChanged = "age_changed"
            case donationPaypalEmail = "donation_paypal_email"
            case userUploadLimit = "user_upload_limit"
            case twoFactor = "two_factor"
            case lastMonth = "last_month"
            case name, url
            case aboutDecoded = "about_decoded"
            case balanceOr = "balance_or"
            case nameV = "name_v"
            case countryName = "country_name"
            case genderText = "gender_text"
            case isSubscribedToChannel = "is_subscribed_to_channel"
        }
    }
    
    enum About: String, Codable {
        case about = "About"
        case empty = ""
        case musicProducerGamerAmpWebDeveloper = "Music Producer, Gamer &amp; Web Developer."
    }
    
    enum DonationPaypalEmail: String, Codable {
        case empty = ""
        case legittiproductionsGmailCOM = "legittiproductions@gmail.com"
    }
    
    enum Facebook: String, Codable {
        case empty = ""
        case the10213902865859625 = "10213902865859625"
        case yxNPZADPBWEg3UndTVDZAHRnpoNEQ4Vm1PejVNWWZADRTVnZA0 = "YXNpZADpBWEg3UndTVDZAHRnpoNEQ4Vm1pejVNWWZADRTVnZA0"
    }
    
    enum Gender: String, Codable {
        case female = "female"
        case male = "male"
    }
    
    enum GenderText: String, Codable {
        case female = "Female"
        case male = "Male"
    }
    
    enum Google: String, Codable {
        case empty = ""
        case legitti = "Legitti"
    }
    
    enum Language: String, Codable {
        case english = "english"
        case russian = "russian"
        case turkish = "turkish"
    }
    
    enum Src: String, Codable {
        case empty = ""
        case facebook = "Facebook"
    }



}
class AddCommentModel{
    struct AddCommentSuccessModel: Codable {
        let apiStatus, apiVersion, successType, message: String?
        let id: Int?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case successType = "success_type"
            case message, id
        }
    }
  
    struct AddCommentErrorModel: Codable {
        let apiStatus, apiVersion: String?
        let errors: Errors
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case errors
        }
    }
    
    struct Errors: Codable {
        let errorID, errorText: String?
        
        enum CodingKeys: String, CodingKey {
            case errorID = "error_id"
            case errorText = "error_text"
        }
    }


}
class LikeCommentModel{
    struct LikeCommentSuccessModel: Codable {
        let apiStatus, apiVersion, successType: String?
        let liked: Int?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case successType = "success_type"
            case liked
        }
    }
    struct LikeCommentErrorModel: Codable {
        let apiStatus, apiVersion: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case errors
        }
    }
    
    struct Errors: Codable {
        let errorID, errorText: String?
        
        enum CodingKeys: String, CodingKey {
            case errorID = "error_id"
            case errorText = "error_text"
        }
    }

}
class DislikeCommentModel{
    struct DislikeCommentSuccessModel: Codable {
        let apiStatus, apiVersion, successType: String?
        let dislike: Int?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case successType = "success_type"
            case dislike
        }
    }
    struct DislikeCommentErrorModel: Codable {
        let apiStatus, apiVersion: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case errors
        }
    }
    
    struct Errors: Codable {
        let errorID, errorText: String?
        
        enum CodingKeys: String, CodingKey {
            case errorID = "error_id"
            case errorText = "error_text"
        }
    }

}


class RepliesModel{
    
    struct RepliesSuccessModel: Codable {
        let apiStatus, apiVersion, successType: String?
        let data: [Datum]?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case successType = "success_type"
            case data
        }
    }
    
    struct Datum: Codable {
        let id, userID, commentID, videoID: Int?
        let postID: Int?
        let text, time: String?
        let isReplyOwner: Bool?
        let replyUserData: ReplyUserData?
        let isLikedReply, isDislikedReply, replyLikes, replyDislikes: Int?
        let textTime: String?
        
        enum CodingKeys: String, CodingKey {
            case id
            case userID = "user_id"
            case commentID = "comment_id"
            case videoID = "video_id"
            case postID = "post_id"
            case text, time
            case isReplyOwner = "is_reply_owner"
            case replyUserData = "reply_user_data"
            case isLikedReply = "is_liked_reply"
            case isDislikedReply = "is_disliked_reply"
            case replyLikes = "reply_likes"
            case replyDislikes = "reply_dislikes"
            case textTime = "text_time"
        }
    }
    
    struct ReplyUserData: Codable {
        let id: Int?
        let username, email, ipAddress, firstName: String?
        let lastName, gender, emailCode, deviceID: String?
        let language: String?
        let avatar, cover: String?
        let src: String?
        let countryID, age: Int?
        let about, google, facebook, twitter: String?
        let instagram: String?
        let active, admin, verified, lastActive: Int?
        let registered: String?
        let isPro, imports, uploads: Int?
        let wallet, balance: String?
        let videoMon, ageChanged: Int?
        let donationPaypalEmail, userUploadLimit: String?
        let twoFactor: Int?
        let lastMonth, name: String?
        let url: String?
        let aboutDecoded, balanceOr, nameV, countryName: String?
        let genderText: String?
        
        enum CodingKeys: String, CodingKey {
            case id, username, email
            case ipAddress = "ip_address"
            case firstName = "first_name"
            case lastName = "last_name"
            case gender
            case emailCode = "email_code"
            case deviceID = "device_id"
            case language, avatar, cover, src
            case countryID = "country_id"
            case age, about, google, facebook, twitter, instagram, active, admin, verified
            case lastActive = "last_active"
            case registered
            case isPro = "is_pro"
            case imports, uploads, wallet, balance
            case videoMon = "video_mon"
            case ageChanged = "age_changed"
            case donationPaypalEmail = "donation_paypal_email"
            case userUploadLimit = "user_upload_limit"
            case twoFactor = "two_factor"
            case lastMonth = "last_month"
            case name, url
            case aboutDecoded = "about_decoded"
            case balanceOr = "balance_or"
            case nameV = "name_v"
            case countryName = "country_name"
            case genderText = "gender_text"
        }
    }
    
    struct RepliesErrorModel: Codable {
        let apiStatus, apiVersion: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case errors
        }
    }
    
    struct Errors: Codable {
        let errorID, errorText: String?
        
        enum CodingKeys: String, CodingKey {
            case errorID = "error_id"
            case errorText = "error_text"
        }
    }

}


class CommentReplyModel{
    struct CommentReplySuccessModel: Codable {
        let apiStatus, apiVersion, successType, message: String?
        let replyID: Int
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case successType = "success_type"
            case message
            case replyID = "reply_id"
        }
    }
    struct CommentReplyErrorModel: Codable {
        let apiStatus, apiVersion: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case errors
        }
    }
    
    struct Errors: Codable {
        let errorID, errorText: String?
        
        enum CodingKeys: String, CodingKey {
            case errorID = "error_id"
            case errorText = "error_text"
        }
    }

}
