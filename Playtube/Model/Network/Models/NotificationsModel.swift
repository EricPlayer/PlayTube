//
//  NotificationsModel.swift
//  Playtube
//


import Foundation
class NotificationsModel{
    
//    struct NotificationsSuccessModel: Codable {
//        let apiStatus, apiVersion: String?
//        let notifications: [Notification]?
//
//        enum CodingKeys: String, CodingKey {
//            case apiStatus = "api_status"
//            case apiVersion = "api_version"
//            case notifications
//        }
//    }
//
    struct NotificationsErrorModel: Codable {
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
    struct NotificationsSuccessModel: Codable {
        let apiStatus, apiVersion: String?
        let notifications: [Notification]?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case notifications
        }
    }
    
    struct Notification: Codable {
        let id: Int?
        let userData: UserData?
        let video: VIDEOUnion?
        let title: String?
        let url: String?
        let time, icon: String?
        
        enum CodingKeys: String, CodingKey {
            case id = "ID"
            case userData = "USER_DATA"
            case video = "VIDEO"
            case title = "TITLE"
            case url = "URL"
            case time = "TIME"
            case icon = "ICON"
        }
    }
    
    struct UserData: Codable {
        let id: Int?
        let username, email, ipAddress, firstName: String?
        let lastName, gender, emailCode, deviceID: String?
        let language: String?
        let avatar: String?
        let cover: String?
        let src: String?
        let countryID, age: Int?
        let about: String?
        let google, facebook: String?
        let twitter, instagram: String?
        let active, admin, verified, lastActive: Int?
        let registered: String?
        let isPro, imports, uploads: Int?
        let wallet, balance: String?
        let videoMon, ageChanged: Int?
        let donationPaypalEmail, userUploadLimit: String?
        let twoFactor: Int?
        let lastMonth: String?
        let activeTime: Int?
        let activeExpire, name: String?
        let url: String?
        let aboutDecoded, balanceOr, nameV, countryName: String?
        let genderText: String?
        let isSubscribedToChannel: Int?
        let password: String?
        
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
            case activeTime = "active_time"
            case activeExpire = "active_expire"
            case name, url
            case aboutDecoded = "about_decoded"
            case balanceOr = "balance_or"
            case nameV = "name_v"
            case countryName = "country_name"
            case genderText = "gender_text"
            case isSubscribedToChannel = "is_subscribed_to_channel"
            case password
        }
    }
    
    enum VIDEOUnion: Codable {
        
        case string(String)
        case videoClass(VIDEOClass)
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let x = try? container.decode(String.self) {
                self = .string(x)
                return
            }
            if let x = try? container.decode(VIDEOClass.self) {
                self = .videoClass(x)
                return
            }
            throw DecodingError.typeMismatch(VIDEOUnion.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for VIDEOUnion"))
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .string(let x):
                try container.encode(x)
            case .videoClass(let x):
                try container.encode(x)
            }
        }
    }
    
    struct VIDEOClass: Codable {
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
        let tags: JSONNull?
        let duration: String?
        let size, converted: Int?
        let categoryID: String?
        let views, featured: Int?
        let registered: String?
        let privacy, ageRestriction: Int?
        let type: String?
        let approved, the240P, the360P, the480P: Int?
        let the720P, the1080P, the2048P, the4096P: Int?
        let sellVideo, subCategory, geoBlocking, demo: String?
        let isMovie: Int?
        let stars, producer, country, movieRelease: String?
        let quality, rating: String?
        let rentPrice: Int?
        let orgThumbnail, videoVideoID, source, videoType: String?
        let url: String?
        let editDescription, markupDescription: String?
        let owner: UserData?
        let isLiked, isDisliked: Int?
        let isOwner: Bool?
        let timeAlpha, timeAgo, categoryName: String?
        let likes, dislikes, likesPercent, dislikesPercent: Int?
        
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
            case demo
            case isMovie = "is_movie"
            case stars, producer, country
            case movieRelease = "movie_release"
            case quality, rating
            case rentPrice = "rent_price"
            case orgThumbnail = "org_thumbnail"
            case videoVideoID = "video_id_"
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
            case likes, dislikes
            case likesPercent = "likes_percent"
            case dislikesPercent = "dislikes_percent"
        }
    }
    
    // MARK: Encode/decode helpers
    
    class JSONNull: Codable, Hashable {
        
        public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
            return true
        }
        
        public var hashValue: Int {
            return 0
        }
        
        public init() {}
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if !container.decodeNil() {
                throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encodeNil()
        }
    }

//    struct Notification: Codable {
//        let id: Int?
//        let userData: UserData?
//        let video, title: String?
//        let url: String?
//        let time, icon: String?
//
//        enum CodingKeys: String, CodingKey {
//            case id = "ID"
//            case userData = "USER_DATA"
//            case video = "VIDEO"
//            case title = "TITLE"
//            case url = "URL"
//            case time = "TIME"
//            case icon = "ICON"
//        }
//    }
    
//    struct UserData: Codable {
//        let id: Int?
//        let username, email, ipAddress, firstName: String?
//        let lastName, gender, emailCode, deviceID: String?
//        let language: String?
//        let avatar: String?
//        let cover: String?
//        let src: String?
//        let countryID, age: Int?
//        let about, google, facebook, twitter: String?
//        let instagram: String?
//        let active, admin, verified, lastActive: Int?
//        let registered: String?
//        let isPro, imports, uploads: Int?
//        let wallet, balance: String?
//        let videoMon, ageChanged: Int?
//        let donationPaypalEmail, userUploadLimit: String?
//        let twoFactor: Int?
//        let lastMonth: String?
//        let name: String?
//        let url: String?
//        let aboutDecoded, balanceOr, nameV, countryName: String?
//        let genderText: String?
//        let isSubscribedToChannel: Int?
//
//        enum CodingKeys: String, CodingKey {
//            case id, username, email
//            case ipAddress = "ip_address"
//            case firstName = "first_name"
//            case lastName = "last_name"
//            case gender
//            case emailCode = "email_code"
//            case deviceID = "device_id"
//            case language, avatar, cover, src
//            case countryID = "country_id"
//            case age, about, google, facebook, twitter, instagram, active, admin, verified
//            case lastActive = "last_active"
//            case registered
//            case isPro = "is_pro"
//            case imports, uploads, wallet, balance
//            case videoMon = "video_mon"
//            case ageChanged = "age_changed"
//            case donationPaypalEmail = "donation_paypal_email"
//            case userUploadLimit = "user_upload_limit"
//            case twoFactor = "two_factor"
//            case lastMonth = "last_month"
//            case name, url
//            case aboutDecoded = "about_decoded"
//            case balanceOr = "balance_or"
//            case nameV = "name_v"
//            case countryName = "country_name"
//            case genderText = "gender_text"
//            case isSubscribedToChannel = "is_subscribed_to_channel"
//        }
//    }
}
