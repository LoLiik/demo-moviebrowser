//
//  PostImageView.swift
//  FlatunDemo
//
//  Created by Евгений on 22.11.2018.
//  Copyright © 2018 Евгений. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

class PostImageView: UIImageView {

    var imageUrlString: String?

    func loadImageUsingUrlString(urlString: String) {

        imageUrlString = urlString

        let url = NSURL(string: urlString)

        if let imageFromCache = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = imageFromCache
            return
        }

        URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, respones, error) in

            if error != nil {
                print(error!)
                return
            }

            DispatchQueue.main.async {

                let imageToCache = UIImage(data: data!)

                if self.imageUrlString == urlString {
                    self.image = imageToCache
                }

                imageCache.setObject(imageToCache!, forKey: urlString as AnyObject)
            }

        }).resume()
    }

}


