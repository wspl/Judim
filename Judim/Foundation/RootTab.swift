//
//  RootTab.swift
//  Judim
//
//  Created by Plutonist on 2017/4/2.
//  Copyright © 2017年 Plutonist. All rights reserved.
//

import UIKit

class RootTab : UITabBarController {
    
    static let sharedInstance = RootTab()
    
    override func viewDidLoad() {
        tabBar.isTranslucent = false
        tabBar.tintColor = THEME_COLOR
        
        viewControllers = [
            SiteViewController(icon: PLIcon.FontAwesome.size(22).offset(x: 0, y: 5).char("\u{f06e}"))
        ]
    }
    
}
