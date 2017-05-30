//
//  ChooseAlbumTableViewCell.swift
//  AlbmsApp
//
//  Created by Pete Holdsworth on 02/10/2016.
//  Copyright © 2016 Onyx Interactive. All rights reserved.
//

import UIKit

class ChooseAlbumTableViewCell: UITableViewCell {

   
    @IBOutlet weak var albumCoverTile: UIImageView!
    @IBOutlet weak var albumTitleLabel: UILabel!
    @IBOutlet weak var remainingPhotosLabel: UILabel!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.albumCoverTile.layer.cornerRadius = 5
        self.albumCoverTile.layer.masksToBounds = true
        self.contentView.backgroundColor = UIColor.clear
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    
    
    
}
