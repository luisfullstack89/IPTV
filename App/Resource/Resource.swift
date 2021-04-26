//
//  Resource.swift
//  Created by YPY Global on 8/12/20.
//  Copyright © 2020 YPY Global. All rights reserved.
//

import Foundation
import UIKit

let iphone_res = "iphone"
let ipad_res = "ipad"

func getDimen(_ dimenArrays: [String:CGFloat]) -> CGFloat {
    let key = Display.pad ? ipad_res : iphone_res
    return dimenArrays[key] ?? dimenArrays[iphone_res]!
}

func getString(_ key: String) -> String {
    return getString(key,comment: "")
}

func getString(_ key: String, comment: String) -> String {
    let value = NSLocalizedString(key, comment: "")
    if value != key || NSLocale.preferredLanguages.first == "en" {
        return value
    }
    
    // Fall back to en
    guard
        let path = Bundle.main.path(forResource: "Base", ofType: "lproj"),
        let bundle = Bundle(path: path)
        else { return value }
    return NSLocalizedString(key, bundle: bundle, comment: "")
}

func getColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if(cString.starts(with: "00") && (cString.count) == 9){
        return UIColor.clear
    }
    
    if(cString.count == 9){
        cString = cString.argb2rgba!
    }
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6 && (cString.count) != 8) {
        return UIColor.gray
    }
    var rgbValue:UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    if(cString.count == 6){
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    else{
        return UIColor(
            red: CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0,
            green: CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0,
            blue: CGFloat((rgbValue & 0x0000FF00) >> 8)  / 255.0,
            alpha: CGFloat(rgbValue & 0x000000FF)  / 255.0
        )
    }
}
