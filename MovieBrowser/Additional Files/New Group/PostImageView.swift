//
//  PostImageView.swift
//  FlatunDemo
//
//  Created by Евгений on 22.11.2018.
//  Copyright © 2018 Евгений. All rights reserved.
//

import UIKit
import Alamofire

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

        let queue = DispatchQueue(label: "tmdb.test.api", qos: .background, attributes: .concurrent)
        Alamofire.request(urlString,
                          method: .get)
            .validate()
            .responseData(queue: queue){ response in
                guard response.error == nil else {
                    print("Error while fetching image from url: \(urlString)")
                    return
                }

                guard let responseData = response.data else {
                    print("Error while fetching image from url: \(urlString)")
                    return
                }

            DispatchQueue.main.async {
                if let imageToCache = UIImage(data: responseData){
                    if self.imageUrlString == urlString {
                        self.image = imageToCache
                    }

                    imageCache.setObject(imageToCache, forKey: urlString as AnyObject)
                }
            }

        }
    }

}


