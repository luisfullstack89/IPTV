//
//  YPYLog.swift
//  Created by YPY Global on 3/5/19.
//  Copyright © 2019 YPY Global. All rights reserved.
//

import Foundation

open class YPYLog {
    
    private static var LOG: Bool = false
    private static let DEFAULT_TAG = "DCM"
    
    public static func logD(_ msg: String) {
        logD(DEFAULT_TAG,msg)
    }
    
    public static func logD(_ tag: String, _ msg: String) {
        if LOG {
            print("\(tag), DEBUG====>\(msg)")
        }
    }
    
    public static func logE(_ msg: String) {
        logE(DEFAULT_TAG,msg)
    }
    
    public static func logE(_ tag: String, _ msg: String) {
        if LOG {
            print("\(tag), ERROR====>\(msg)")
        }
    }
    
    public static func logV(_ msg: String) {
        logV(DEFAULT_TAG,msg)
    }
    
    public static func logV(_ tag: String, _ msg: String) {
        if LOG {
            print("\(tag), VERBOSE====>\(msg)")
        }
    }
    public static func setDebug(_ allowDebug: Bool) {
        LOG = allowDebug
    }
}
