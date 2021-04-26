//
//  BundleModel.swift
//  iptv-pro
//
//  Created by YPY Global on 8/13/20.
//  Copyright © 2020 YPY Global. All rights reserved.
//

import Foundation

public class BundleModel: AbstractModel {
    
    var uri = ""
    var apiKey = ""
    var isM3u: Int64 = 0
    var versionCode = "0"
    var sha1 = ""

    public required init() {
        super.init()
    }
    
    init(_ name: String, _ uri: String) {
        super.init(0,name,"")
        self.uri = uri
    }
    
    override func initFromDict(_ dictionary: [String : Any]?) {
        super.initFromDict(dictionary)
        if let uri = dictionary?["uri"] as? String{
            self.uri = uri
        }
        if let apiKey = dictionary?["api_key"] as? String{
            self.apiKey = apiKey
        }
        if let isM3u = dictionary?["is_m3u"] as? Int64{
            self.isM3u = isM3u
        }
        if let sha1 = dictionary?["sha1"] as? String{
            self.sha1 = sha1
        }
        if let versionCode = dictionary?["version_code"] as? String{
            self.versionCode = versionCode
        }
    }
    
    override func createDictToSave() -> [String : Any]? {
        var dicts = super.createDictToSave()
        dicts!.updateValue(uri, forKey: "uri")
        dicts!.updateValue(apiKey, forKey: "api_key")
        dicts!.updateValue(sha1, forKey: "sha1")
        dicts!.updateValue(versionCode, forKey: "version_code")
        dicts!.updateValue(isM3u, forKey: "is_m3u")
        return dicts
    }
    
    override func getShareStr() -> String? {
        var strBuilder: String = ""
        if !name.isEmpty {
            strBuilder = strBuilder + name + "\n"
        }
        if !uri.isEmpty {
            strBuilder = strBuilder + uri
        }
        return strBuilder
    }
}
