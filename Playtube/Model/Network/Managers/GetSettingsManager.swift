//
//  CategoriesManager.swift
//  Playtube


import Foundation
import Alamofire
import PlaytubeSDK
class GetSettingsManager:NSObject {
    
    static let instance = GetSettingsManager()
    
    func getSetting(completionBlock: @escaping (_ categories:[String:String]?,_ siteSetting:[String:String]?,_ SessionError:GetSettings.GetSettingsErrorModel?, Error?) ->()){
        let params = [
            API.Params.ServerKey : API.SERVER_KEY.Server_Key
            ] as [String : Any]
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        print("Decoded String",params)
        Alamofire.request(API.PLAYLIST_Methods.CATEGORIES_METHODS.GET_CATEGORIES_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            log.verbose("URL = \(API.PLAYLIST_Methods.CATEGORIES_METHODS.GET_CATEGORIES_API)")
            if (response.result.value != nil){
                guard let Res = response.result.value as? [String:Any] else {return}
                guard let api_status = Res["api_status"]  as? String else {return}
                if api_status == "200"{
                    guard let allValues = response.result.value as? [String:Any] else{return}
//                    log.verbose("allValues = \(allValues)")
                    guard let data = allValues["data"] as? [String:Any] else {return}
                    guard let categories = data["categories"] as? [String:String] else {return}
//                    log.verbose("data = \(data)")
                    guard let siteSettings = data["site_settings"] as? [String:String] else{return}
//                    
                    completionBlock(categories,siteSettings,nil,nil)
                }else if api_status == "400" {
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    let result = try! JSONDecoder().decode(GetSettings.GetSettingsErrorModel.self, from: data)
                    //                    log.verbose("Response = \(response.result.value)")
                    print("Response = \(result)")
                    completionBlock(nil,nil,result,nil)
           
                }
            }else{
                completionBlock(nil,nil,nil,response.error)
            }
        }
        
    }
    
    
}
