//
//  PictureViewController.swift
//  Judim
//
//  Created by Plutonist on 2017/4/8.
//  Copyright © 2017年 Plutonist. All rights reserved.
//

import UIKit
import Hydra
import Kingfisher
import EVGPUImage2
import RxSwift
import RxCocoa

class PictureViewController: UIViewController {
    var index: Int
    
    var scrollView: UIScrollView!
    var pictureView: UIImageView!

//    var ___picture: PostPicture? {
//        get { return _picture }
//        set(value) {
//            async {
//                self._picture = value
//
//                let thumbnail = try await(PLImageFetcher().url(self.picture!.thumbnail).downloadImage())
//                self.pictureView.image = thumbnail
//                
//                // Slowly on simulator
////                let blurFilter = GaussianBlur()
////                blurFilter.blurRadiusInPixels = 20
////                self.pictureView.image = thumbnail!.filterWithOperation(blurFilter)
//
//                try await(self.picture!.preload())
//                var prevProgress: Double = 0
//                
//                self.pictureView.pil.url(self.picture!.url)
////                .progress{ percent in
////                    if percent - prevProgress >= 0.1 {
////                        print(percent)
////                        let blurFilter = GaussianBlur()
////                        blurFilter.blurRadiusInPixels = Float(20.0 * (1.0 - percent))
////                        self.pictureView.image = thumbnail!.filterWithOperation(blurFilter)
////                    }
////                    prevProgress = percent
////                }
//                .show()
//            }.then{}
//            //
//        }
//    }

    init(index: Int) {
        self.index = index
        super.init(nibName: nil, bundle: nil)
        
        scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        pictureView = UIImageView()
        scrollView.addSubview(pictureView)
        pictureView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        pictureView.contentMode = .scaleAspectFit
        
    }
    
    var currentPicture: PostPicture?
    func configure(picture: PostPicture) {
        guard currentPicture != picture else { return }
        currentPicture = picture
        
        async {
            ImageCache.default.retrieveImage(forKey: "sp-thumbnail#!" + picture.url, options: nil) { image, cacheType in
                if let image = image {
                    //DispatchQueue.main.sync {
                    self.pictureView.image = image
                    //}
                } else {
                    ImageCache.default.retrieveImage(forKey: picture.thumbnail, options: nil) { image, cacheType in
                        self.pictureView.image = image
                    }
                }
            }
            
            try await(picture.preload())
            let res = URL(string: picture.url)
            self.pictureView.kf.setImage(with: res)
            //let thumbnail = try await(PLImageFetcher().url(picture.thumbnail).downloadImage())
            //DispatchQueue.main.sync {
            //    self.pictureView.image = thumbnail
            //}
            //try await(picture.preload())
            //self.pictureView.pil.url(picture.url).show()
        }.catch{ err in
            print(err.localizedDescription)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
