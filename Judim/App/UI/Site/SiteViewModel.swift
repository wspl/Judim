//
//  SiteViewModel.swift
//  Judim
//
//  Created by Plutonist on 2017/4/3.
//  Copyright © 2017年 Plutonist. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Hydra

struct SiteViewModel {
    var site: Site

    var posts = Variable<[Post]>([])

    var loadPublisher = PublishSubject<PLLoadEvent>()

    init() {
        let rule = try! await(PLFetcher().method(.get).url("https://raw.githubusercontent.com/H-Viewer-Sites/Index/master/sites/g.e-hentai.txt").html)
        site = Site.from(name: "EH", rule: rule)
    }
    
    func reload() {
        async {
            try await(self.site.initPosts())
            self.posts.value = Array(self.site.posts)
            self.loadPublisher.onNext(.refreshFinished)
        }.catch { err in
            self.loadPublisher.onNext(.refreshFailed)
            self.loadPublisher.onError(err)
        }
    }
    
    func more() {
        async {
            try await(self.site.nextPosts())
            self.posts.value = Array(self.site.posts)
            self.loadPublisher.onNext(.loadMoreFinished)
        }.catch { err in
            self.loadPublisher.onNext(.loadMoreFailed)
            self.loadPublisher.onError(err)
        }
    }
}
