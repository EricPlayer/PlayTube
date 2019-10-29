//
//  MychannelManager.swift
//  Playtube



import Foundation
import Alamofire
import PlaytubeSDK
class MyChannelManager:NSObject {
    
    static let instance = MyChannelManager()
    
    func changePassword(User_id: Int, Session_Token: String,CurrentPassword:String,NewPassword:String,RepeatPassword:String, completionBlock: @escaping (_ Success:MychannelModel.ChangePasswordModel.ChangePassordSuccessModel?,_ SessionError:MychannelModel.ChangePasswordModel.ChangePassordErrorModel?, Error?) ->()){
        let params = [
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.CurrentPassword : CurrentPassword,
            API.Params.NewPassword : NewPassword,
            API.Params.RepeatPassword : RepeatPassword,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key
            ] as [String : Any]
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        print("Decoded String",params)
        Alamofire.request(API.MY_CHANNEL_Methods.CHANGE_PASSWORD_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            if (response.result.value != nil){
                guard let Res = response.result.value as? [String:Any] else {return}
                guard let api_status = Res["api_status"]  as? String else {return}
                if api_status == "200"{
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    let result = try! JSONDecoder().decode(MychannelModel.ChangePasswordModel.ChangePassordSuccessModel.self, from: data)
                    //                    log.verbose("Response = \(response.result.value)")
                    print("Response = \(result)")
                    completionBlock(result,nil,nil)
                }else if api_status == "400" {
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    let result = try! JSONDecoder().decode(MychannelModel.ChangePasswordModel.ChangePassordErrorModel.self, from: data)
                    //                    log.verbose("Response = \(response.result.value)")
                    print("Response = \(result)")
                    completionBlock(nil,result,nil)
                }
            }else{
                completionBlock(nil,nil,response.error)
            }
        }
        
    }
    
    
    func editMyChannel(User_id: Int, Session_Token: String,Username:String,FirstName:String,LastName:String,Email:String,About:String,Gender:String, completionBlock: @escaping (_ Success:MychannelModel.UpdateMyChannelModel.UpdateChannelSuccessModel?,_ SessionError:MychannelModel.UpdateMyChannelModel.UpdateChannelErrorModel?, Error?) ->()){
        let params = [
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.Username : Username,
            API.Params.Email : Email,
            API.Params.FirstName : FirstName,
            API.Params.LastName : LastName,
            API.Params.About : About,
            API.Params.Gender : Gender,
            API.Params.SettingsType : API.SETTINGS_TYPE.SettingType_General,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key
            ] as [String : Any]
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        print("Decoded String",params)
        Alamofire.request(API.MY_CHANNEL_Methods.UPDATE_MY_CHANNEL_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            if (response.result.value != nil){
                guard let Res = response.result.value as? [String:Any] else {return}
                guard let api_status = Res["api_status"]  as? String else {return}
                if api_status == "200"{
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    let result = try! JSONDecoder().decode(MychannelModel.UpdateMyChannelModel.UpdateChannelSuccessModel.self, from: data)
                    //                    log.verbose("Response = \(response.result.value)")
                    print("Response = \(result)")
                    completionBlock(result,nil,nil)
                }else if api_status == "400" {
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    let result = try! JSONDecoder().decode(MychannelModel.UpdateMyChannelModel.UpdateChannelErrorModel.self, from: data)
                    //                    log.verbose("Response = \(response.result.value)")
                    print("Response = \(result)")
                    completionBlock(nil,result,nil)
                }
            }else{
                completionBlock(nil,nil,response.error)
            }
        }

    }
    
    func getChannelInfo(User_id: Int,Session_Token:String,Channel_id:Int, completionBlock: @escaping (_ Success:MychannelModel.GetChannelInfoModel.GetChannelInfoSuccessModel?,_ SessionError:MychannelModel.GetChannelInfoModel.GetChannelInfoErrorModel?, Error?) ->()){
        let params = [
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key
            ] as [String : Any]
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        print("Decoded String",params)
        Alamofire.request(API.MY_CHANNEL_Methods.GET_CHANNEL_INFO_API + "\(Channel_id)", method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            if (response.result.value != nil){
                guard let Res = response.result.value as? [String:Any] else {return}
                guard let api_status = Res["api_status"]  as? String else {return}
                if api_status == "200"{
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    let result = try! JSONDecoder().decode(MychannelModel.GetChannelInfoModel.GetChannelInfoSuccessModel.self, from: data)
                    //                    log.verbose("Response = \(response.result.value)")
                    print("Response = \(result)")
                    completionBlock(result,nil,nil)
                }else if api_status == "400" {
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    let result = try! JSONDecoder().decode(MychannelModel.GetChannelInfoModel.GetChannelInfoErrorModel.self, from: data)
                    //                    log.verbose("Response = \(response.result.value)")
                    print("Response = \(result)")
                    completionBlock(nil,result,nil)
                }
            }else{
                completionBlock(nil,nil,response.error)
            }
        }
        
    }
    
    func clearWatchHistory(User_id: Int, Session_Token: String, completionBlock: @escaping (_ Success:DeleteHistoryModel
        .DeleteHistorySuccessModel?,_ SessionError:DeleteHistoryModel.DeleteHistoryErrorModel?, Error?) ->()){
        let params = [
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key
            ] as [String : Any]
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        print("Decoded String",params)
        Alamofire.request(API.MY_CHANNEL_Methods.CLEAR_WATCH_HISTORY_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            if (response.result.value != nil){
                guard let Res = response.result.value as? [String:Any] else {return}
                guard let api_status = Res["api_status"]  as? String else {return}
                if api_status == "200"{
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    let result = try! JSONDecoder().decode(DeleteHistoryModel.DeleteHistorySuccessModel.self, from: data)
                    //                    log.verbose("Response = \(response.result.value)")
                    print("Response = \(result)")
                    completionBlock(result,nil,nil)
                }else if api_status == "400" {
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    let result = try! JSONDecoder().decode(DeleteHistoryModel.DeleteHistoryErrorModel.self, from: data)
                    //                    log.verbose("Response = \(response.result.value)")
                    print("Response = \(result)")
                    completionBlock(nil,result,nil)
                }
            }else{
                completionBlock(nil,nil,response.error)
            }
        }
        
    }
    func getChannelVideos(User_id: Int, completionBlock: @escaping (_ Success:MychannelModel.ChannelVideos.ChannelVideosSUccessModel?,_ SessionError:MychannelModel.ChannelVideos.ChannelVideosErrorModel?, Error?) ->()){
        let params = [
            API.Params.ServerKey : API.SERVER_KEY.Server_Key
            ] as [String : Any]
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        print("Decoded String",params)
        Alamofire.request(API.MY_CHANNEL_Methods.CHANNEL_VIDEOS_API + "\(User_id)", method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            if (response.result.value != nil){
                guard let Res = response.result.value as? [String:Any] else {return}
                guard let api_status = Res["api_status"]  as? String else {return}
                if api_status == "200"{
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    let result = try! JSONDecoder().decode(MychannelModel.ChannelVideos.ChannelVideosSUccessModel.self, from: data)
                    //                    log.verbose("Response = \(response.result.value)")
                    print("Response = \(result)")
                    completionBlock(result,nil,nil)
                }else if api_status == "400" {
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    let result = try! JSONDecoder().decode(MychannelModel.ChannelVideos.ChannelVideosErrorModel.self, from: data)
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
