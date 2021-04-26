//
//  StringUtils.swift
//  YPY Global
//  Created by YPY Global on 8/27/19.
//  Copyright © 2019 YPY Global. All rights reserved.
//

import Foundation
import UIKit
import CommonCrypto

open class StringUtils {
    
    public static func urlEncodeString(_ data: String?) -> String? {
        if data == nil || data!.isEmpty {
            return nil
        }
        return data!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
    }

    public static func formatNumberSocial(_ resId: String, _ resIds: String, _ number: Int64) -> String {
        let resIdShow = number > 1 ? resIds : resId
        var strShow = String(number)
        if number >= 1000 && number < 1000000 {
            strShow = String(number/1000) + "K"
        }
        else if number >= 1000000 && number < 1000000000 {
            strShow = String(number/1000) + "M"
        }
        else if number >= 1000000000 {
            strShow = String(number/1000) + "B"
        }
        return String(format: getString(resIdShow), strShow)
    }
    
    public static func isHasSpecialCharacter(_ str: String) -> Bool{
        let regex = ".*[^A-Za-z0-9_].*"
        let hasSpecialCharacters = str.range(of: regex, options: .regularExpression)
        return hasSpecialCharacters != nil
    }
    
    public static func checkUrl(_ url: String?) -> Bool {
        if url == nil || url!.isEmpty {
            return false
        }
        if url!.starts(with: "http"){
            guard let uri = URL(string: url!) else {
                return false
            }
            if !UIApplication.shared.canOpenURL(uri) {
                return false
            }
        }
        let regEx = "((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let regExHttp = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let hasUrl = url?.range(of: regEx, options: .regularExpression)
        let hasUrlHttp = url?.range(of: regExHttp, options: .regularExpression)
        return hasUrl != nil || hasUrlHttp != nil
    }
    
    public static func getMd5Hash(_ string: String) -> String? {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)
        if let data = string.data(using: String.Encoding.utf8) {
            data.withUnsafeBytes { buffer in
                _ = CC_MD5(buffer.baseAddress, CC_LONG(buffer.count), &digest)
            }
        }
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }

 

}
