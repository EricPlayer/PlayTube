//
//  Url.swift
//  Playtube


import Foundation


struct Url {
    
    static var server_key = "5ca11cbdd144863916b48c628e3d40dc"
    static var appVerstion = "v1.0"
    static var baseUrl = "https://playtubescript.com/"
    static var register = "\(baseUrl)/api/\(Url.appVerstion)?type=register"
    static var login = "\(baseUrl)/api/\(Url.appVerstion)?type=login"
}
