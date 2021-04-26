//
//  CacheJoinModel.swift
//  iLandMusic
//
//  Created by iLandMusic on 11/5/19.
//  Copyright © 2019 iLandMusic. All rights reserved.
//

import Foundation
import SQLite

class CacheJoinModel: AbstractModel {
    
    var cacheId: Int64 = 0
    var valueId: Int64 = 0
    var type: String = ""
    
    public required init() {
        super.init()
    }
    
    init(_ cacheId: Int64, _ valueId: Int64, _ type: String) {
        super.init()
        self.cacheId = cacheId
        self.valueId = valueId
        self.type = type
    }
    
    override func initFromDict(_ dictionary: [String : Any]?) {
        super.initFromDict(dictionary)
        if dictionary != nil {
            if let parseCacheId = dictionary!["cache_id"] as? Int64{
                self.cacheId = parseCacheId
            }
            if let parseValueId = dictionary!["value_id"] as? Int64{
                self.valueId = parseValueId
            }
            if let parseType = dictionary!["type"] as? String{
                self.type = parseType
            }
        }
    }
    
    override func createDictToSave() -> [String : Any]? {
        var dicts = super.createDictToSave()
        dicts!.updateValue(cacheId, forKey: "cache_id")
        dicts!.updateValue(valueId, forKey: "value_id")
        dicts!.updateValue(type, forKey: "type")
        return dicts
    }
    
}
