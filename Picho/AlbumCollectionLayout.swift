//
//  AlbumCollectionLayout.swift
//  AlbmsApp
//
//  Created by Pete Holdsworth on 14/09/2016.
//  Copyright © 2016 Onyx Interactive. All rights reserved.
//

import UIKit

protocol AlbumCollectionLayoutDelegate {
    // 1
    func collectionView(_ collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath,
                        withWidth:CGFloat) -> CGFloat
    // 2
    func collectionView(_ collectionView: UICollectionView,
                        heightForAnnotationAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat
}


class AlbumCollectionLayout: UICollectionViewLayout {

}
