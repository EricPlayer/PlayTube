//
//  viewExctention.swift
//  Playtube

import Foundation
import UIKit

extension UIView {
    
    @IBInspectable var cornerRadiusV: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidthV: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColorV: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    
}
@IBDesignable extension UIButton {
  
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}

extension String  {
    var isBlank: Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    var isEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,20}"
        let emailTest  = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
}
extension UIColor {
    class var mainBlue: UIColor {
        return UIColor(red: 76.0 / 255.0, green: 165.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)
    }
    
}
enum UserDefaultsKeys : String {
    case isLoggedIn
    case userID
}
extension UserDefaults{
    //MARK: Check Login
    func setLoggedIn(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isLoggedIn.rawValue)
        //synchronize()
    }
    
    func isLoggedIn()-> Bool {
        return bool(forKey: UserDefaultsKeys.isLoggedIn.rawValue)
    }
    
    //MARK: Save User Data
    func setUserSession(value: [String:Any], ForKey:String){
        set(value, forKey: ForKey)
        //synchronize()
    }
    func getUserSessions(Key:String) -> [String:Any]{
        return (object(forKey: Key) as? [String:Any]) ?? [:]
    }

    func setGetSettings(value: [String:String], ForKey:String){
        set(value, forKey: ForKey)
        //synchronize()
    }
    
    func getGetSettings(Key:String) ->  [String:String]{
    return ((object(forKey: Key) as? [String:String]) ?? [:])!
    }
    
    func clearUserDefaults(){
       removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }
    func removeValuefromUserdefault(Key:String){
        removeObject(forKey: Key)
    }
    func setWatchLater(value: [Data], ForKey:String){
        set(value, forKey: ForKey)
        synchronize()
        
    }
    func getWatchLater(Key:String) ->  [Data]{
        
        return ((object(forKey: Key) as? [Data]) ?? [])!
       
    }
    func setNotInterested(value: [Data], ForKey:String){
        set(value, forKey: ForKey)
        synchronize()
        
    }
    func getNotInterested(Key:String) ->  [Data]{
        
        return ((object(forKey: Key) as? [Data]) ?? [])!
        
    }
    func setOfflineDownload(value: [Data], ForKey:String){
        set(value, forKey: ForKey)
        synchronize()
        
    }
    func getOfflineDownload(Key:String) ->  [Data]{
        
        return ((object(forKey: Key) as? [Data]) ?? [])!
        
    }
    func setSharedVideos(value: [Data], ForKey:String){
        set(value, forKey: ForKey)
        synchronize()
        
    }
    func getSharedVideos(Key:String) ->  [Data]{
        
        return ((object(forKey: Key) as? [Data]) ?? [])!
        
    }
    
    func setLanguage(value: String, ForKey:String){
        set(value, forKey: ForKey)
        synchronize()
        
    }
    func getLanguage(Key:String) ->  String{
        
        return ((object(forKey: Key) as? String) ?? "")!
        
    }
    func setLibraryImages(value: [String], ForKey:String){
        set(value, forKey: ForKey)
        synchronize()
        
    }
    func getLibraryImages(Key:String) ->  [String]{
        
        return ((object(forKey: Key) as? [String]) ?? [])!
        
    }
    func setSubscriptionImage(value: String, ForKey:String){
        set(value, forKey: ForKey)
        synchronize()
        
    }
    func getSubscriptionImage(Key:String) ->  String{
        
        return ((object(forKey: Key) as? String) ?? "")!
        
    }
    func setRecentWatchImage(value: String, ForKey:String){
        set(value, forKey: ForKey)
        synchronize()
        
    }
    func getRecentWatchImage(Key:String) ->  String{
        
        return ((object(forKey: Key) as? String) ?? "")!
        
    }
    func setWatchLaterImage(value: String, ForKey:String){
        set(value, forKey: ForKey)
        synchronize()
        
    }
    func getOfflineImage(Key:String) ->  String{
        
        return ((object(forKey: Key) as? String) ?? "")!
        
    }
    func setOfflineImage(value: String, ForKey:String){
        set(value, forKey: ForKey)
        synchronize()
        
    }
    func getWatchLaterImage(Key:String) ->  String{
        
        return ((object(forKey: Key) as? String) ?? "")!
        
    }
    func setLikedImage(value: String, ForKey:String){
        set(value, forKey: ForKey)
        synchronize()
        
    }
    func getLikedImage(Key:String) ->  String{
        
        return ((object(forKey: Key) as? String) ?? "")!
        
    }
    
}
extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
//                self.layer.cornerRadius = 30
//                self.layer.masksToBounds = true
//                self.clipsToBounds = true
            }
            }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFill) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
        
    }
}
class RGBColor {
    func Color(R:Int,G:Int,B:Int,Alpha:Double) -> UIColor{
        return  UIColor(red:CGFloat(R/255), green: CGFloat(G/255), blue: CGFloat(B/255), alpha: CGFloat(Alpha))
    }
}
extension UIImageView {
    func makeRounded() {
        let radius = self.frame.height/2.0
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
}
public extension LazyMapCollection  {
    
