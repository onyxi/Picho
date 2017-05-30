//
//  PastAlbumCollectionViewCell.swift
//  AlbmsApp
//
//  Created by Pete Holdsworth on 14/09/2016.
//  Copyright © 2016 Onyx Interactive. All rights reserved.
//

import UIKit
 

class PastAlbumCollectionViewCell: UICollectionViewCell {

    /// set outlets
    @IBOutlet weak var albumCoverTile: AlbumCollectionTileView!
    @IBOutlet weak var albumCoverImage: UIImageView!
    @IBOutlet weak var albumTitleLabel: UILabel!
    var shadeLayer: CAGradientLayer!
    
    override func awakeFromNib() {
        setupView() // trigger view setup
    }
    
    
    func setupView() {
        
        /// set gradient layer to album cover
        shadeLayer = CAGradientLayer()
        shadeLayer.frame = self.bounds
        let color1 = UIColor.clear.cgColor as CGColor
        let color2 = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.8).cgColor
        shadeLayer.colors = [color1, color2]
        shadeLayer.locations =  [0.45, 0.5]
        self.albumCoverImage.layer.addSublayer(shadeLayer)
        
        ///  set up shadow for album tile
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 1.0
        self.clipsToBounds = false
        self.layer.masksToBounds = false

    }
    
    

    
    
}
