//
//  UserDefaultModel.swift
//  Playtube


import Foundation
class UserDefaultModel{
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
        let avatar, cover: String?
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

//struct Datum: Codable {
//    let id: Int?
//    let videoID: String?
//    let userID: Int?
//    let shortID, title, description: String?
//    let thumbnail: String?
//    let videoLocation: String?
//    let youtube, vimeo, daily, facebook: String?
//    let twitch, twitchType: String?
//    let time: Int?
//    let timeDate: String?
//    let active: Int?
//    let tags, duration: String?
//    let size, converted: Int?
//    let categoryID: String?
//    let views, featured: Int?
//    let registered: String?
//    let privacy, ageRestriction: Int?
//    let type: String?
//    let approved, the240P, the360P, the480P: Int?
//    let the720P, the1080P, the2048P, the4096P: Int?
//    let sellVideo: String?
//    let subCategory, geoBlocking: String?
//    let orgThumbnail: String?
//    let datumVideoID, videoType, source: String?
//    let url: String?
//    let editDescription, markupDescription: String?
//    let owner: Owner?
//    let isLiked, isDisliked: Int?
//    let isOwner: Bool?
//    let timeAlpha, timeAgo, categoryName: String?
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case videoID = "video_id"
//        case userID = "user_id"
//        case shortID = "short_id"
//        case title, description, thumbnail
//        case videoLocation = "video_location"
//        case youtube, vimeo, daily, facebook, twitch
//        case twitchType = "twitch_type"
//        case time
//        case timeDate = "time_date"
//        case active, tags, duration, size, converted
//        case categoryID = "category_id"
//        case views, featured, registered, privacy
//        case ageRestriction = "age_restriction"
//        case type, approved
//        case the240P = "240p"
//        case the360P = "360p"
//        case the480P = "480p"
//        case the720P = "720p"
//        case the1080P = "1080p"
//        case the2048P = "2048p"
//        case the4096P = "4096p"
//        case sellVideo = "sell_video"
//        case subCategory = "sub_category"
//        case geoBlocking = "geo_blocking"
//        case orgThumbnail = "org_thumbnail"
//        case datumVideoID = "video_id_"
//        case videoType = "video_type"
//        case source, url
//        case editDescription = "edit_description"
//        case markupDescription = "markup_description"
//        case owner
//        case isLiked = "is_liked"
//        case isDisliked = "is_disliked"
//        case isOwner = "is_owner"
//        case timeAlpha = "time_alpha"
//        case timeAgo = "time_ago"
//        case categoryName = "category_name"
//    }
//}
//
//struct Owner: Codable {
//    let id: Int?
//    let username, email, firstName, lastName: String?
//    let gender, language: String?
//    let avatar, cover: String?
//    let about, google, facebook, twitter: String?
//    let verified, isPro: Int?
//    let url: String?
//
//    enum CodingKeys: String, CodingKey {
//        case id, username, email
//        case firstName = "first_name"
//        case lastName = "last_name"
//        case gender, language, avatar, cover, about, google, facebook, twitter, verified
//        case isPro = "is_pro"
//        case url
//    }
//}
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
    let sellVideo, subCategory, geoBlocking, demo: String?
    let isMovie: Int?
    let stars, producer, country, movieRelease: String?
    let quality, rating: String?
    let rentPrice: Int?
    let orgThumbnail: String?
    let videosVideoID, videoType, source: String?
    let url: String?
    let editDescription, markupDescription: String?
    let owner: Owner?
    let isLiked, isDisliked: Int?
    let isOwner: Bool?
    let timeAlpha, timeAgo, categoryName: String?
    let playlistLink: String?
    
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
        case videosVideoID = "video_id_"
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
        case playlistLink = "playlist_link"
    }
}

struct Owner: Codable {
    let id: Int?
    let username, email, ipAddress, password: String?
    let firstName, lastName, gender, emailCode: String?
    let deviceID, language: String?
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
    
    enum CodingKeys: String, CodingKey {
        case id, username, email
        case ipAddress = "ip_address"
        case password
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
    }
}
