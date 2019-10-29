//
//  UnderlineTextField.swift
//  Playtube


import Foundation
import UIKit

@IBDesignable class TJTextField: UITextField {
    
    fileprivate var ImgIcon: UIImageView?
    
    @IBInspectable var errorEntry: Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var leftTextPedding: Int = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var lineColor: UIColor = UIColor.black {
        didSet {
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var placeHolerColor: UIColor = UIColor(red: 199.0/255.0, green: 199.0/255.0, blue: 205.0/255.0, alpha: 1.0) {
        didSet {
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var errorColor: UIColor = UIColor.red {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var imageWidth: Int = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var txtImage : UIImage? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return self.newBounds(bounds)
    }
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return self.newBounds(bounds)
    }
    
    fileprivate func newBounds(_ bounds: CGRect) -> CGRect {
        
        var newBounds = bounds
        newBounds.origin.x += CGFloat(leftTextPedding) + CGFloat(imageWidth)
        return newBounds
    }
    
    var errorMessage: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //setting left image
        if (txtImage != nil)
        {
            let imgView = UIImageView(image: txtImage)
            imgView.frame = CGRect(x: 0, y: 0, width: CGFloat(imageWidth), height: self.frame.height)
            imgView.contentMode = .center
            self.leftViewMode = UITextField.ViewMode.always
            self.leftView = imgView
        }
    }
    
    override func draw(_ rect: CGRect)
    {
        let height = self.bounds.height
        
        // get the current drawing context
        let context = UIGraphicsGetCurrentContext()
        
        // set the line color and width
        if errorEntry {
            context?.setStrokeColor(errorColor.cgColor)
            context?.setLineWidth(1.5)
        } else {
            context?.setStrokeColor(lineColor.cgColor)
            context?.setLineWidth(0.5)
        }
        
        // start a new Path
        context?.beginPath()
        
        context!.move(to: CGPoint(x: self.bounds.origin.x, y: height - 0.5))
        context!.addLine(to: CGPoint(x: self.bounds.size.width, y: height - 0.5))
        // close and stroke (draw) it
        context?.closePath()
        context?.strokePath()
        
        //Setting custom placeholder color
        if let strPlaceHolder: String = self.placeholder
        {
            self.attributedPlaceholder = NSAttributedString(string:strPlaceHolder,
                                                            attributes:[NSAttributedString.Key.foregroundColor:placeHolerColor])
        }
    }
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect
    {
        return CGRect(x: 0, y: 0, width: CGFloat(imageWidth), height: self.frame.height)
    }
}