    func toArray() -> [Element]{
        return Array(self)
    }
}
extension UIImage {
    
    var pngRepresentationData: Data? {
        return self.pngData()
    }
    
    var jpegRepresentationData: Data? {
        return jpegData(compressionQuality:1)
    }
}
extension String {
    /// Converts HTML string to a `NSAttributedString`
    
    var htmlAttributedString: String? {
        return try? NSAttributedString(data: Data(utf8), options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil).string
}
}
extension Int {
    var roundedWithAbbreviations: String {
        let number = Double(self)
        let thousand = number / 1000
        let million = number / 1000000
        if million >= 1.0 {
            return "\(round(million*10)/10)M"
        }
        else if thousand >= 1.0 {
            return "\(round(thousand*10)/10)K"
        }
        else {
            return "\(Int(number))"
        }
    }
}
extension CAShapeLayer {
    func drawCircleAtLocation(location: CGPoint, withRadius radius: CGFloat, andColor color: UIColor, filled: Bool) {
        fillColor = filled ? color.cgColor : UIColor.white.cgColor
        strokeColor = color.cgColor
        let origin = CGPoint(x: location.x - radius, y: location.y - radius)
        path = UIBezierPath(ovalIn: CGRect(origin: origin, size: CGSize(width: radius * 2, height: radius * 2))).cgPath
    }
}

private var handle: UInt8 = 0

extension UIBarButtonItem {
    private var badgeLayer: CAShapeLayer? {
        if let b: AnyObject = objc_getAssociatedObject(self, &handle) as AnyObject? {
            return b as? CAShapeLayer
        } else {
            return nil
        }
    }
    
    func addBadge(number: Int, withOffset offset: CGPoint = CGPoint.zero, andColor color: UIColor = UIColor.red, andFilled filled: Bool = true) {
        guard let view = self.value(forKey: "view") as? UIView else { return }
        
        badgeLayer?.removeFromSuperlayer()
        
        // Initialize Badge
        let badge = CAShapeLayer()
        let radius = CGFloat(7)
        let location = CGPoint(x: view.frame.width - (radius + offset.x), y: (radius + offset.y))
        badge.drawCircleAtLocation(location: location, withRadius: radius, andColor: color, filled: filled)
        view.layer.addSublayer(badge)
        
        // Initialiaze Badge's label
        let label = CATextLayer()
        label.string = "\(number)"
        label.alignmentMode = CATextLayerAlignmentMode.center
        label.fontSize = 11
        label.frame = CGRect(origin: CGPoint(x: location.x - 4, y: offset.y), size: CGSize(width: 8, height: 16))
        label.foregroundColor = filled ? UIColor.white.cgColor : color.cgColor
        label.backgroundColor = UIColor.clear.cgColor
        label.contentsScale = UIScreen.main.scale
        badge.addSublayer(label)
        
        // Save Badge as UIBarButtonItem property
        objc_setAssociatedObject(self, &handle, badge, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func updateBadge(number: Int) {
        if let text = badgeLayer?.sublayers?.filter({ $0 is CATextLayer }).first as? CATextLayer {
            text.string = "\(number)"
        }
    }
    
    func removeBadge() {
        badgeLayer?.removeFromSuperlayer()
    }
}
extension UIColor {
    convenience init(hexFromString:String, alpha:CGFloat = 1.0) {
        var cString:String = hexFromString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        var rgbValue:UInt32 = 10066329 //color #999999 if string has wrong format
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) == 6) {
            Scanner(string: cString).scanHexInt32(&rgbValue)
        }
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

extension Float {
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}
extension String {
    var floatValue: Float {
        return (self as NSString).floatValue
    }
}
extension String {
    var numberValue:NSNumber? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.number(from: self)
    }
}
extension String {
    func toInt(defaultValue: Int) -> Int {
        if let n = Int(self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)) {
            return n
        } else {
            return defaultValue
        }
    }
}
