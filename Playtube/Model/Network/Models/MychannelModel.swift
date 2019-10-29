//
//  MychannelModel.swift
//  Playtube

import Foundation

class MychannelModel{
    class ChangePasswordModel {
      
        struct ChangePassordSuccessModel: Codable {
            let apiStatus, apiVersion, message: String?
            
            enum CodingKeys: String, CodingKey {
                case apiStatus = "api_status"
                case apiVersion = "api_version"
                case message
            }
        }

       
        struct ChangePassordErrorModel: Codable {
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
    
    class UpdateMyChannelModel{
        
        struct UpdateChannelSuccessModel: Codable {
            let apiStatus, apiVersion, message: String?
            
            enum CodingKeys: String, CodingKey {
                case apiStatus = "api_status"
                case apiVersion = "api_version"
                case message
            }
        }

        struct UpdateChannelErrorModel: Codable {
            let apiStatus, apiVersion: String?
            let errors: Errors?
            let status: Int?
            
            enum CodingKeys: String, CodingKey {
                case apiStatus = "api_status"
                case apiVersion = "api_version"
                case errors, status
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
    class GetChannelInfoModel{
        
        struct GetChannelInfoSuccessModel: Codable {
            let apiStatus, apiVersion: String?
            let data: DataClass?
            
            enum CodingKeys: String, CodingKey {
                case apiStatus = "api_status"
                case apiVersion = "api_version"
                case data
            }
        }
        
        struct DataClass: Codable {
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
            let lastMonth: String?
            let name: String?
            let url: String?
            let aboutDecoded, balanceOr, nameV, countryName: String?
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
        struct GetChannelInfoErrorModel: Codable {
            let apiStatus: String?
            let errors: Errors?
            
            enum CodingKeys: String, CodingKey {
                case apiStatus = "api_status"
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
    class ChannelVideos{
        struct ChannelVideosSUccessModel: Codable {
            let apiStatus, apiVersion: String?
            let data: [Datum]?
            enum CodingKeys: String, CodingKey {
                case apiStatus = "api_status"
                case apiVersion = "api_version"
                case data
            }
            
        }
            struct ChannelVideosErrorModel: Codable {
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
            let id: Int?
            let videoID: String?
            let userID: Int?
            let shortID, title, description: String?
            let thumbnail: String?
            let videoLocation: String?
            let youtube, vimeo, daily, facebook: String?
            let twitch, twitchType: String?
            let time: Int?
            let timeDate: String?
            let active: Int?
            let tags, duration: String?
            let size, converted: Int?
            let categoryID: String?
            let views, featured: Int?
            let registered: String?
            let privacy, ageRestriction: Int?
            let type: String?
            let approved, the240P, the360P, the480P: Int?
            let the720P, the1080P, the2048P, the4096P: Int?
            let sellVideo: String?
            let subCategory, geoBlocking: String?
            let orgThumbnail: String?
            let datumVideoID, videoType, source: String?
            let url: String?
            let editDescription, markupDescription: String?
            let owner: Owner?
            let isLiked, isDisliked: Int?
            let isOwner: Bool?
            let timeAlpha, timeAgo, categoryName: String?
            
            enum CodingKeys: String, CodingKey {
                case id
                case videoID = "video_id"
                case userID = "user_id"
                case shortID = "short_id"
                case title, description, thumbnail
                case videoLocation = "video_location"
                case youtube, vimeo, daily, facebook, twitch
                case twitchType = "twitch_type"
                case time
                case timeDate = "time_date"
                case active, tags, duration, size, converted
                case categoryID = "category_id"
                case views, featured, registered, privacy
                case ageRestriction = "age_restriction"
                case type, approved
                case the240P = "240p"
                case the360P = "360p"
                case the480P = "480p"
                case the720P = "720p"
                case the1080P = "1080p"
                case the2048P = "2048p"
                case the4096P = "4096p"
                case sellVideo = "sell_video"
                case subCategory = "sub_category"
                case geoBlocking = "geo_blocking"
                case orgThumbnail = "org_thumbnail"
                case datumVideoID = "video_id_"
                case videoType = "video_type"
                case source, url
                case editDescription = "edit_description"
                case markupDescription = "markup_description"
                case owner
                case isLiked = "is_liked"
                case isDisliked = "is_disliked"
                case isOwner = "is_owner"
                case timeAlpha = "time_alpha"
                case timeAgo = "time_ago"
                case categoryName = "category_name"
            }
        }
        
        struct Owner: Codable {
            let id: Int?
            let username, email, firstName, lastName: String?
            let gender, language: String?
            let avatar: String?
            let cover: String?
            let about, google, facebook, twitter: String?
            let verified, isPro: Int?
            let url: String?
            
            enum CodingKeys: String, CodingKey {
                case id, username, email
                case firstName = "first_name"
                case lastName = "last_name"
                case gender, language, avatar, cover, about, google, facebook, twitter, verified
                case isPro = "is_pro"
                case url
            }
        }
            
            
        }

    
}

class DeleteHistoryModel{
    
    
    struct DeleteHistorySuccessModel: Codable {
        let apiStatus, apiVersion, successType, message: String
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case successType = "success_type"
            case message
        }
    }
    struct DeleteHistoryErrorModel: Codable {
        let apiStatus, apiVersion: String
        let errors: Errors
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case errors
        }
    }
    
    struct Errors: Codable {
        let errorID, errorText: String
        
        enum CodingKeys: String, CodingKey {
            case errorID = "error_id"
            case errorText = "error_text"
        }
    }

}
