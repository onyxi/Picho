//
//  Extensions.swift
//  Picho
//
//  Created by Pete on 08/04/2017.
//  Copyright © 2017 Onyx Interactive. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func loadImageUsingCacheWithURLString(url: String) {
        let coverURL = NSURL(string: url)
        var request = URLRequest(url: coverURL as! URL)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            print (data)
            //download hit an error so let's return out
            if error != nil {
                print (error)
                return
            }
            
            DispatchQueue.main.async(execute: {
                self.image = UIImage(data: data!)
            })
            
            
        }
        task.resume()

    }
    
}
