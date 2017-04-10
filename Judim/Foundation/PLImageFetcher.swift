//
//  PLImageFetcher.swift
//  Judim
//
//  Created by Plutonist on 2017/4/9.
//  Copyright © 2017年 Plutonist. All rights reserved.
//

import UIKit
import Hydra
import RealmSwift

extension UIImageView {
    var pil: PLImageFetcher { return PLImageFetcher(imageView: self) }
}


class ImageCached: Object {
    dynamic var url: String = ""
    dynamic var data = NSData()
}

fileprivate let cacheUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]

fileprivate let imageCacheConfig = Realm.Configuration(
    fileURL: cacheUrl.appendingPathComponent("judim_cache.realm")
)

//fileprivate let realm = try! Realm(configuration: imageCacheConfig)


fileprivate class ImageCache {
    subscript(url: String) -> Data? {
        get {
            let realm = try! Realm(configuration: imageCacheConfig)
            for cache in realm.objects(ImageCached.self) {
                if cache.url == url {
                    return Data(referencing: cache.data)
                }
            }
            return nil
        }
        set(value) {
            let realm = try! Realm(configuration: imageCacheConfig)
            realm.objects(ImageCached.self).forEach { cache in
                if cache.url == url {
                    realm.delete(cache)
                }
            }
            if value != nil {
                let cache = ImageCached(value: [
                    "url": url,
                    "data": value!,
                ])
                try! realm.write {
                    realm.add(cache)
                }
            }
        }
    }
}

fileprivate let imageCache = ImageCache()

class PLImageFetcher: PLFetcher {
    var imageView: UIImageView?
    
    init(imageView: UIImageView) {
        self.imageView = imageView
    }
    
    override init() {
        super.init()
    }
    
    override func url(_ url: String) -> PLImageFetcher {
        _ = super.url(url)
        return self
    }
    
    override func progress(_ prg: @escaping (Double) -> ()) -> PLImageFetcher {
        _ = super.progress(prg)
        return self
    }
    
    func downloadImage() -> Promise<UIImage?> {
        return async {
            var image: UIImage?
            if let cache = imageCache[self.url] {
                image = UIImage(data: cache)
            } else {
                let data = try await(self.download)
                imageCache[self.url] = data
                image = UIImage(data: data)
            }
            return image
        }
    }
    
    func show() -> Promise<(image: UIImage?, alive: Bool)> {
        return async {
            do {
                let currentUrl = self.url
                let image = try await(self.downloadImage())
                
                var alive = false
                if currentUrl == self.url {
                    DispatchQueue.main.async {
                        self.imageView?.image = image
                    }
                    alive = true
                }
                return Promise(resolved: (image: image, alive: alive))
            } catch {
                print(error.localizedDescription)
                return Promise(rejected: error)
            }
        }.then{ result in result }
    }
}
