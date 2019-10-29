//
//  VerificationVC.swift
//  Playtube
//
//  Created by Macbook Pro on 05/04/2019.
//  Copyright © 2019 Muhammad Haris Butt. All rights reserved.
//

import UIKit
import PlaytubeSDK
import Async
import Alamofire

class VerificationVC: BaseViewController {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var selectedImage: UIImageView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    private let imagePickerController = UIImagePickerController()
    private var userId:Int? = nil
    private var sessionId:String? = nil
    private var imageData:Data? = nil
    private var ImageURL:String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getUserSession()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.NavigationbarConfiguration()
    }
    
    @IBAction func submitPressed(_ sender: Any) {
        if (self.firstNameTextField.text?.isEmpty)! {
            self.view.makeToast("Please enter first name.")
        }else if (self.lastNameTextField.text?.isEmpty)!{
            self.view.makeToast("Please enter last name.")
        }else if (self.messageTextField.text?.isEmpty)!{
            self.view.makeToast("Please enter a message.")
        }else if imageData == nil{
            
            self.view.makeToast("Please select recent picutre of your passport or id.")
        }else{
            self.showProgressDialog(text: "Loading...")
            let firstName = self.firstNameTextField.text
            let lastName = self.lastNameTextField.text
            let message = self.messageTextField.text
         
            self.showProgressDialog(text: "Loading...")
//
            log.verbose("Image Url Path = \(self.ImageURL)")
        Async.background({
            VerificationManager.instance.VerificationUser(User_id: self.userId ?? 0  , Session_Token: self.sessionId ?? "" , FirstName: firstName ?? "", LastName: lastName ?? "", Identity: (self.imageData)!, Message: message ?? "", completionBlock: { (success, sessionError, error) in
                if success != nil{
                   Async.main({
                    self.view.makeToast(success?.message)
                    self.dismissProgressDialog()
                    log.debug("Success = \(success?.message)")
                   })
                }else if sessionError != nil{
                    Async.main({
                        self.dismissProgressDialog()
                        self.view.makeToast(sessionError?.errors.errorText)
                        log.error("SessionError = \(sessionError?.errors.errorText)")
                    })
                }else{
                    Async.main({
                        log.error("error = \(error?.localizedDescription)")
                        self.view.makeToast(error?.localizedDescription)
                        self.dismissProgressDialog()
                    })
                }
            })
        })
//            })
            
        }
    }
    @IBAction func selectPicturePressed(_ sender: Any) {
        let alert = UIAlertController(title: "", message: "Select Source", preferredStyle: .alert)
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.imagePickerController.delegate = self
            
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .camera
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let gallery = UIAlertAction(title: "Gallery", style: .default) { (action) in
            self.imagePickerController.delegate = self
            
            self.imagePickerController.allowsEditing = true
            self.imagePickerController.sourceType = .photoLibrary
            self.present(self.imagePickerController, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alert.addAction(camera)
        alert.addAction(gallery)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func crossPressed(_ sender: Any) {
        self.selectedImage.image = UIImage(named: "maxresdefault-1")
    }
    
    private  func getUserSession(){
        log.verbose("getUserSession = \(UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session))")
        let localUserSessionData = UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session)
        self.userId = localUserSessionData[Local.USER_SESSION.user_id] as! Int
        self.sessionId = localUserSessionData[Local.USER_SESSION.session_id] as! String
    }
    
    private func NavigationbarConfiguration(){
        self.tabBarController?.tabBar.isHidden = true
        self.title = "Verification"
        let color = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color ]
        self.navigationController?.navigationBar.tintColor = color
    }
    
}

extension  VerificationVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        log.verbose("Imageselected = \(image)")
        self.selectedImage.image = image
        self.imageData = image.jpegData(compressionQuality: 0.1)
        self.saveImageToDocumentDirectory(image: image)
        self.loadImageFromDocumentDirectory(nameOfImage: "image001.png")
        
        self.dismiss(animated: true, completion: nil)
        
        
    }
    func saveImageToDocumentDirectory(image: UIImage ) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "image001.png" // name of the image to be saved
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
       
        if let data = image.jpegData(compressionQuality: 1.0),!FileManager.default.fileExists(atPath: fileURL.path){
            do {
                try data.write(to: fileURL)
                print("file saved")
            } catch {
                print("error saving file:", error)
            }
        }
    }
    
    
    func loadImageFromDocumentDirectory(nameOfImage : String) -> UIImage {
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)

        if let dirPath = paths.first{
            let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(nameOfImage)
            self.ImageURL = "image001.png"
             log.verbose("Paths = \(imageURL.path)")
            let image    = UIImage(contentsOfFile: imageURL.path)
            return image!
        }
        return UIImage.init(named: "default.png")!
    }
 
    
 
}
