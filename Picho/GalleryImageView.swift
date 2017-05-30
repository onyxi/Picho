//
//  GalleryImageView.swift
//  AlbmsApp
//
//  Created by Pete Holdsworth on 28/09/2016.
//  Copyright © 2016 Onyx Interactive. All rights reserved.
//

import UIKit

class GalleryImageView: UIImageView {

    
    override func awakeFromNib() {
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 1.0
        self.clipsToBounds = false
        self.layer.masksToBounds = false
    }
    

}
