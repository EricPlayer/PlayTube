//
//  RegisterModel.swift
//  Playtube


import Foundation
class RegisterModel{
  
    struct RegisterSuccessModel: Codable {
        let apiStatus, apiVersion: String?
        let data: DataClass?
        let message, successType: String?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case data, message
            case successType = "success_type"
        }
    }
    
    struct DataClass: Codable {
        let cookie, s: String?
        let userID: Int?
        
        enum CodingKeys: String, CodingKey {
            case cookie, s
            case userID = "user_id"
        }
    }

    
    struct RegisterEmailSuccessModel: Codable {
        let apiStatus: Int?
        let apiVersion, message, successType: String?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case message
            case successType = "success_type"
        }
    }

    
    
    struct RegisterErrorModel: Codable {
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


