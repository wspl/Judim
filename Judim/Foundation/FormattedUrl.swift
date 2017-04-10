//
//  FormattedUrl.swift
//  Judim
//
//  Created by Plutonist on 2017/4/2.
//  Copyright © 2017年 Plutonist. All rights reserved.
//

import Foundation
import Regex

extension String {
    var fmt: FormattedUrl { return FormattedUrl(self) }
}

class FormattedUrl  {
    var url: String
    
    var page = ""
    var pageStr = ""
    var idCode = ""
    var keyword = ""
    var date = ""
    var time = ""
    
    init(_ url: String) {
        self.url = url
    }

    private func find(key: String) -> (whole: Range<Int>, value: Range<Int>)? {
        let keyRange = url.rangeInt(of: "{" + key + ":")
        guard keyRange.count > 0 else { return nil }
        
        let wholeStart = keyRange.lowerBound
        var wholeEnd = -1
        
        let valueStart = keyRange.upperBound
        var valueEnd = -1
        var level = 1
        
        charFor: for i in valueStart..<url.characters.count {
            let char = url.char(at: i)
            switch char {
            case "{":
                level += 1
            case "}":
                level -= 1
                if level == 0 {
                    wholeEnd = i + 1
                    valueEnd = i
                    break charFor
                }
            default: break
            }
        }
        return (
            whole: Range<Int>(uncheckedBounds: (lower: wholeStart, upper: wholeEnd)),
            value: Range<Int>(uncheckedBounds: (lower: valueStart, upper: valueEnd))
        )
    }
    
    func get(key: String) -> String? {
        guard let range = find(key: key)?.value else { return nil }
        return url.substring(with: range)
    }
    
    func getWhole(key: String) -> String? {
        guard let range = find(key: key)?.whole else { return nil }
        return url.substring(with: range)
    }
    
    func set(key: String, value: String) -> FormattedUrl {
        guard let range = find(key: key)?.whole else { return self }
        url = url.replace(in: range, with: value)
        return self
    }
    
    func restore(key: String) -> FormattedUrl {
        return set(key: key, value: get(key: key) ?? "")
    }
    
    func restoreAll() -> FormattedUrl {
        var keys = [String]()
        Regex("\\{(\\w+):").allMatches(url).forEach { rs in
            keys.append(rs.captures[0]!)
        }
        var instance = self
        keys.forEach { key in instance = restore(key: key) }
        return instance
    }
    
    func base(on parentUrl: String) -> String {
//        if Regex("^//").matches(url) {
//            let proto = Regex("^(http|https)://").match(parentUrl)?.captures[0]
//            return proto ?? "http" + ":" + url
//        }
//        if Regex("/")
        let u = URL(string: url, relativeTo: URL(string: parentUrl.fmt.restoreAll().url))
        return u?.absoluteString ?? url
    }
}
