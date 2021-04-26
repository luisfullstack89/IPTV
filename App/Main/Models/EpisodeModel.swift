//
//  EpisodeModel.swift
//  iptv-pro
//  Created by YPY Global on 8/13/20.
//  Copyright © 2020 YPY Global. All rights reserved.
//

import Foundation
public class EpisodeModel: DateModel {
    
    var linkDownload = ""
    var linkPlay = ""
    var des = ""
    var movie: MovieModel?

    override func initFromDict(_ dictionary: [String : Any]?) {
        super.initFromDict(dictionary)
        if let linkPlay = dictionary?["link"] as? String {
            self.linkPlay = linkPlay
        }
        if let linkDownload = dictionary?["link_download"] as? String {
            self.linkDownload = linkDownload
        }
        if let des = dictionary?["des"] as? String {
            self.des = des
        }
    }
    
    override func createDictToSave() -> [String : Any]? {
        var dicts = super.createDictToSave()
        dicts!.updateValue(linkPlay, forKey: "link")
        dicts!.updateValue(linkDownload, forKey: "link_download")
        dicts!.updateValue(createdAt, forKey: "created_date")
        dicts!.updateValue(des, forKey: "des")
        return dicts
    }
    
    override func getUriArtwork(_ urlEnpoint: String) -> String {
        if !img.isEmpty && !img.starts(with: "http") {
            let urlFormat = urlEnpoint + IPTVNetUtils.FOLDER_EPISODES
            return String.init(format: urlFormat, img.replacingOccurrences(of: " ", with: "%20"))
        }
        return img
    }
    
    func convertToMovieModel() -> MovieModel {
        if self.movie == nil {
            self.movie = MovieModel(id,name,img)
            self.movie?.isEpisode = true
            self.movie?.createdAt = createdAt
            
            self.movie?.links = []
            let movieLink = MovieLinkModel("la",self.linkPlay,self.linkDownload)
            self.movie?.links?.append(movieLink)
        }
        return self.movie!
    }

}
