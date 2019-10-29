//
//  Home.swift
//  Playtube


import Foundation
class Home {
    struct HomeModel: Codable {
        let apiStatus, apiVersion: String?
        let data: DataClass?
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case data
        }
    }
    struct HomeModel_Error: Codable {
        let apiStatus, apiText: String?
        let errors: Errors?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiText = "api_text"
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
    struct DataClass: Codable {
        let featured, top, latest: [Featured]?
    }
    
    struct Featured: Codable {
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
        let featuredVideoID: String?
        let source: String?
        let videoType: String?
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
            case featuredVideoID = "video_id_"
            case source
            case videoType = "video_type"
            case url
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
        let username, email: String?
        let firstName: String?
        let lastName: String?
        let gender: String?
        let language: String?
        let avatar: String?
        let cover: String?
        let about: String?
        let google, facebook: String?
        let twitter: String?
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
    
    enum About: String, Codable {
        case empty = ""
        case hiIAmDeenILoveCoding = "Hi, I am Deen, I love coding!"
    }
    
    enum FirstName: String, Codable {
        case argenis = "Argenis"
        case deen = "Deen"
        case empty = ""
        case sergey = "Sergey"
    }
    
    enum Gender: String, Codable {
        case male = "male"
    }
    
    enum Language: String, Codable {
        case english = "english"
        case russian = "russian"
        case spanish = "spanish"
    }
    
    enum LastName: String, Codable {
        case deyneko = "Deyneko"
        case doughouz = "Doughouz"
        case empty = ""
        case vazquez = "Vazquez"
    }
    
    enum Source: String, Codable {
        case uploaded = "Uploaded"
        case youTube = "YouTube"
    }
    
    enum VideoType: String, Codable {
        case videoMp4 = "video/mp4"
        case videoYoutube = "video/youtube"
    }

   
}



//





