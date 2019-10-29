//
//  ForgotPasswordModel.swift
//  Playtube


import Foundation

class ForgotPasswordModel{
    struct ForgotPasswordSuccessModel: Codable {
        let apiStatus, apiVersion: String?
        let data: DataClass?
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case data
        }
    }
    
    struct DataClass: Codable {
        let email, message: String?
    }
    
    struct ForgotPasswordErrorModel: Codable {
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

