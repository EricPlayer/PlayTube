//
//  UserModel.swift
//  Playtube


import Foundation

class LoginModel{
    struct UserErrorModel: Codable {
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
    struct UserSuccessModel: Codable {
        let apiStatus, apiVersion: String?
        let data: DataClass?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case data
        }
    }
    
    struct DataClass: Codable {
        let sessionID, message: String?
        let userID: Int?
        let cookie: String?
        
        enum CodingKeys: String, CodingKey {
            case sessionID = "session_id"
            case message
            case userID = "user_id"
            case cookie
        }
    }
}
