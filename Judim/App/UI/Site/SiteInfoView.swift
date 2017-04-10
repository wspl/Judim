//
//  SiteInfoView.swift
//  Judim
//
//  Created by Plutonist on 2017/4/5.
//  Copyright © 2017年 Plutonist. All rights reserved.
//

import UIKit

class SiteInfoView: UIView {
    var indicator: UIView!
    var nameLabel: UILabel!
    
    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = .white
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        
        let root = PLUi(view: self)
        
        indicator = root.put(UIView()) { node, this in
            this.backgroundColor = THEME_COLOR
            
            this.snp.makeConstraints { make in
                make.top.equalTo(self).offset(10)
                make.left.equalTo(self)
                make.width.equalTo(4)
                make.height.equalTo(28)
            }
        }
        
        nameLabel = root.put(UILabel()) { node, this in
            this.textColor = THEME_TEXT_REGULAR_COLOR
            this.text = "站点名称"
            this.font = this.font.withSize(16)
            this.snp.makeConstraints { make in
                make.top.equalTo(self).offset(10)
                make.left.equalTo(self).offset(15)
                make.height.equalTo(28)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
