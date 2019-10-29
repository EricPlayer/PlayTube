//
//  SearchManager.swift
//  Playtube


import Foundation
import Alamofire
import PlaytubeSDK
class SearchManager:NSObject {
    
    static let instance = SearchManager()
    
    func searchVideo(User_id: Int, Session_Token: String,SearchText:String, completionBlock: @escaping (_ Success:SearchModel.SearchSuccessModel?,_ SessionError:SearchModel.SearchErrorModel?, Error?) ->()){
        let params = [
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key
            ] as [String : Any]
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        print("Decoded String",params)
        Alamofire.request(API.SEARCH_VIDEOS_Methods.SEARCH_VIDEOS_API + "\(SearchText)", method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            if (response.result.value != nil){
                guard let Res = response.result.value as? [String:Any] else {return}
                guard let api_status = Res["api_status"]  as? String else {return}
                if api_status == "200"{
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    let result = try! JSONDecoder().decode(SearchModel.SearchSuccessModel.self, from: data)
                    //                    log.verbose("Response = \(response.result.value)")
                    print("Response = \(result)")
                    completionBlock(result,nil,nil)
                }else if api_status == "400" {
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    let result = try! JSONDecoder().decode(SearchModel.SearchErrorModel.self, from: data)
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
