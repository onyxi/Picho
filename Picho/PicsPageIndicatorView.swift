//
//  PicsPageIndicatorView.swift
//  AlbmsApp
//
//  Created by Pete Holdsworth on 19/01/2017.
//  Copyright © 2017 Onyx Interactive. All rights reserved.
//

import UIKit

@IBDesignable class PicsPageIndicatorView: UIView {

    @IBInspectable var isActive: Bool = true
    
    override func draw(_ rect: CGRect) {
        
        let indicatorOutlineColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 0.5)
        indicatorOutlineColor.setStroke()
        
        
        let outerRect = CGRect(x: 2, y: 2, width: bounds.width - 4, height: bounds.height - 4)
        var outerPath = UIBezierPath(ovalIn: outerRect)
        outerPath.lineWidth = 2.0
        outerPath.stroke()
        
        if isActive {
            let innerRect = CGRect(x: 5, y: 5, width: bounds.width - 10, height: bounds.height - 10)
            let innerPath = UIBezierPath(ovalIn: innerRect)
            
            let indicatorCenterColor = UIColor(red: 85/255, green: 161/255, blue: 147/255, alpha: 0.8)
            indicatorCenterColor.setFill()
            innerPath.fill()
        }
    }
    
    
    
}
