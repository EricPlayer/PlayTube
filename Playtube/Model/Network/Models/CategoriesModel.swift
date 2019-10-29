//
//  CategoriesModel.swift
//  Playtube
//


import Foundation

class GetSettings{
    struct GetSettingsSuccessModel: Codable {
        let apiStatus, apiVersion: String?
        let data: DataClass?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case data
        }
    }
    
    struct DataClass: Codable {
        let siteSettings: SiteSettings?
        let categories: Categories?
        enum CodingKeys: String, CodingKey {
            case siteSettings = "site_settings"
            case categories
        }
    }
    
    struct Categories: Codable {
        let category1, category3, category4, category5: String?
        let category6, category7, category8, category9: String?
        let category10, category11, category12, category13: String?
        let other: String?
        
        enum CodingKeys: String, CodingKey {
            case category1 = "category__1"
            case category3 = "category__3"
            case category4 = "category__4"
            case category5 = "category__5"
            case category6 = "category__6"
            case category7 = "category__7"
            case category8 = "category__8"
            case category9 = "category__9"
            case category10 = "category__10"
            case category11 = "category__11"
            case category12 = "category__12"
            case category13 = "category__13"
            case other
        }
    }
    
    struct SiteSettings: Codable {
        let theme, censoredWords, title, name: String?
        let keyword, email, description, validation: String?
        let recaptcha, language, seoLink, commentSystem: String?
        let deleteAccount, totalVideos, totalViews, totalUsers: String?
        let totalSubs, totalComments, totalLikes, totalDislikes: String?
        let totalSaved, uploadSystem, importSystem, autoplaySystem: String?
        let historySystem, userRegistration, verificationBadge, commentsDefaultNum: String?
        let fbLogin, twLogin, plusLogin, goPro: String?
        let userAds, maxUpload: String?
        let themeURL, siteURL: String?
        let scriptVersion: String?
        
        enum CodingKeys: String, CodingKey {
            case theme
            case censoredWords = "censored_words"
            case title, name, keyword, email, description, validation, recaptcha, language
            case seoLink = "seo_link"
            case commentSystem = "comment_system"
            case deleteAccount = "delete_account"
            case totalVideos = "total_videos"
            case totalViews = "total_views"
            case totalUsers = "total_users"
            case totalSubs = "total_subs"
            case totalComments = "total_comments"
            case totalLikes = "total_likes"
            case totalDislikes = "total_dislikes"
            case totalSaved = "total_saved"
            case uploadSystem = "upload_system"
            case importSystem = "import_system"
            case autoplaySystem = "autoplay_system"
            case historySystem = "history_system"
            case userRegistration = "user_registration"
            case verificationBadge = "verification_badge"
            case commentsDefaultNum = "comments_default_num"
            case fbLogin = "fb_login"
            case twLogin = "tw_login"
            case plusLogin = "plus_login"
            case goPro = "go_pro"
            case userAds = "user_ads"
            case maxUpload = "max_upload"
            case themeURL = "theme_url"
            case siteURL = "site_url"
            case scriptVersion = "script_version"
        }
    }
    struct GetSettingsErrorModel: Codable {
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
