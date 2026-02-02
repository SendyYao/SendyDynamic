//
//  ImageLoader.swift
//  SendyDynamic
//
//  Created by XuYao on 2025/12/18.
//

import Foundation
import UIKit

final class ImageLoaderOP {
    
    static let shared = ImageLoaderOP()
    
    private let queue = DispatchQueue(label: "image.loader.queue")
    private let maxConcurrent = 4
    
    private var running = 0
    private var pending: [URL] = []
    
    private var inFlight: [URL: [(UIImage?) -> Void]] = [:]
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.httpMaximumConnectionsPerHost = 4
        config.waitsForConnectivity = false
        return URLSession(configuration: config)
    }()
    
    func loadImage(url: URL, completion: @escaping (UIImage?) -> Void) {
        queue.async {
            // Merge request
            if self.inFlight[url] != nil {
                self.inFlight[url]?.append(completion)
                return
            }
            
            self.inFlight[url] = [completion]
            self.pending.append(url)
            self.shedule()
        }
    }
    
    func loadLocalImage(named name: String) -> UIImage? {
        guard let url = Bundle.main.url(forResource: name, withExtension: nil) else {
            return nil
        }
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        return UIImage(data: data)
    }
    
    private func shedule() {
        guard running < maxConcurrent, !pending.isEmpty else { return }
        
        let url = pending.removeFirst()
        running += 1
        
        session.dataTask(with: url) { data, _, _ in
            let image = data.flatMap(UIImage.init)
            
            self.queue.async {
                let callbacks = self.inFlight.removeValue(forKey: url) ?? []
                self.running -= 1
                callbacks.forEach { $0(image) }
                self.shedule()
            }
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
