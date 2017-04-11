//
//  PostViewModel.swift
//  Judim
//
//  Created by Plutonist on 2017/4/7.
//  Copyright © 2017年 Plutonist. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import Hydra

typealias PicturesSection = SectionModel<String, PostPicture>

class PostViewModel {
    var post = Variable<Post>(Post())
    
    var pictures = Variable<[PostPicture]>([])
    let picturesDataSource = RxCollectionViewSectionedReloadDataSource<PicturesSection>()
    
    var pictureSection: Driver<[PicturesSection]> {
        return pictures.asObservable()
            .map { [PicturesSection(model: "", items: $0)] }
            .asDriver(onErrorJustReturn: [])
    }
    
    var refresh = PublishSubject<PLRefreshEvent>()
    var loadMore = PublishSubject<PLLoadMoreEvent>()
    
    init(post: Post) {
        self.post.value = post
    }
    
    func reload() {
        async {
            try await(self.post.value.initPictures())
            self.pictures.value = Array(self.post.value.pictures)
            self.refresh.onNext(.reloadFinished)
        }.catch { err in
            self.refresh.onError(err)
            print(err)
        }
    }
    
    func restore() {
        async {
            self.pictures.value.removeAll()
            if self.post.value.pictures.isEmpty {
                try await(self.post.value.initPictures())
            }
            self.pictures.value = Array(self.post.value.pictures)
            self.refresh.onNext(.reloadFinished)
        }.catch { err in
            self.refresh.onError(err)
            print(err)
        }
    }
    
    func more() {
        async {
            try await(self.post.value.nextPictures())
            self.pictures.value = Array(self.post.value.pictures)
            self.loadMore.onNext(.loadMoreFinished)
        }.catch { err in
            self.loadMore.onError(err)
            print(err)
        }
    }
}
