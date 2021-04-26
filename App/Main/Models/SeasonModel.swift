//
//  SeasonModel.swift
//  iptv-pro
//
//  Created by Do Trung Bao on 8/13/20.
//  Copyright © 2020 YPY Global. All rights reserved.
//

import Foundation
public class SeasonModel: DateModel{
    
    var des = ""
    var numEpisode: Int64 = 0
 
    override func initFromDict(_ dictionary: [String : Any]?) {
        super.initFromDict(dictionary)
        if let numEpisode = dictionary?["num_episode"] as? String {
            if numEpisode.isNumber() {
                self.numEpisode = Int64(numEpisode)!
            }
        }
        if let des = dictionary?["des"] as? String {
            self.des = des
        }
    }
    
    override func createDictToSave() -> [String : Any]? {
        var dicts = super.createDictToSave()
        dicts!.updateValue(numEpisode, forKey: "num_episode")
        dicts!.updateValue(des, forKey: "des")
        return dicts
    }
    
    override func getUriArtwork(_ urlEnpoint: String) -> String {
        if !img.isEmpty && !img.starts(with: "http") {
            let urlFormat = urlEnpoint + IPTVNetUtils.FOLDER_SEASONS
            return String.init(format: urlFormat, img.replacingOccurrences(of: " ", with: "%20"))
        }
        return img
    }
    
}
