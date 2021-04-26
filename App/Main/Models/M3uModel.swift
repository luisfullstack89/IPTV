//
//  M3uModel.swift
//  iptv-pro
//  Created by YPY Global on 8/19/20.
//  Copyright © 2020 YPY Global. All rights reserved.
//

import Foundation

public class M3uModel: DateModel {
    
    var bundleId: Int64 = 0
    var duration: Int64 = 0
    var uri = ""
    var group = ""

    override func initFromDict(_ dictionary: [String : Any]?) {
        super.initFromDict(dictionary)
        if let bundleId = dictionary?["bundle_id"] as? Int64 {
            self.bundleId = bundleId
        }
        if let duration = dictionary?["duration"] as? Int64 {
            self.duration = duration
        }
        if let group = dictionary?["group_title"] as? String {
            self.group = group
        }
        if let uri = dictionary?["uri"] as? String {
            self.uri = uri
        }
    }
    
    override func createDictToSave() -> [String : Any]? {
        var dicts = super.createDictToSave()
        dicts!.updateValue(uri, forKey: "uri")
        dicts!.updateValue(bundleId, forKey: "bundle_id")
        dicts!.updateValue(duration, forKey: "duration")
        dicts!.updateValue(group, forKey: "group_title")
        return dicts
    }
    
    func convertToMovieModel() -> MovieModel {
        let movie = MovieModel(id,name,img)
        movie.isM3u = true
        movie.createdAt = createdAt
        movie.genres = self.group
        movie.links = []
        let movieLink = MovieLinkModel("la",self.uri,self.uri)
        movie.links?.append(movieLink)
        return movie
    }
    
    
}
