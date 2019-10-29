//
//  UserManager.swift
//  Playtube
//

import Foundation
import Alamofire
import PlaytubeSDK
class UserManager:NSObject {
    
    static let instance = UserManager()
    
    //Authenticate User On Server
    func authenticateUser(UserName: String, Password: String, completionBlock: @escaping (_ Success:LoginModel.UserSuccessModel?,_ AuthError:LoginModel.UserErrorModel?, Error?) ->()){
        
        let params = [
            API.Params.Username: UserName,
            API.Params.Password: Password,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Decoded String = \(decoded)")
        Alamofire.request(API.AUTH_Constants_Methods.LOGIN_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            if (response.result.value != nil){
                guard let Res = response.result.value as? [String:Any] else {return}
                guard let apiStatus = Res["api_status"]  as? String else {return}
                if apiStatus == "200"{
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    let result = try! JSONDecoder().decode(LoginModel.UserSuccessModel.self, from: data)
                    log.debug("Success = \(result.data!.message)")
                    let User_Session = [Local.USER_SESSION.cookie:result.data!.cookie,Local.USER_SESSION.session_id:result.data!.sessionID,Local.USER_SESSION.user_id:result.data!.userID] as [String : Any]
                    UserDefaults.standard.setUserSession(value: User_Session, ForKey: Local.USER_SESSION.User_Session)
                    completionBlock(result,nil,nil)
                }else if apiStatus == "400" {
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    let result = try! JSONDecoder().decode(LoginModel.UserErrorModel.self, from: data)
                    log.error("AuthError = \(result.errors!.errorText)")
                    completionBlock(nil,result,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription)")
                completionBlock(nil,nil,response.error)
            }
        }
        
    }
    func RegisterUser(Email:String,UserName: String, Password: String,ConfirmPassword:String, completionBlock: @escaping (_ Success:RegisterModel.RegisterSuccessModel?,_ EmailSucces:RegisterModel.RegisterEmailSuccessModel?,_ AuthError:RegisterModel.RegisterErrorModel?, Error?) ->()){
        let params = [
            API.Params.Username: UserName,
            API.Params.Email: Email,
            API.Params.Password: Password,
            API.Params.ConfirmPassword: ConfirmPassword,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Decoded String = \(decoded)")
        Alamofire.request(API.AUTH_Constants_Methods.REGISTER_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            if (response.result.value != nil){
                log.verbose("reponse = \(response.result.value)")
                guard let Res = response.result.value as? [String:Any] else {return}
                guard let apiStatus = Res["api_status"]  as? String else {return}
                 guard let  message = Res["message"]  as? String else {return}
                if apiStatus == "200"{
                    if message == "Successfully joined, Please wait.."{
                        let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                        let result = try! JSONDecoder().decode(RegisterModel.RegisterSuccessModel.self, from: data)
                        
                        log.debug("Success = \(result.message)")
                        let User_Session = [Local.USER_SESSION.cookie:result.data!.cookie,Local.USER_SESSION.session_id:result.data!.s,Local.USER_SESSION.user_id:result.data!.userID] as [String : Any]
                        UserDefaults.standard.setUserSession(value: User_Session, ForKey: Local.USER_SESSION.User_Session)
                        completionBlock(result,nil,nil,nil)
                    }else{
                        let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                        let result = try! JSONDecoder().decode(RegisterModel.RegisterEmailSuccessModel.self, from: data)
                        log.debug("Success = \(result.message)")
                        completionBlock(nil,result,nil,nil)
                    }
                }else if apiStatus == "400" {
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    let result = try! JSONDecoder().decode(RegisterModel.RegisterErrorModel.self, from: data)
                    log.error("AuthError = \(result.errors!.errorText)")
                    completionBlock(nil,nil,result,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription)")
                completionBlock(nil,nil,nil,response.error)
            }
            
        }
        
    }
    
    func ForgetPassword(Email:String, completionBlock: @escaping (_ Success:ForgotPasswordModel.ForgotPasswordSuccessModel?,_ AuthError:ForgotPasswordModel.ForgotPasswordErrorModel?, Error?) ->()){
        let params = [
            API.Params.Email: Email,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Decoded String = \(decoded)")
        Alamofire.request(API.AUTH_Constants_Methods.FORGETPASSWORD_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            if (response.result.value != nil){
                guard let Res = response.result.value as? [String:Any] else {return}
                guard let apiStatus = Res["api_status"]  as? String else {return}
                if apiStatus == "200"{
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    let result = try! JSONDecoder().decode(ForgotPasswordModel.ForgotPasswordSuccessModel.self, from: data)
                    log.debug("Success = \(result.data!.message)")
                    completionBlock(result,nil,nil)
                }else if apiStatus == "400" {
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    let result = try! JSONDecoder().decode(ForgotPasswordModel.ForgotPasswordErrorModel.self, from: data)
                    log.error("AuthError = \(result.errors!.errorText)")
                    completionBlock(nil,result,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription)")
                completionBlock(nil,nil,response.error)
            }
            
        }
        
    }
    
    func deleteUser(User_id: Int, Session_Token: String, completionBlock: @escaping (_ Success:DeleteUserModel.DeleteUserSuccessModel?,_ SessionError:DeleteUserModel.DeleteUserErrorModel?, Error?) ->()){
        let params = [
            API.Params.user_id : User_id,
            API.Params.session_token : Session_Token,
            API.Params.ServerKey : API.SERVER_KEY.Server_Key
            ] as [String : Any]
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        print("Decoded String",params)
        Alamofire.request(API.AUTH_Constants_Methods.DELETE_USER_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            if (response.result.value != nil){
                guard let Res = response.result.value as? [String:Any] else {return}
                guard let api_status = Res["api_status"]  as? String else {return}
                if api_status == "200"{
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    let result = try! JSONDecoder().decode(DeleteUserModel.DeleteUserSuccessModel.self, from: data)
                    //                    log.verbose("Response = \(response.result.value)")
                    print("Response = \(result)")
                    completionBlock(result,nil,nil)
                }else if api_status == "400"{
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    let result = try! JSONDecoder().decode(DeleteUserModel.DeleteUserErrorModel.self, from: data)
                    //                    log.verbose("Response = \(response.result.value)")
                    print("Response = \(result)")
                    completionBlock(nil,result,nil)
                }
            }else{
                completionBlock(nil,nil,response.error)
            }
        }
        
    }
    
    func facebookLogin(Provider:String,AccessToken:String, completionBlock: @escaping (_ Success:LoginModel.UserSuccessModel?,_ AuthError:LoginModel.UserErrorModel?, Error?) ->()){
        let params = [
            API.Params.Provider: Provider,
            API.Params.AccessToken: AccessToken,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Decoded String = \(decoded)")
        Alamofire.request(API.AUTH_Constants_Methods.SOCIAL_LOGIN_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            if (response.result.value != nil){
                guard let Res = response.result.value as? [String:Any] else {return}
                guard let apiStatus = Res["api_status"]  as? String else {return}
                if apiStatus == "200"{
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    let result = try! JSONDecoder().decode(LoginModel.UserSuccessModel.self, from: data)
                    log.debug("Success = \(result.data!.message)")
                    let User_Session = [Local.USER_SESSION.cookie:result.data!.cookie,Local.USER_SESSION.session_id:result.data!.sessionID,Local.USER_SESSION.user_id:result.data!.userID] as [String : Any]
                    UserDefaults.standard.setUserSession(value: User_Session, ForKey: Local.USER_SESSION.User_Session)
                    completionBlock(result,nil,nil)
                }else if apiStatus == "400" {
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    let result = try! JSONDecoder().decode(LoginModel.UserErrorModel.self, from: data)
                    log.error("AuthError = \(result.errors!.errorText)")
                    completionBlock(nil,result,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription)")
                completionBlock(nil,nil,response.error)
            }
            
        }
        
    }
    func googleLogin(Provider:String,AccessToken:String,GoogleApiKey:String, completionBlock: @escaping (_ Success:LoginModel.UserSuccessModel?,_ AuthError:LoginModel.UserErrorModel?, Error?) ->()){
        let params = [
            API.Params.Provider: Provider,
            API.Params.AccessToken: AccessToken,
            API.Params.ServerKey: API.SERVER_KEY.Server_Key,
            API.Params.Google_Key : GoogleApiKey
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: params, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        log.verbose("Decoded String = \(decoded)")
        Alamofire.request(API.AUTH_Constants_Methods.SOCIAL_LOGIN_API, method: .post, parameters: params, encoding:URLEncoding.default , headers: nil).responseJSON { (response) in
            if (response.result.value != nil){
                log.verbose("JsonPrint = \(response.result.value)") 
                guard let Res = response.result.value as? [String:Any] else {return}
                guard let apiStatus = Res["api_status"]  as? String else {return}
                if apiStatus == "200"{
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    let result = try! JSONDecoder().decode(LoginModel.UserSuccessModel.self, from: data)
                    log.debug("Success = \(result.data!.message)")
                    let User_Session = [Local.USER_SESSION.cookie:result.data!.cookie,Local.USER_SESSION.session_id:result.data!.sessionID,Local.USER_SESSION.user_id:result.data!.userID] as [String : Any]
                    UserDefaults.standard.setUserSession(value: User_Session, ForKey: Local.USER_SESSION.User_Session)
                    completionBlock(result,nil,nil)
                }else if apiStatus == "400" {
                    let data = try! JSONSerialization.data(withJSONObject: response.value, options: [])
                    
                    let result = try! JSONDecoder().decode(LoginModel.UserErrorModel.self, from: data)
                    log.error("AuthError = \(result.errors!.errorText)")
                    completionBlock(nil,result,nil)
                }
            }else{
                log.error("error = \(response.error?.localizedDescription)")
                completionBlock(nil,nil,response.error)
            }
            
        }
        
    }
    
}
