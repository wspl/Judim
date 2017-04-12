//
//  PictureCell.swift
//  Judim
//
//  Created by Plutonist on 2017/4/7.
//  Copyright © 2017年 Plutonist. All rights reserved.
//

import UIKit
import Kingfisher

class PictureCell: BaseCollectionViewCell {
    
    var picture: PostPicture!
    var pictureView: UIImageView!
    
    override func render(root: PLUi<UIView>) {
        pictureView = root.put(UIImageView()) { node, this in
            this.backgroundColor = THEME_PLACEHOLDER_COLOR
            this.contentMode = .scaleAspectFit
            this.snp.makeConstraints { make in
                make.edges.equalTo(this.superview!)
            }
        }
    }
    
    var repeatedThumbnailCalced: Bool {
        get { return picture.post!.repeatedThumbnailCalced }
        set(value) {
            picture.post!.repeatedThumbnailCalced = value
        }
    }
    var thumbnailsPerPicture: CGFloat {
        get { return CGFloat(picture.post!.thumbnailsPerPicture) }
        set(value) {
            picture.post!.thumbnailsPerPicture = Int(value)
        }
    }
    var realWidth: CGFloat {
        get { return CGFloat(picture.post!.thumbnailRealWidth) }
        set(value) {
            picture.post!.thumbnailRealWidth = Int(value)
        }
    }
    
    func adjustRepeatedThumbnail(image: Image) {

        if !repeatedThumbnailCalced {
            thumbnailsPerPicture = CGFloat(picture.post!.pictures
                .filter { $0.thumbnail == self.picture.thumbnail }
                .count)
            realWidth = image.size.width / thumbnailsPerPicture
            repeatedThumbnailCalced = true
        }
        
        var index: CGFloat = 0

        let picBundle = picture.post!.pictures
            .filter { $0.thumbnail == self.picture.thumbnail }
        
        for pic in picBundle {
            if pic == self.picture {
                break
            }
            index += 1
        }
        
        let image = image.cgImage?.cropping(to: CGRect(
            x: CGFloat(index) * realWidth,
            y: 0,
            width: realWidth,
            height: image.size.height))

        if image != nil {
            pictureView.image = UIImage(cgImage: image!)
        }
    }
    
    func configure(picture: PostPicture) {
        if self.picture == nil || self.picture.url != picture.url {
            print("reload: ", self.picture == nil ? "nil" : self.picture.url, "to", picture.url)
            renderView()
            
            pictureView.image = nil
            self.picture = picture

            pictureView.pil.url(picture.thumbnail).show().then { image, alive in
                if image != nil && alive {
                    if self.picture.site!.flags.has("repeatedThumbnail") {
                        if image != nil {
                            self.adjustRepeatedThumbnail(image: image!)
                        }
                    }
                }
            }
        }
    }
}
