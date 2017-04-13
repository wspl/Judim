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
            _ = root.put(UIBackView()) { node, this in
                this.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pressBack)))
                this.snp.makeConstraints { make in
                    make.left.equalTo(this.superview!).offset(-5)
                    make.top.equalTo(this.superview!)
                    make.bottom.equalTo(this.superview!)
                    make.width.equalTo(this.snp.height)
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
    
    func pressBack() {
        RootNav.sharedInstance.popViewController(animated: true)
    }
}

class UIBackView: UIImageView {
    init() {
        super.init(frame: CGRect.zero)
        contentMode = .center
        image = PLIcon.FontAwesome.size(25).color(.white).char("\u{f104}").done()
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        alpha = 0.6
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        alpha = 1
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        alpha = 1
    }
}
