//
//  StringExtensions.swift
//  Judim
//
//  Created by Plutonist on 2017/4/2.
//  Copyright © 2017年 Plutonist. All rights reserved.
//

import Foundation

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
    
    func rangeInt(of str: String) -> Range<Int> {
        let nsRange = (self as NSString).range(of: str)
        return Range<Int>.init(uncheckedBounds: (lower: nsRange.location, upper: nsRange.location + nsRange.length))
    }
    
    func char(at index: Int) -> Character {
        return Character(UnicodeScalar((self as NSString).character(at: index))!)
    }
    
    func replace(in range: Range<Int>, with: String) -> String {
        return substring(to: range.lowerBound) + with + substring(from: range.upperBound)
    }
}
