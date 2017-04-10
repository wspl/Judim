//
//  PostPicture.swift
//  Judim
//
//  Created by Plutonist on 2017/4/2.
//  Copyright © 2017年 Plutonist. All rights reserved.
//

import RealmSwift
import Hydra
import SwiftSoup

class PostPicture: Object {
    dynamic var post: Post?
    dynamic var site: Site?

    dynamic var thumbnail: String = ""
    dynamic var url: String = ""
    
    func preload() -> Promise<()> {
        return async {
            if self.site!.flags.has("singlePageBigPicture") {
                let html = try await(PLFetcher().method(.get).url(self.url).html)
                let doc = try SwiftSoup.parse(html)
                
                let urlSelector = self.site!.json["extraRule"]["pictureRule"]["url"]
                let url = Selector(json: urlSelector).Invoke(input: doc).fmt.base(on: self.url)
                self.url = url
            }
        }
    }
}
