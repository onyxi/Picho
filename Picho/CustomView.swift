//
//  CustomView.swift
//  AlbmsApp
//
//  Created by Pete on 02/01/2017.
//  Copyright © 2017 Onyx Interactive. All rights reserved.
//

import UIKit

@IBDesignable
class CustomView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            setupView()
        }
    }
    
    func setupView() {
        self.layer.cornerRadius = cornerRadius
    }
    
}
