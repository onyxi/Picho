//
//  FireSD.swift
//  Picho
//
//  Created by Pete on 29/01/2017.
//  Copyright © 2017 Onyx Interactive. All rights reserved.
//

import Foundation
import FirebaseStorage

class FireSD {
    

    
    static func uploadPhotoFromMemory (albumName: String, photoName: String, photo: UIImage) {
       
        var storageRef: FIRStorageReference!
        storageRef = FIRStorage.storage().reference()
        
        // prepare image object
        guard let imageData = UIImageJPEGRepresentation(photo, 0.8) else { return }
        
        // prepare storage path
        let imagesRef = storageRef.child("images")
        let albumRef = imagesRef.child(albumName)
        let photoRef = albumRef.child("\(photoName).jpg")
   
        // prepare metadata
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // Upload the object to the path
        let uploadTask = photoRef.put(imageData, metadata: metadata) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                print("error: \(error?.localizedDescription)")
                return
            }
            // Metadata contains file metadata such as size, content-type, and download URL.
            let downloadURL = metadata.downloadURL
            let url = downloadURL()
            print (url)
        }
    }
    
    
}






