//
//  SiteFlag.swift
//  Judim
//
//  Created by Plutonist on 2017/4/2.
//  Copyright © 2017年 Plutonist. All rights reserved.
//

import SwiftyJSON

class SiteFlags {
    static let all = [
        "noCover",
        "noTitle",
        "noRating",
        "noTag",
        "repeatedThumbnail",
        "singlePageBigPicture",
        "preloadGallery",
        "secondLevelGallery",
        "onePicGallery",
        "postIndex",
        "postGallery",
        "postPicture",
        "postAll"
    ]
    var flagsStrings = [String]()
    var isSupported = false
    init(parse: String) {
        flagsStrings = parse.components(separatedBy: "|")
        isSupported = flagsStrings.filter { SiteFlags.all.contains($0) }.count == flagsStrings.count
    }
    func has(_ flag: String) -> Bool {
        return flagsStrings.contains(flag)
    }
}
