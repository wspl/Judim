//
//  PLNavBar.swift
//  Judim
//
//  Created by Plutonist on 2017/4/3.
//  Copyright © 2017年 Plutonist. All rights reserved.
//

import UIKit

class PLNavBarIcon {
    let image: UIImage
    let closure: () -> ()
    
    init(_ image: UIImage, closure: @escaping () -> ()) {
        self.image = image
        self.closure = closure
    }
}

class PLNavBar: UIView {
    var title = ""
    var icons = [PLNavBarIcon]()
    var iconViews = [UIView]()
    var isWithBack = false
    
    func title(_ title: String) -> PLNavBar {
        self.title = title
        return self
    }
    
    func addIcon(_ icon: PLNavBarIcon) -> PLNavBar {
        self.icons.append(icon)
        return self
    }
    
    func withBack() -> PLNavBar {
        isWithBack = true
        return self
    }
    
    func done() -> PLNavBar {
        let root = PLUi(view: self)
        
        if isWithBack {
            _ = root.put(UIImageView()) { node, this in
                this.image = PLIcon.FontAwesome.size(25).color(.white).char("\u{f104}").done()
                this.snp.makeConstraints { make in
                    make.centerY.equalTo(this.superview!)
                    make.left.equalTo(this.superview!).offset(15)
                }
            }
        }
        
        _ = root.put(UILabel()) { node, this in
            this.text = title
            this.textColor = THEME_TEXT_WHITE
            this.font = this.font.withSize(17)
            this.snp.makeConstraints { make in
                make.center.equalTo(this.superview!)
            }
        }
        
        return self
    }
}
