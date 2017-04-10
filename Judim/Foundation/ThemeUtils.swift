//
//  ThemeUtils.swift
//  Judim
//
//  Created by Plutonist on 2017/4/2.
//  Copyright © 2017年 Plutonist. All rights reserved.
//

import UIKit

class ThemeUtils {
    static func ApplyGradient(view: UIView) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [THEME_GRADIENT_LEFT_TOP_COLOR.cgColor, THEME_GRADIENT_RIGHT_BOTTOM_COLOR.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.1)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
}

