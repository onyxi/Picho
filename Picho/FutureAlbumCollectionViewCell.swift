//
//  FutureAlbumCollectionViewCell.swift
//  AlbmsApp
//
//  Created by Pete Holdsworth on 14/09/2016.
//  Copyright © 2016 Onyx Interactive. All rights reserved.
//

import UIKit
 

class FutureAlbumCollectionViewCell: UICollectionViewCell {

    /// set outlets
    @IBOutlet weak var albumCoverTile: AlbumCollectionTileView!
    @IBOutlet weak var albumCoverImage: UIImageView!
    @IBOutlet weak var albumTitleLabel: UILabel!
    @IBOutlet weak var shadeLayer: UIView!
    @IBOutlet weak var lockedIcon: UIImageView!
    
    
    override func awakeFromNib() {
        setupView() // trigger view setup
    }
    
    
    func setupView() {
        /// set up shadow for album tile
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 1.0
        self.clipsToBounds = false
        self.layer.masksToBounds = false
    }
    
    
    
    
}
