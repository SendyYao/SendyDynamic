//
//  ImageLoader.swift
//  SendyDynamic
//
//  Created by XuYao on 2025/12/18.
//

import Foundation
import UIKit

class ImageLoader: ObservableObject {
    private let maxConcurrentRequestes = 10
    private var currentRequests = 0
    
    func loadImage(url: URL, completion: @escaping (UIImage?) -> Void) {
        guard currentRequests < maxConcurrentRequestes else { return }
        
        currentRequests += 1
        URLSession.shared.dataTask(with: url) { data, response, error in
            defer { self.currentRequests -= 1 }
            guard let data = data, let imgae = UIImage(data: data) else {
                completion(nil)
                return
            }
            completion(imgae)
        }.resume()
    }
}

class ImageCache {
    static let shared = ImageCache()
    private var cache = NSCache<NSURL, UIImage>()
    
    init() {
        clearCache()
    }
    
    func getImage(for url: URL) -> UIImage? {
        return cache.object(forKey: url as NSURL)
    }
    
    func setImage(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url as NSURL)
    }
    
    func clearCache() {
        cache.removeAllObjects()
        print("Image cache cleared!")
    }
}
