//
//  SeriesModel.swift
//  iptv-pro
//
//  Created by YPY Global on 8/13/20.
//  Copyright © 2020 YPY Global. All rights reserved.
//

import Foundation
public class SeriesModel: DateModel {
    
    var numSeason: Int64 = 0
    var des = ""
    
    override func initFromDict(_ dictionary: [String : Any]?) {
        super.initFromDict(dictionary)
        if let numSeason = dictionary?["num_season"] as? String {
            if numSeason.isNumber() {
                self.numSeason = Int64(numSeason)!
            }
        }
        if let des = dictionary?["des"] as? String {
            self.des = des
        }
    }
    
    override func createDictToSave() -> [String : Any]? {
        var dicts = super.createDictToSave()
        dicts!.updateValue(numSeason, forKey: "num_season")
        dicts!.updateValue(des, forKey: "des")
        return dicts
    }
    
    override func getUriArtwork(_ urlEnpoint: String) -> String {
        if !img.isEmpty && !img.starts(with: "http") {
            let urlFormat = urlEnpoint + IPTVNetUtils.FOLDER_SERIES
            return String.init(format: urlFormat, img.replacingOccurrences(of: " ", with: "%20"))
        }
        return img
    }
}
