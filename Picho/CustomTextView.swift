//
//  CustomTextView.swift
//  AlbmsApp
//
//  Created by Pete Holdsworth on 30/09/2016.
//  Copyright © 2016 Onyx Interactive. All rights reserved.
//

import UIKit

@IBDesignable
class CustomTextView: UITextView {

    @IBInspectable var cornerRadius: CGFloat = 1.0{
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
    
    func setupView() {
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = borderSize
        self.layer.borderColor = borderColor.cgColor
    }
    
}
