//
//  CustomLabel.swift
//  AlbmsApp
//
//  Created by Pete Holdsworth on 29/09/2016.
//  Copyright © 2016 Onyx Interactive. All rights reserved.
//

import UIKit

@IBDesignable
class CustomLabel: UILabel {

    
    /// allow IB setting of corner radius
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
            
        }
    }
    

}
