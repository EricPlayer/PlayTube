//
//  MonetizationModel.swift
//  Playtube
//
//  Created by Macbook Pro on 08/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
class MonetizationModel{
    struct MonetizationSuccessModel: Codable {
        let apiStatus, apiVersion, successType, message: String
        
        enum CodingKeys: String, CodingKey {
            case apiStatus = "api_status"
            case apiVersion = "api_version"
            case successType = "success_type"
            case message
        }
    }
    struct MonetizationErrorModel: Codable {
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
