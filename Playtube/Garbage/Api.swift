//
//  Api.swift
//  Playtube



import Foundation
import UIKit
import Alamofire
import SwiftyJSON


protocol registrationDelegation {
    func sucessRegisterConnection()
}

protocol loginDelegation {
    func sucessLoginData()
}




class Api: NSObject {
    
    var registerDelegate: registrationDelegation?
    var loginDelegate: loginDelegation?
    
    func registerNewUser(userName: String , userEmail: String , pass: String ,controller: UIViewController , view: UIView){
        
        let indic = creatIndicator(view: view, controller: controller)
        let url = Url.register
        
        let param = [
            "server_key" : Url.server_key ,
            "username" : userName ,
            "email" : userEmail ,
            "password" : pass ,
            "confirm_password" : pass ,
        ]
        Alamofire.request(url, method: .post, parameters: param, encoding: URLEncoding.default, headers: nil).responseJSON{
            
            response in
            
            if response.result.isSuccess {
                let json = JSON(response.result.value!)
                if json["api_status"] == "200" {
                    
                    // created new user
                var user = Users()
                let data = usersData()
                    user.userName = userName
                    user.userEmail = userEmail
                    user.user_id = json["data"]["user_id"].int ?? 0
                    user.s = json["data"]["s"].string ?? ""
                    user.cookie = json["data"]["cookie"].string ?? ""
                    UserDefaults.standard.set(user.userName, forKey: "userName")
                    UserDefaults.standard.set(user.userEmail, forKey: "userEmail")
                    UserDefaults.standard.set(user.user_id, forKey: data.user_id)
                    UserDefaults.standard.set(user.s, forKey: data.s)
                    UserDefaults.standard.set(user.cookie, forKey: data.cookie)
                    UserDefaults.standard.synchronize()
                    if self.registerDelegate != nil {
                        self.registerDelegate?.sucessRegisterConnection()
                    }
                    removeIndicator(indicator: indic, view: view)
                }else if json["api_status"] == "400"{
                    removeIndicator(indicator: indic, view: view)
                    let alert = validation.alert(str: json["errors"]["error_text"].string ?? "")
                    controller.present(alert, animated: true, completion: nil)
                }
                print(json)
            }else{
                removeIndicator(indicator: indic, view: view)
                print("failed connection\(String(describing: response.response?.statusCode))")
                let alert = validation.alert(str: "there is somthing wrong, try again later.")
                controller.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    func loginUser(view: UIView , controller: UIViewController , userName:String , password:String){
         let indic = creatIndicator(view: view, controller: controller)
        let url = Url.login
        let param = [
            "username" : userName ,
            "password" : password ,
            "server_key" : Url.server_key ,
        ]
        print(param)
        print(url)
        Alamofire.request(url, method: .post, parameters: param, encoding: URLEncoding.default, headers: nil).responseJSON{
            response in
            if response.result.isSuccess {
                removeIndicator(indicator: indic, view: view)
                let json = JSON(response.result.value!)
                print(json)
                if json["api_status"] == "400" {
                    let alert = validation.alert(str: json["errors"]["error_text"].string ?? "")
                    controller.present(alert, animated: true, completion: nil)
                }else if json["api_status"] == "200" {
                    if self.loginDelegate != nil {
                        // save user data
                        var user = Users()
                        user.cookie = json["data"]["cookie"].string ?? ""
                        user.user_id = json["data"]["user_id"].int ?? 0
                        user.session_id = json["data"]["session_id"].string ?? ""
                        let f = usersData()
                        UserDefaults.standard.set(user.cookie, forKey: f.cookie)
                        UserDefaults.standard.set(user.session_id, forKey: f.session_id)
                        UserDefaults.standard.set(user.user_id, forKey: f.user_id)
                        self.loginDelegate?.sucessLoginData()
                    }
                }
            }else{
                removeIndicator(indicator: indic, view: view)
                let alert = validation.alert(str: "there is something wrong, try again later.")
                controller.present(alert, animated: true, completion: nil)
            }
        }
    }
}
