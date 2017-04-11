//
//  Post.swift
//  Judim
//
//  Created by Plutonist on 2017/4/2.
//  Copyright © 2017年 Plutonist. All rights reserved.
//

import RealmSwift
import Hydra
import SwiftyJSON
import SwiftSoup

class Post: Object {
    dynamic var site: Site?
    
    dynamic var url: String = ""
    // Info
    dynamic var idCode: String = ""
    dynamic var title: String = ""
    dynamic var cover: String = ""
    dynamic var by: String = ""
    dynamic var date: String = ""
    let tags = List<PostTag>()
    // Media
    let pictures = List<PostPicture>()
    
    // Status
    dynamic var lastFetchedTo: Int = -1
    var hasNextPage: Bool { return lastFetchedTo != -2 }
    
    // Params for flag
    dynamic var repeatedThumbnailCalced = false
    dynamic var thumbnailsPerPicture: Int = 0
    dynamic var thumbnailRealWidth: Int = 0

    
    func firstPage() -> Int? {
        return Int(self.site!.json["galleryUrl"].stringValue.fmt.get(key: "page") ?? "")
    }
    
    func initPictures() -> Promise<()> {
        return async {
            self.pictures.removeAll()
            let pics = try await(self.getPicturesBy(page: self.firstPage()))
            self.lastFetchedTo = self.firstPage() ?? -2
            self.pictures.append(objectsIn: pics)
        }
    }
    
    func nextPictures() -> Promise<()> {
        return async {
            guard self.lastFetchedTo != -2 else { return }
            self.lastFetchedTo += 1
            let pics = try await(self.getPicturesBy(page: self.lastFetchedTo))
            let repeated = pics.filter { pic in
                self.pictures.filter { hadPic in
                    hadPic.url == pic.url
                }.count > 0
            }
            
            if repeated.isEmpty {
                self.pictures.append(objectsIn: pics)
            } else {
                self.lastFetchedTo = -2
            }
        }
    }
    
    func preload() throws -> Promise<()> {
        return async {
            let postUrl = self.url.fmt
                .set(key: "page", value: String(self.firstPage() ?? 0))
                .url
            
            let galleryRule = self.site!.json["galleryRule"]
            let html = try await(PLFetcher().method(.get).url(postUrl).html)
            let doc = try SwiftSoup.parse(html)
            let fieldsMap = [
                "title": "title",
                "cover": "cover",
                "by": "uploader",
                "date": "datetime",
            ]
            for (fieldNative, fieldJson) in fieldsMap {
                if galleryRule[fieldJson].exists() {
                    var value = Selector(json: galleryRule[fieldJson]).Invoke(input: doc)
                    if fieldNative == "cover" {
                        value = value.fmt.base(on: self.url)
                    }
                    self.setValue(value, forKey: fieldNative)
                }
            }
        }
    }
    
    func getPicturesBy(page: Int?) throws -> Promise<List<PostPicture>> {
        return async {
            let postUrl = self.url.fmt
                .set(key: "page", value: String(page ?? 0))
                .url
            
            let galleryRule = self.site!.json["galleryRule"]
            var pictureRule = galleryRule["pictureRule"]
            let extraRule: JSON = self.site!.json["extraRule"]
            
            var html = try await(PLFetcher().method(.get).url(postUrl).html)
            if self.site!.flags.has("secondLevelGallery") {
                let nlUrl = Selector(json: pictureRule["url"]).Invoke(input: try SwiftSoup.parse(html))
                pictureRule = extraRule["pictureRule"]
                html = try await(PLFetcher().method(.get).url(nlUrl).html)
            }
            
            let doc = try SwiftSoup.parse(html)
            let itemSelector = pictureRule["item"]["selector"].stringValue
            let pictures = List<PostPicture>()
            try doc.select(itemSelector).forEach { element in
                let thumbnail = Selector(json: pictureRule["thumbnail"]).Invoke(input: element).fmt.base(on: self.url)
                let url = Selector(json: pictureRule["url"]).Invoke(input: element).fmt.base(on: self.url)
 
                pictures.append(PostPicture(value: [
                    "post": self,
                    "site": self.site!,
                    "thumbnail": thumbnail,
                    "url": url
                ]))
            }
            return pictures
        }
    }
}
