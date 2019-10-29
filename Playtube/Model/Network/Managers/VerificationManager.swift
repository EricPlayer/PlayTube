//
//  VerificationManager.swift
//  Playtube
//
//  Created by Macbook Pro on 06/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import Foundation
import Alamofire
import PlaytubeSDK


class VerificationManager:NSObject {
    
    static let instance = VerificationManager()
    
    func VerificationUser(User_id:Int,Session_Token:String,FirstName:String,LastName:String,Identity:Data,Message:String,completionBlock: @escaping (_ Success:VerificationModel.VerificationSuccessModel?,_ SessionError:VerificationModel.VerificationErrorModel?, Error?) ->()){
        let params = [
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key,
            API.Params.Message_Id : Message,
            API.Params.FirstName : FirstName,
            API.Params.LastName : LastName,
//            API.Params.Indentity_Id : ImageURL
            ] as [String : Any]
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        print("Decoded String",params)
        SRWebClient.POST(API.Verification_Methods.VERIFICATION_API).data(Identity, fieldName: "identity", data: params).send({ (response, status) in
            log.verbose("reposne - \(response)")
            guard let res = response as? [String:Any] else{return}
            guard let apiStatus = res["api_status"] as? String else{return}
            log.verbose("res = \(apiStatus)")
            if apiStatus == "200"{
                let data = try! JSONSerialization.data(withJSONObject: response!, options: [])
                let result = try! JSONDecoder().decode(VerificationModel.VerificationSuccessModel.self, from: data)
                //                    log.verbose("Response = \(response.result.value)")
                print("Response = \(result)")
                completionBlock(result,nil,nil)
                
            }else if apiStatus == "400"{
                let data = try! JSONSerialization.data(withJSONObject: response, options: [])
                let result = try! JSONDecoder().decode(VerificationModel.VerificationErrorModel.self, from: data)
                //                    log.verbose("Response = \(response.result.value)")
                print("Response = \(result)")
                completionBlock(nil,result,nil)
                
            }
        }) { (error) in
            log.verbose("error = \(error?.localizedDescription)")
            completionBlock(nil,nil,error)
        }


        
    }
}
