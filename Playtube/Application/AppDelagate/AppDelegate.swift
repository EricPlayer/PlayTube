//
//  AppDelegate.swift
//  Playtube
//


import UIKit
import IQKeyboardManagerSwift
import SwiftyBeaver
import DropDown
import Async
import OneSignal
import FBSDKLoginKit
import GoogleSignIn
import PlaytubeSDK

let log = SwiftyBeaver.self

//let key = "VjFaV2IxVXdNVWhVYTJ4VlZrWndUbHBXVW5OTk1XeHlXa1ZrVDFZeFNrcFdiVEZ6V1Zaa1JrNVlSbHBOYWtaNldrUktVMUpGTlZoalIyeE9ZV3RGTlNOV1JscFRWREpHUjJOR1ZsaFhSMUpRVld0a01FMUdaRmxqUlVwc1ZsUldkMVJWVWtOVU1ERnlZVE5rVlZKc1NucFpiRlV4VjBaV1dWVnJPV2xXYlhRMFZqSjBhMVpyTUhoalNGSlhWMGRvVDFsc1ZuZGpkejA5UURka09ERXlZekJrT0RNMU1HVmlNalJtT0RrME9XSTNZakJoWlRBeU1XWm1KREl4TVRrMU16WXk="
//let googleClientKey = "497109148599-u0g40f3e5uh53286hdrpsj10v505tral.apps.googleusercontent.com"
//let oneSignalAppID = "b64b10e7-4cc4-455b-adcb-54e580e6b5ff"
let key = "VjFaV2IxVXdNVWhVYTJ4VlZrWndUbHBXVW5OamJHUnpXa1JTYTJKVmNEQlphMk40V1Zaa1JtTkhPVlZTZWtGNFdXMTBNMlZXU25WYVIzQlNaV3RhZGxZeWRHcGxSMDVJVTIwMVVWWkVRVGtqVmtaa2QxWXlSbk5qU0ZKVFZrVTFVVlpyV2xkTlJsSlpZMGhLVDFadVFsVlVWVkpEVkd4SmVGWnFXbFZTYkVwNVZHeFZOVlpXYTNwVmJIQlhVbFZaTVZaRVJsTmhiVkYzVFZWV1lWSjZSazlaVnpFMFkwRTlQVUF5T0ROaE5qUmhZakk0TnpnMlltWm1NMlJsTUdVNVpUZzNPRFkwTkRnek1pUXlNelF5TnpVMk1RPT0="
let googleClientKey = "595278948486-dmi3otdlugsc00ne76if1jo5dq65l80l.apps.googleusercontent.com"
let oneSignalAppID = "af044056-0403-4654-887e-70fa45ad4b2e"
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var appDelCategories:[String:String]? = nil
    var myChannelInfo:MychannelModel.GetChannelInfoModel.DataClass? = nil
    var videoId:String? = nil
    var commentVideoId:Int? = nil
    var recipientID:Int? = 0
    var userChatsObject:UserChatModel.DataClass?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        initFramework()
//        UIView.appearance().backgroundColor = AppSettings.appColor
        
        GIDSignIn.sharedInstance().clientID = googleClientKey
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId:oneSignalAppID ,
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings)
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
      
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })
      
        self.GetSetting()
        log.debug("UserSession Bool = \(UserSession())")
        if UserSession() == true{
            let mainStoryboard = UIStoryboard(name: "LoggedInTabbar", bundle: nil)
            let tabbarVC =  mainStoryboard.instantiateViewController(withIdentifier: "TabbarVC") as! TabbarVC
            self.window?.rootViewController = tabbarVC
            loadingProfile()
        }else{
            let mainStoryboard = UIStoryboard(name: "Auth", bundle: nil)
            let Login =  mainStoryboard.instantiateViewController(withIdentifier: "Login")
            window?.rootViewController = Login
        }
   
        
        return true
    }
    
  
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let handled: Bool = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        // Add any custom logic here.
        return handled
    }

    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
  
    private func initFramework(){
//        UserDefaults.standard.clearUserDefaults()
        ServerCredentials.setServerDataWithKey(key: key)
        IQKeyboardManager.shared.enable = true
        DropDown.startListeningToKeyboard()
        let console = ConsoleDestination()
        log.addDestination(console)
    }
   func UserSession()->Bool{
        if !UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session).isEmpty{
            return true
        }else {
            return false
        }
    }
   private func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }

    func loadingProfile(){
        
        let localUserSessionData = UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session)
        if localUserSessionData.isEmpty{
            log.verbose("NotLoggedIn")
        }else{
            let userId = localUserSessionData[Local.USER_SESSION.user_id] as! Int
            let sessionId = localUserSessionData[Local.USER_SESSION.session_id] as! String
            if Reachability.isConnectedToNetwork(){
                Async.background({
                    MyChannelManager.instance.getChannelInfo(User_id:userId, Session_Token: sessionId, Channel_id: userId, completionBlock: { (success, sessionError, error) in
                        if success != nil{
                            Async.main({
                                self.myChannelInfo = success?.data
                                log.debug("success")
                                
                            })
                        }else if sessionError != nil {
                            Async.main({
                                log.error("sessionErrror = \(sessionError?.errors!.errorText)")
                            })
                        }else {
                            Async.main({
                                log.error("error =  \(error?.localizedDescription)")
                            })
                        }
                    })
                })
            }else {
                self.inputView?.makeToast(InterNetError)
            }
        }
        
        
    }
   private func GetSetting() {
        
        let getSetting =  UserDefaults.standard.getGetSettings(Key: Local.GET_SETTINGS.Categories)
        if !getSetting.isEmpty{
            log.debug("Already Saved in UserDefaults")
            self.appDelCategories = getSetting
            log.verbose("categories = \(self.appDelCategories)")
        }else{
            log.debug("Saving settings in UserDefaults")
            Async.background({
                GetSettingsManager.instance.getSetting { (categories, settings, sessionError, error) in
                    
                    if categories != nil && settings != nil{
                        Async.main({
                            log.debug("categories = \(categories)")
                            log.debug("settings = \(settings)")
                            UserDefaults.standard.setGetSettings(value: categories ?? [:], ForKey: Local.GET_SETTINGS.Categories)
                            UserDefaults.standard.setGetSettings(value: settings ?? [:], ForKey: Local.GET_SETTINGS.Settings)
                            self.appDelCategories = categories
                            log.verbose("categories = \(self.appDelCategories)")
                            //
                        })
                        
                    }else if sessionError != nil{
                        Async.main({
                            log.error("sessionError  = \(sessionError)")
                        })
                        
                    }else {
                        Async.main({
                            log.error("error  = \(error?.localizedDescription)")
                        })
                    }
                }
            })
        }
    }
}

