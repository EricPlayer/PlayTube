//
//  EditMyChannelVC.swift
//  Playtube


import UIKit
import Async
import Alamofire
import PlaytubeSDK

extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}
class EditMyChannelVC: BaseViewController {
    
    @IBOutlet weak var femaleBtn: UIButton!
    @IBOutlet weak var maleBtn: UIButton!
    @IBOutlet weak var emailTF: TJTextField!
    @IBOutlet weak var aboutTV: UITextView!
    @IBOutlet weak var usernameTF: TJTextField!
    @IBOutlet weak var lastNameTF: TJTextField!
    @IBOutlet weak var firstNameTF: TJTextField!
    
    private var gender:String? = ""
    private var userId:Int? = nil
    private var sessionId:String? = nil
    private let imagePickerController = UIImagePickerController()
    private var avatar:UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()
          self.view.backgroundColor = AppSettings.appColor
        self.getUserSession()
        getImgPath()
        self.fetchData()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.NavigationbarConfiguration()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = false
    }
    private func fetchData(){
        self.showProgressDialog(text: "Loading...")
        Async.background({
            MyChannelManager.instance.getChannelInfo(User_id: self.userId ?? 0, Session_Token: self.sessionId ?? "", Channel_id: self.userId ?? 0) { (success, sessionError, error) in
                if success != nil{
                    Async.main({
                      log.verbose("Succees = \(success)")
                        self.firstNameTF.text = success?.data!.firstName ?? ""
                        self.lastNameTF.text = success!.data!.lastName ?? ""
                        self.usernameTF.text = success?.data!.username ?? ""
                        self.emailTF.text = success!.data!.email ?? ""
                        self.aboutTV.text = success!.data!.about ?? ""
                        if success?.data!.gender == "male"{
                            self.maleBtn.setImage(UIImage(named: "radio_button_on"), for: .normal)
                            self.femaleBtn.setImage(UIImage(named: "radio_button_off"), for: .normal)
                             self.gender = "male"
                            
                        }else {
                            self.femaleBtn.setImage(UIImage(named: "radio_button_on"), for: .normal)
                            self.maleBtn.setImage(UIImage(named: "radio_button_off"), for: .normal)
                            self.gender = "female"
                        }
                        self.dismissProgressDialog()
                    })
                }else if sessionError != nil{
                    Async.main({
                        log.verbose("sessionError = \(sessionError?.errors!.errorText)")
                        self.view.makeToast(sessionError?.errors!.errorText)
                        self.dismissProgressDialog()
                    })
                }else{
                    Async.main({
                        log.verbose("error = \(error?.localizedDescription)")
                        self.view.makeToast(error?.localizedDescription)
                        self.dismissProgressDialog()
                    })
                }
               
            }
        })
      
        
    }
    
    @IBAction func genderBtnPressed(_ sender: UIButton) {
        if sender.tag == 0{
            self.maleBtn.setImage(UIImage(named: "radio_button_on"), for: .normal)
            self.femaleBtn.setImage(UIImage(named: "radio_button_off"), for: .normal)
            self.gender = "male"
        }else{
            self.femaleBtn.setImage(UIImage(named: "radio_button_on"), for: .normal)
            self.maleBtn.setImage(UIImage(named: "radio_button_off"), for: .normal)
            self.gender = "female"
        }
        
    }
    @IBAction func imageAvatarPressed(_ sender: Any) {
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
    @IBAction func imageCoverPressed(_ sender: Any) {
    }
    private  func getUserSession(){
        log.verbose("getUserSession = \(UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session))")
        let localUserSessionData = UserDefaults.standard.getUserSessions(Key: Local.USER_SESSION.User_Session)
        self.userId = localUserSessionData[Local.USER_SESSION.user_id] as! Int
        self.sessionId = localUserSessionData[Local.USER_SESSION.session_id] as! String
    }
    func getImgPath()
    {
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let userDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
        let paths             = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
        if let dirPath        = paths.first
        {
            let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent("image.jpg")
            let image    = UIImage(contentsOfFile: imageURL.path)
            log.verbose("image path = \(imageURL.path)")
            // Do whatever you want with the image
        }
        
    }
    private func NavigationbarConfiguration(){
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = false
        self.title = "Edit My Channel"
        let color = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color ]
        self.navigationController?.navigationBar.tintColor = color
        let Save = UIBarButtonItem(title: "Save", style: .done, target: self, action: Selector("Save"))
        self.navigationItem.rightBarButtonItem = Save
    }
    @objc func Save(){
        self.showProgressDialog(text: "Loading...")
        let firstname = self.firstNameTF.text ?? ""
        let lastname = self.lastNameTF.text ?? ""
        let username = self.usernameTF.text ?? ""
        let email = self.emailTF.text ?? ""
        let about = self.aboutTV.text ?? ""
        MyChannelManager.instance.editMyChannel(User_id: self.userId!, Session_Token: self.sessionId!, Username: username, FirstName: firstname, LastName: lastname, Email: email, About: about, Gender: gender ?? "") { (success, sessionError, error) in
            if success != nil{
                Async.main({
                    self.dismissProgressDialog()
                    self.view.makeToast(success?.message)
                    log.debug("success = \(success?.message)")
                })
            }else if sessionError != nil{
                Async.main({
                    self.dismissProgressDialog()
                    self.view.makeToast(sessionError?.errors!.errorText)
                    log.debug("ssessionError = \(sessionError?.errors!.errorText)")
                })
            }else {
                Async.main({
                    self.dismissProgressDialog()
                    self.view.makeToast(error?.localizedDescription)
                    log.debug("error = \(error?.localizedDescription)")
                })
            }
        }
        
    }
}
extension  EditMyChannelVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate{

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            self.avatar = image
            log.verbose("Imageselected = \(self.avatar)")
          self.showProgressDialog(text: "Loading...")
            self.dismiss(animated: true, completion: nil)
            let param = [
                "user_id":"\(userId ?? 0)",
                "s":sessionId ?? "",
                "server_key":API.SERVER_KEY.Server_Key,
                "settings_type":"avatar",
                "image" : self.avatar.jpegData(compressionQuality: 0.3)
                ] as [String : Any]
            requestWith(imageData: self.avatar.jpegData(compressionQuality: 0.3), parameters: param)

            
        }
    
    func requestWith(imageData: Data?, parameters: [String : Any], onCompletion: ((String?) -> Void)? = nil, onError: ((Error?) -> Void)? = nil){
        
        let url = API.MY_CHANNEL_Methods.UPDATE_MY_CHANNEL_API 
        
        let headers: HTTPHeaders = [
           
            "Content-type": "multipart/form-data"
        ]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
            if let data = imageData{
                multipartFormData.append(data, withName: "image", fileName: "image.png", mimeType: "image/png")
            }
            
        }, usingThreshold: UInt64.init(), to: url, method: .post, headers: headers) { (result) in
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    print("response = \(response.result.value)")
                    print("Succesfully uploaded")
                    if let err = response.error{
                        onError?(err)
                        return
                    }
                    onCompletion?(nil)
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                onError?(error)
            }
        }
    }
    
   
}


