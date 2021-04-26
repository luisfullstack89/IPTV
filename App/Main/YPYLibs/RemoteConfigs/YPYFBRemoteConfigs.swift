//
//  YPYFBRemoteConfigs.swift
//  OldiesRadio
//
//  Created by Do Trung Bao on 2/23/20.
//  Copyright © 2020 YPY Global. All rights reserved.
//

import Foundation
import Firebase

class YPYFBRemoteConfigs {
    private let DEFAULT_TIME_OUT = 8.0 //8 seconds
    
    private let expirationDuration = 900 // seconds, 15 minutes
    private var cacheExpiration: Double = 0
    private var timeOut: Double = 0
    private var remoteConfig: RemoteConfig!
    private var defaultDict: NSDictionary!
    
    init(_ cacheExpiration: Double, _ defaultDict: NSDictionary) {
        self.cacheExpiration = cacheExpiration
        self.timeOut = DEFAULT_TIME_OUT
        self.defaultDict = defaultDict
    }
    
    init(_ cacheExpiration: Double, _ timeOut: Double, _ defaultDict: NSDictionary) {
        self.cacheExpiration = cacheExpiration
        self.timeOut = timeOut <= 0 ? DEFAULT_TIME_OUT : timeOut
        self.defaultDict = defaultDict
    }
    
    private func setUpFireBaseConfig () {
        self.remoteConfig = RemoteConfig.remoteConfig()
        self.remoteConfig.setDefaults(self.defaultDict as? [String : NSObject])
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = TimeInterval(self.cacheExpiration)
        settings.fetchTimeout = TimeInterval(self.timeOut)
        self.remoteConfig.configSettings = settings
    }
    
    func fetchDataFromFireBase( _ callback: ((Bool) -> Void)? = nil) {
        self.setUpFireBaseConfig()
        self.remoteConfig.fetch(withExpirationDuration: TimeInterval(self.expirationDuration)) { (status, error) in
            if status == .success {
                 YPYLog.logD("==========>Remote Config fetched!")
                 //show callback with success = true
                self.remoteConfig.activate { (isSuccess, error) in
                    YPYLog.logD("==========>activate done isSuccess =\(isSuccess) and  error=\(String(describing: error?.localizedDescription))")
                    callback?(true)
                }
            }
            else{
                 YPYLog.logE("==========>Config not fetched error= \(error?.localizedDescription ?? "No error available.")")
                 //show callback with success = false
                 callback?(false)
            }
        }
        
    }
    
    public func getBooleanConfig(_ key: String) -> Bool {
        return self.remoteConfig[key].boolValue
    }
    
    public func getStringConfig(_ key: String) -> String {
        let strVal = self.remoteConfig[key].stringValue
        if strVal != nil {
            return strVal!
        }
        return ""
    }
    
    public func getIntConfig(_ key: String) -> Int {
        let strVal = self.remoteConfig[key].stringValue
        if strVal != nil {
            guard let intVal = Int(strVal!) else {
                return -1
            }
            return intVal
        }
        return 0
    }
    public func getDoubleConfig(_ key: String) -> Double {
        let strVal = self.remoteConfig[key].stringValue
        if strVal != nil {
            guard let doubleVal = Double(strVal!) else {
                return -1
            }
            return doubleVal
        }
        return 0.0
    }
    
}
