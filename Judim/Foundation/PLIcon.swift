//
//  PLIcon.swift
//  Judim
//
//  Created by Plutonist on 2017/4/2.
//  Copyright © 2017年 Plutonist. All rights reserved.
//

import UIKit

class PLIcon {
    
    static var FontAwesome: PLIcon {
        get {
            return PLIcon(fromFont: "FontAwesome")
        }
    }
    
    static var Ionicons: PLIcon {
        get {
            return PLIcon(fromFont: "Ionicons")
        }
    }
    
    static var Material: PLIcon {
        get {
            return PLIcon(fromFont: "material")
        }
    }
    
    static var SimpleLineIcons: PLIcon {
        get {
            return PLIcon(fromFont: "simple-line-icons")
        }
    }
    
    
    let fontName: String!
    var fontSize: CGFloat!
    var color: UIColor!
    var canvasRect: CGRect?
    var offsetX: CGFloat?
    var offsetY: CGFloat?
    var char: Character?
    
    init(fromFont fontName: String) {
        self.fontName = fontName
    }
    
    func size(_ size: CGFloat) -> PLIcon {
        self.fontSize = size
        return self
    }
    
    func color(_ color: UIColor) -> PLIcon {
        self.color = color
        return self
    }
    
    func rect(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> PLIcon {
        canvasRect = CGRect(x: x, y: y, width: width, height: height)
        return self
    }
    
    func offset(x: CGFloat, y: CGFloat) -> PLIcon {
        offsetX = x
        offsetY = y
        return self
    }
    
    func char(_ char: Character) -> PLIcon {
        self.char = char
        return self
    }
    
    func done() -> UIImage {
        let imageLabel = UILabel()
        imageLabel.text = String(char!)
        imageLabel.font = UIFont(name: fontName, size: CGFloat(fontSize))
        imageLabel.textColor = color
        
        if canvasRect != nil {
            imageLabel.bounds = canvasRect!
        } else {
            imageLabel.sizeToFit()
            
            if offsetX != nil {
                imageLabel.bounds = CGRect(x: offsetX!, y: imageLabel.bounds.minY,
                                           width: imageLabel.bounds.width + offsetX!,
                                           height: imageLabel.bounds.height)
            }
            if offsetY != nil {
                imageLabel.bounds = CGRect(x: imageLabel.bounds.minX, y: offsetY!,
                                           width: imageLabel.bounds.width,
                                           height: imageLabel.bounds.height + offsetY!)
            }
        }
        
        UIGraphicsBeginImageContextWithOptions(imageLabel.bounds.size, false, UIScreen.main.scale)
        let ctx = UIGraphicsGetCurrentContext()
        imageLabel.layer.render(in: ctx!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
}
