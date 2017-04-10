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

class PictureViewController: UIViewController {
    var index: Int
    
    var scrollView: UIScrollView!
    var pictureView: UIImageView!
    private var _picture: PostPicture?
    
    var picture: PostPicture? {
        get { return _picture }
        set(value) {
            async {
                self._picture = value
                //let overlay = OverlayImageProcessor(overlay: .white, fraction: 0.5)
                //self.pictureView.kf.setImage(with: URL(string: self.picture!.thumbnail), options: [.processor(overlay)])
                let thumbnail = try await(PLImageFetcher().url(self.picture!.thumbnail).downloadImage())
                self.pictureView.image = thumbnail
                
                let blurFilter = GaussianBlur()
                blurFilter.blurRadiusInPixels = 20
                self.pictureView.image = thumbnail!.filterWithOperation(blurFilter)
                //print("no xxx?")
                
                try await(self.picture!.preload())
                var prevProgress: Double = 0
                self.pictureView.pil.url(self.picture!.url).progress{ percent in
                    if percent - prevProgress >= 0.1 {
                        print(percent)
                        let blurFilter = GaussianBlur()
                        blurFilter.blurRadiusInPixels = Float(20.0 * (1.0 - percent))
                        self.pictureView.image = thumbnail!.filterWithOperation(blurFilter)
                    }
                    prevProgress = percent
                }.show()
                //self.pictureView.kf.setImage(with: URL(string: self.picture!.url))
            }.then{}
            //
        }
    }

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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
