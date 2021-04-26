//
//  CacheModel.swift
//  iLandMusic
//
//  Created by iLandMusic on 11/5/19.
//  Copyright © 2019 iLandMusic. All rights reserved.
//

import Foundation
import SQLite

class CacheModel: AbstractModel {
    
    var cacheId: Int64 = 0
    var timeStamp: Double = Double(0)
    var type: String = ""
    
    public required init() {
        super.init()
    }
    
    override init(_ cacheId: Int64, _ name: String, _ type: String) {
        super.init(0,name,"")
        self.cacheId = cacheId
        self.type = type
        self.timeStamp = DateTimeUtils.currentTimeMillis()
    }
    
    override func initFromDict(_ dictionary: [String : Any]?) {
        super.initFromDict(dictionary)
        if dictionary != nil {
            if let parseCacheId = dictionary!["cache_id"] as? Int64{
                self.cacheId = parseCacheId
            }
            if let parseTimeStamp = dictionary!["time_stamp"] as? Double{
                self.timeStamp = parseTimeStamp
            }
            if let parseType = dictionary!["type"] as? String{
                self.type = parseType
            }
        }
    }
    
    override func createDictToSave() -> [String : Any]? {
        var dicts = super.createDictToSave()
        dicts!.updateValue(cacheId, forKey: "cache_id")
        dicts!.updateValue(type, forKey: "type")
        dicts!.updateValue(timeStamp, forKey: "time_stamp")
        return dicts
    }
 
    func isExpired (_ deltaTime: Double) -> Bool {
        return timeStamp == 0 || ( deltaTime > 0 && (DateTimeUtils.currentTimeMillis() - timeStamp) > deltaTime)
    }
}
