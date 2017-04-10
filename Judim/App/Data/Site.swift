//
//  Site.swift
//  Judim
//
//  Created by Plutonist on 2017/4/2.
//  Copyright © 2017年 Plutonist. All rights reserved.
//

import RealmSwift
import SwiftyJSON
import SwiftSoup
import Hydra

class Site: Object {
    dynamic var rule: String = ""
    dynamic var name: String = ""
    let posts = List<Post>()
    // Status
    dynamic var lastFetchedTo: Int = -1
    var hasNextPage: Bool { return lastFetchedTo != -2 }
    
    lazy var json: JSON = JSON(parseJSON: self.rule)
    lazy var flags: SiteFlags = SiteFlags(parse: self.json["flag"].stringValue)
    lazy var isSupported: Bool = self.flags.isSupported

    static func from(name: String, rule: String) -> Site {
        return Site(value: [
            "name": name,
            "rule": rule
        ])
    }

    func firstPage() -> Int? {
        return Int(self.json["indexUrl"].stringValue.fmt.get(key: "page") ?? "")
    }
    
    func initPosts() -> Promise<()> {
        return async {
            self.posts.removeAll()
            let posts = try await(self.getPostBy(page: self.firstPage()))
            self.lastFetchedTo = self.firstPage() ?? -2
            self.posts.append(objectsIn: posts)
        }
    }
    
    func nextPosts() -> Promise<()> {
        return async {
            self.lastFetchedTo += 1
            let posts = try await(self.getPostBy(page: self.lastFetchedTo))
            self.posts.append(objectsIn: posts)
        }
    }
    
    func getPostBy(page: Int?) -> Promise<List<Post>> {
        return async {
            let indexUrl = self.json["indexUrl"].stringValue.fmt
                .set(key: "page", value: String(page ?? 0))
                .url
            
            let html = try await(PLFetcher().method(.get).url(indexUrl).html)
            let indexRule = self.json["indexRule"]
            let doc = try SwiftSoup.parse(html)
            
            let posts = List<Post>()
            
            try doc.select(indexRule["item"]["selector"].stringValue).forEach { element in
                var fieldsMap = [
                    "idCode": "idCode",
                    "title": "title",
                    "cover": "cover",
                    "by": "uploader",
                    "date": "datetime",
                ]
                let post = Post(value: ["site": self])
                
                for (fieldNative, fieldJson) in fieldsMap {
                    if indexRule[fieldJson].exists() {
                        let value = Selector(json: indexRule[fieldJson]).Invoke(input: element)
                        post.setValue(value, forKey: fieldNative)
                        fieldsMap.removeValue(forKey: fieldNative)
                    }
                }
                let url = self.json["galleryUrl"].stringValue.fmt.set(key: "idCode", value: post.idCode).url
                post.setValue(url, forKey: "url")
//                
//                if fieldsMap.count > 0 {
//                    let preloadedHtml = try await(Fetcher.get(url.fmt.restore(key: "page").url).string)
//                    let doc = try SwiftSoup.parse(preloadedHtml)
//                    for (fieldNative, fieldJson) in fieldsMap {
//                        let value = Selector(json: self.json["galleryUrl"][fieldJson]).Invoke(input: doc)
//                        post.setValue(value, forKey: fieldNative)
//                    }
//                }

                posts.append(post)
            }
            return posts
        }
    }
}
