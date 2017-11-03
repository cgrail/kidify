//
//  ImageDownloader.swift
//  kidify
//
//  Created by Grail, Christian on 03.11.17.
//  Copyright © 2017 Grail. All rights reserved.
//

import Foundation

class ImageDownloader {
    
    
    func downloadImage(_ url: URL, completeHandler: @escaping (_ image: UIImage) -> Void) {
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                if let uiImage = UIImage(data: data) {
                    completeHandler(uiImage)
                }
            }
        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
}
