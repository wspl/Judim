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
import RxDataSources
import Hydra

typealias PostSection = SectionModel<String, Post>

struct SiteViewModel {
    var site: Site

    var posts = Variable<[Post]>([])
    let postsDataSource = RxTableViewSectionedReloadDataSource<PostSection>()

    var postSection: Driver<[PostSection]> {
        return posts.asObservable()
            .map { [PostSection(model: "", items: $0)] }
            .asDriver(onErrorJustReturn: [])
    }
    
    var refresh = PublishSubject<PLRefreshLoadMoreEvent>()

    init() {
        let rule = try! await(PLFetcher().method(.get).url("https://raw.githubusercontent.com/H-Viewer-Sites/Index/master/sites/Konachan.Pool.txt").html)
        site = Site.from(name: "EH", rule: rule)
    }
    
    func reload() {
        async {
            try await(self.site.initPosts())
            self.posts.value = Array(self.site.posts)
            self.refresh.onNext(.reloadFinished)
        }.catch { err in
            self.refresh.onError(err)
            print(err)
        }
    }
}
