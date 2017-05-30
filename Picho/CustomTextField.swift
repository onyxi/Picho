//
//  CustomTextField.swift
//  AlbmsUI
//
//  Created by Pete on 29/08/2016.
//  Copyright © 2016 Pete. All rights reserved.
//

import UIKit

@IBDesignable
class  CustomTextField: UITextField {
    
    @IBInspectable var inset: CGFloat = 3
    
    
    
    @IBInspectable var cornerRadius: CGFloat = 5.0 {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable var borderSize: CGFloat = 1.0 {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.white {
        didSet{
            setupView()
        }
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: inset, dy: inset)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 5.0
    }
    
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    
    func setupView() {
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = borderSize
        self.layer.borderColor = borderColor.cgColor
        
    }
    
    
}
