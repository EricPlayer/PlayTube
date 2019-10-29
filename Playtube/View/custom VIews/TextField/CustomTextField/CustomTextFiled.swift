//
//  viewExctention.swift
//  Playtube
//


import UIKit
import SkyFloatingLabelTextField
class CustomTextFiled: UIView {
    @IBOutlet weak var imgOfTextField: UIImageView!
    @IBOutlet weak var txtField: SkyFloatingLabelTextField!
    let nibName = "CustomTextField"
    var contentView: UIView?
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
        contentView = view
        updateAlignment()
    }
    
    @IBInspectable
    public var iconImage: UIImage = #imageLiteral(resourceName: "userIcon"){
        didSet {
            self.imgOfTextField.image = self.iconImage
        }
    }
    
    @IBInspectable
    public var title : String = "" {
        didSet {
            self.txtField.text = self.title
        }
    }
    
    
    @IBInspectable
    public var placeHolder : String = "" {
        didSet {
            self.txtField.placeholder = self.placeHolder
        }
    }
    
   @IBInspectable
   public var localizeText : String = "" {
       didSet {
        self.txtField.placeholder = localizeText
        }
    }
    func updateAlignment() {
 
            self.txtField.textAlignment = .left
            self.txtField.titleLabel.textAlignment = .left
        
    }
    
    @IBInspectable
    var keyboardType = UIKeyboardType.default.rawValue {
        didSet {
            self.txtField.keyboardType = UIKeyboardType(rawValue: keyboardType)!
        }
    }
    
    @IBInspectable
    var isSecure :Bool = false {
        didSet {
            self.txtField.isSecureTextEntry = self.isSecure
        }
    }
    @IBInspectable
    var textColor :UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) {
        didSet {
            self.txtField.textColor = textColor
        }
    }

    @IBInspectable
    var clearLineColor :Bool = false {
        didSet {
            if(clearLineColor == true)
            {
            self.txtField.selectedLineColor = .clear
            self.txtField.lineColor = .clear
            }
        }
    }
    
    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
}



