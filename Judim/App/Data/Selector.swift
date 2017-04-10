//
//  Selector.swift
//  Judim
//
//  Created by Plutonist on 2017/4/2.
//  Copyright © 2017年 Plutonist. All rights reserved.
//

import RealmSwift
import SwiftSoup
import SwiftyJSON
import Regex

class Selector {
    let json: JSON

    init(json: JSON) {
        self.json = json
    }
    
    func Invoke(input: Element) -> String {
        do {
            let selector = json["selector"].stringValue
            guard let selected = selector == "this" ? input : try input.select(selector).first() else {
                return ""
            }

            var str = ""
            
            switch json["fun"].stringValue {
            case "html":
                str = try selected.html()
            case "text":
                str = try selected.text()
            case "attr":
                str = try selected.attr(json["param"].stringValue)
            default:
                str = try selected.outerHtml()
            }
            
            if json["regex"].exists() {
                let re = try Regex(string: json["regex"].stringValue)
                let matched = re.match(str)!.captures

                if json["replacement"].exists() {
                    str = json["replacement"].stringValue
                    for (i, ss) in matched.enumerated() {
                        str = str.replacingOccurrences(of: "$\(i+1)", with: ss!)
                    }
                } else {
                    str = matched[0]!
                }
            }
            
            return str
        } catch {
            print(error.localizedDescription)
            return ""
        }
    }
}
