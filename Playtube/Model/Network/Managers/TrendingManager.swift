//
//  TrendingManager.swift
//  Playtube


import Foundation
import Alamofire
import PlaytubeSDK
class TrendingManager:NSObject {
    
    static let instance = TrendingManager()
    
    func getTrendingData(User_id:Int,Session_Token:String,completionBlock: @escaping (_ Success:TrendingModel.TrendingSuccessModel?,_ SessionError:TrendingModel.TrendingErrorModel?, Error?) ->()){
        let params = [
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key
            ] as [String : Any]
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        print("Decoded String",params)
        Alamofire.request(API.Trending_Methods.TRENDING_VIDEOS_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            log.verbose("URL = \(API.Trending_Methods.TRENDING_VIDEOS_API + Session_Token)")
            if (response.result.value != nil){
                log.verbose("URL = \(API.Trending_Methods.TRENDING_VIDEOS_API + Session_Token)")
                guard let Res = response.result.value as? [String:Any] else {return}
                guard let api_status = Res["api_status"]  as? String else {return}
                if api_status == "200"{
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    let result = try! JSONDecoder().decode(TrendingModel.TrendingSuccessModel.self, from: data)
                    //                    log.verbose("Response = \(response.result.value)")
                    print("Response = \(result)")
                    completionBlock(result,nil,nil)
                }else if api_status == "400"{
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    let result = try! JSONDecoder().decode(TrendingModel.TrendingErrorModel.self, from: data)
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
