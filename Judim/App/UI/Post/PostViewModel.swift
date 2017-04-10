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
    var post: Post
    
    var pictures = Variable<[PostPicture]>([])
    let picturesDataSource = RxCollectionViewSectionedReloadDataSource<PicturesSection>()
    
    var pictureSection: Driver<[PicturesSection]> {
        return pictures.asObservable()
            .map { [PicturesSection(model: "", items: $0)] }
            .asDriver(onErrorJustReturn: [])
    }
    
    var refresh = PublishSubject<PLRefreshLoadMoreEvent>()
    
    init(post: Post) {
        self.post = post
    }
    
    func reload() {
        async {
            try await(self.post.initPictures())
            self.pictures.value = Array(self.post.pictures)
            self.refresh.onNext(.reloadFinished)
        }.catch { err in
            self.refresh.onError(err)
            print(err)
        }
    }
}