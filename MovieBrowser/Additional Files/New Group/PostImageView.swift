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

    static var documentURL: URL{
        let fileManager = FileManager.default
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    var imageUrlString: String?

    func loadImageUsingUrlString(urlString: String) {

        imageUrlString = urlString

        let url = NSURL(string: urlString)

        // Check if there is saved ccopy of image
        let imageName = imageUrlString?.components(separatedBy: "/").last
        let filePath = PostImageView.documentURL.appendingPathComponent("\(String(describing: imageName!))")

        if FileManager.default.fileExists(atPath: filePath.path){
            if let contentsOfFilePath = UIImage(contentsOfFile: filePath.path){
                DispatchQueue.main.async {
                    self.image = contentsOfFilePath
                }
                return
            }
        }

//        if let imageFromCache = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
//            self.image = imageFromCache
//            return
//        }

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
                    // Save image to cache
//                    imageCache.setObject(imageToCache, forKey: urlString as AnyObject)

                    // Write image to file
                    // Check for existing image data
                    do{
                        // Look through array of files in documentDirectory
                        let files = try FileManager.default.contentsOfDirectory(atPath: PostImageView.documentURL.path)
                        for file in files{
                            if "\(PostImageView.documentURL.path)/\(file)" == filePath.path {
                                try FileManager.default.removeItem(at: filePath)
                            }
                        }
                    } catch{
                        print("Couldn't add image from document directory \(error)")
                    }

                    // Create imageData and write to filePath
                    do{
                        if let pngImageData = imageToCache.pngData(){ //UIImage.pngData(imageToCache){
                            try pngImageData.write(to: filePath, options: .atomic)
                        }
                    } catch{
                        print("Couldn't write image to filePath \(filePath)")
                    }
                }
            }

        }
    }

}


