//
//  PostInfoView.swift
//  Judim
//
//  Created by Plutonist on 2017/4/7.
//  Copyright © 2017年 Plutonist. All rights reserved.
//

import UIKit
import Kingfisher
import EVGPUImage2
import RxCocoa
import RxSwift

class PostInfoView: UIView {
    var coverImageBlur: UIImageView!
    var coverImage: UIImageView!
    var titleLabel: UILabel!
    var byLabel: UILabel!
    var dateLabel: UILabel!
    
    let disposeBag = DisposeBag()
    
    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = .white
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        
        let root = PLUi(view: self)
        coverImageBlur = root.put(UIImageView()) { node, this in
            this.layer.cornerRadius = 10
            this.backgroundColor = THEME_PLACEHOLDER_COLOR
            this.contentMode = .scaleAspectFill
            this.clipsToBounds = true
            this.snp.makeConstraints { make in
                make.top.equalTo(this.superview!).offset(15)
                make.left.equalTo(this.superview!).offset(15)
                make.size.equalTo(120)
            }
        }
        
        coverImage = root.put(UIImageView()) { node, this in
            this.layer.cornerRadius = 10
            this.backgroundColor = .clear
            this.contentMode = .scaleAspectFit
            this.clipsToBounds = true
            this.snp.makeConstraints { make in
                make.edges.equalTo(coverImageBlur)
            }
        }
        
        titleLabel = root.put(UILabel()) { node, this in
            this.text = "画册标题"
            this.textColor = THEME_TEXT_REGULAR_COLOR
            this.font = this.font.withSize(14)
            this.lineBreakMode = .byWordWrapping
            this.numberOfLines = 2
            this.snp.makeConstraints { make in
                make.left.equalTo(coverImage.snp.right).offset(12)
                make.top.equalTo(coverImage).offset(10)
                make.right.equalTo(this.superview!).offset(-25)
            }
        }
        
        dateLabel = root.put(UILabel()) { node, this in
            this.text = "1970-01-01"
            this.textColor = THEME_TEXT_LIGHT_COLOR
            this.font = this.font.withSize(12)
            this.snp.makeConstraints { make in
                make.left.equalTo(titleLabel)
                make.right.equalTo(titleLabel)
                make.bottom.equalTo(coverImage).offset(-10)
            }
        }
        
        byLabel = root.put(UILabel()) { node, this in
            this.text = "Uploader"
            this.textColor = THEME_TEXT_LIGHT_COLOR
            this.font = this.font.withSize(12)
            this.snp.makeConstraints { make in
                make.left.equalTo(titleLabel)
                make.right.equalTo(titleLabel)
                make.bottom.equalTo(dateLabel.snp.top).offset(-5)
            }
        }
    }
    
    func configure(post: Variable<Post>) {
        titleLabel.text = post.value.title
        dateLabel.text = post.value.date
        byLabel.text = post.value.by
        
        post.asObservable().subscribe(onNext: { post in
            guard !post.cover.isEmpty else { return }
            let res = URL(string: post.cover)
            self.coverImage.kf.setImage(with: res) { image, error, cacheType, imageUrl in
                ImageCache.default.retrieveImage(forKey: "blur#!" + post.cover, options: nil) { image, cacheType in
                    if let image = image {
                        self.coverImageBlur.image = image
                    } else {
                        let blurFilter = GaussianBlur()
                        blurFilter.blurRadiusInPixels = 20
                        self.coverImageBlur.image = image!.filterWithOperation(blurFilter)
                        ImageCache.default.store(self.coverImageBlur.image!, forKey: "blur#!" + post.cover)
                    }
                }
            }
        }).addDisposableTo(disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
