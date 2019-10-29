//
//  Helper.swift
//  Playtube


import Foundation
import UIKit
import NVActivityIndicatorView

class validation : UIViewController {
    
    
    class func alert (str : String)-> UIAlertController{
        let alert = UIAlertController(title: NSLocalizedString("Playtube", comment: ""), message: str, preferredStyle: UIAlertController.Style.alert)
        let okbutton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okbutton)
        //   alert.view.tintColor =  UIColor.jungleGreen
        return alert
    }
    
}
func creatIndicator(view: UIView , controller: UIViewController)-> NVActivityIndicatorView{
    let activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: view.center.x
        , y: view.center.y, width: 50, height: 50))
    activityIndicatorView.center = view.center
    activityIndicatorView.type = .ballGridPulse
    activityIndicatorView.color = UIColor.mainBlue
    
    activityIndicatorView.startAnimating()
    view.isUserInteractionEnabled = false
    controller.view.addSubview(activityIndicatorView)
    return activityIndicatorView
}

func removeIndicator(indicator: NVActivityIndicatorView , view: UIView){
    DispatchQueue.main.async {
        indicator.removeFromSuperview()
        view.isUserInteractionEnabled = true
    }
}
