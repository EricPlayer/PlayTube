//
//  MonetizationManager.swift
//  Playtube
//
//  Created by Macbook Pro on 08/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//
import Foundation
import Alamofire
import PlaytubeSDK
class MonetizationManager:NSObject {
    
    static let instance = MonetizationManager()
    
    func monetizeUser(User_id:Int,Session_Token:String,Email:String,Ammount:Int,completionBlock: @escaping (_ Success:MonetizationModel.MonetizationSuccessModel?,_ SessionError:MonetizationModel.MonetizationErrorModel?, Error?) ->()){
        let params = [
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key,
            API.Params.Amount_Id : Ammount,
             API.Params.Email : Email
           
            ] as [String : Any]
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        print("Decoded String",params)
        Alamofire.request(API.Monetization_Methods.MONETIZATION_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            log.verbose("URL = \(API.Monetization_Methods.MONETIZATION_API + Session_Token)")
            if (response.result.value != nil){
                log.verbose("URL = \(API.Monetization_Methods.MONETIZATION_API + Session_Token)")
                guard let Res = response.result.value as? [String:Any] else {return}
                guard let api_status = Res["api_status"]  as? String else {return}
                if api_status == "200"{
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    let result = try! JSONDecoder().decode(MonetizationModel.MonetizationSuccessModel.self, from: data)
                    //                    log.verbose("Response = \(response.result.value)")
                    print("Response = \(result)")
                    completionBlock(result,nil,nil)
                }else if api_status == "400"{
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    let result = try! JSONDecoder().decode(MonetizationModel.MonetizationErrorModel.self, from: data)
                    //                    log.verbose("Response = \(response.result.value)")
                    print("Response = \(result)")
                    completionBlock(nil,result,nil)
                }
            }else{
                completionBlock(nil,nil,response.error)
            }
        }
        
    }
}
