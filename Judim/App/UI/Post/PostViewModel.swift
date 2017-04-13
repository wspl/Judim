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
import Hydra

class PostViewModel {
    var post = Variable<Post>(Post())

    var loadPublisher = PublishSubject<PLLoadEvent>()
    
    init(post: Post) {
        self.post.value = post
    }
    
    func reload() {
        async {
            try await(self.post.value.initPictures())
            self.loadPublisher.onNext(.refreshFinished)
        }.catch { err in
            self.loadPublisher.onNext(.refreshFailed)
            self.loadPublisher.onError(err)
        }
    }
    
    func restore() {
        async {
            if self.post.value.pictures.isEmpty {
                try await(self.post.value.initPictures())
            }
            self.loadPublisher.onNext(.refreshFinished)
        }.catch { err in
            self.loadPublisher.onNext(.refreshFailed)
            self.loadPublisher.onError(err)
        }
    }
    
    func more() {
        async {
            print("start more..")
            try await(self.post.value.nextPictures())
            self.loadPublisher.onNext(.loadMoreFinished)
        }.catch { err in
            self.loadPublisher.onNext(.loadMoreFailed)
            self.loadPublisher.onError(err)
        }
    }
}
