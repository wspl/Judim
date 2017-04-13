//
//  PostCell.swift
//  Judim
//
//  Created by Plutonist on 2017/4/4.
//  Copyright © 2017年 Plutonist. All rights reserved.
//

import UIKit
import Kingfisher
import Hydra
import EVGPUImage2

class PostCell: BaseTableViewCell {
    
    var post: Post!
    
    var coverImageBlur: UIImageView!
    var coverImage: UIImageView!
    var titleLabel: UILabel!
    var byLabel: UILabel!
    var dateLabel: UILabel!
    
    override func render(root: PLUi<UIView>) {
        
        coverImageBlur = root.put(UIImageView()) { node, this in
            this.layer.cornerRadius = 10
            this.backgroundColor = THEME_PLACEHOLDER_COLOR
            this.contentMode = .scaleAspectFill
            this.clipsToBounds = true

            this.snp.makeConstraints { make in
                make.top.equalTo(this.superview!).offset(10)
                make.left.equalTo(this.superview!).offset(25)
                make.size.equalTo(80)
            }
//            
//            _ = node.put(UIVisualEffectView(effect: UIBlurEffect(style: .regular))) { node, this in
//                this.snp.makeConstraints { make in
//                    make.edges.equalTo(this.superview!)
//                }
//            }
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
            this.font = this.font.withSize(14)
            this.textColor = THEME_TEXT_REGULAR_COLOR
            this.lineBreakMode = .byWordWrapping
            this.numberOfLines = 2
            
            this.snp.makeConstraints { make in
                make.left.equalTo(coverImage.snp.right).offset(12)
                make.top.equalTo(coverImage).offset(10)
                make.right.equalTo(this.superview!).offset(-25)
            }
        }
        
        byLabel = root.put(UILabel()) { node, this in
            this.font = this.font.withSize(13)
            this.textColor = THEME_TEXT_LIGHT_COLOR
            
            this.snp.makeConstraints { make in
                make.left.equalTo(titleLabel)
                make.bottom.equalTo(coverImage).offset(-10)
            }
        }
        
        dateLabel = root.put(UILabel()) { node, this in
            this.font = this.font.withSize(13)
            this.textColor = THEME_TEXT_LIGHT_COLOR
            
            this.snp.makeConstraints { make in
                make.right.equalTo(titleLabel)
                make.bottom.equalTo(byLabel)
            }
        }
    }
    
    func configure(post: Post) {
        if self.post == nil || self.post.url != post.url {
            renderView()

            self.post = post
            
            let initialPost = post
            
            coverImage.image = nil
            coverImageBlur.image = nil
            
            titleLabel.text = post.title
            byLabel.text = post.by
            dateLabel.text = post.date
            
            async {
                if post.cover.isEmpty {
                    try await(post.preload())
                    if self.post !== initialPost {
                        return
                    }
                }
                
                let res = URL(string: post.cover)
                self.coverImage.kf.setImage(with: res) { image, error, cacheType, imageUrl in
                    ImageCache.default.retrieveImage(forKey: "blur#!" + post.cover, options: nil) { blurredImage, cacheType in
                        if let blurredImage = blurredImage {
                            self.coverImageBlur.image = blurredImage
                        } else {
                            let blurFilter = GaussianBlur()
                            blurFilter.blurRadiusInPixels = 20
                            self.coverImageBlur.image = image!.filterWithOperation(blurFilter)
                            ImageCache.default.store(self.coverImageBlur.image!, forKey: "blur#!" + post.cover)
                        }
                    }
                }
                
                
//
//                self.coverImage.pil.url(post.cover).show().then { image, alive in
//                    if image != nil && alive {
//                        let blurFilter = GaussianBlur()
//                        blurFilter.blurRadiusInPixels = 20
//                        self.coverImageBlur.image = image!.filterWithOperation(blurFilter)
//                    }
//                }
            }.then{}
        }
    }
}

