//
//  BaseViewController.swift
//  Judim
//
//  Created by Plutonist on 2017/4/2.
//  Copyright © 2017年 Plutonist. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(icon: PLIcon) {
        super.init(nibName: nil, bundle: nil)
        tabBarItem = UITabBarItem(title: "", image: icon.color(THEME_COLOR).done(), selectedImage: nil)
    }
    
    override func viewDidLoad() {
        self.render(root: PLUi<UIView>(view: view))
    }
    
    func render(root: PLUi<UIView>) {}
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class BaseTableViewCell : UITableViewCell {
    
    var isRendered = false;
    
    func renderView() {
        if !isRendered {
            render(root: PLUi<UIView>(view: self.contentView))
            isRendered = true
        }
    }
    
    func render(root: PLUi<UIView>) {}
    
}

class BaseCollectionViewCell : UICollectionViewCell {
    
    var isRendered = false;
    
    func renderView() {
        if !isRendered {
            render(root: PLUi<UIView>(view: self.contentView))
            isRendered = true
        }
    }
    
    func render(root: PLUi<UIView>) {}
    
}
