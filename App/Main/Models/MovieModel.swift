//
//  MovieModel.swift
//  iptv-pro
//
//  Created by YPY Global on 8/13/20.
//  Copyright © 2020 YPY Global. All rights reserved.
//

import Foundation
import GoogleCast

public class MovieModel: DateModel {
    
    var links: [MovieLinkModel]?
    var genres = ""
    var isEpisode = false
    var isM3u = false
    var lanSelected = "la"
    
    override func initFromDict(_ dictionary: [String : Any]?) {
        super.initFromDict(dictionary)
        if let genres = dictionary?["genres"] as? String {
            self.genres = genres
        }
        if let isEpisode = dictionary?["is_episode"] as? Bool {
            self.isEpisode = isEpisode
        }
        if let isM3u = dictionary?["is_m3u"] as? Bool {
            self.isM3u = isM3u
        }
        if let links = dictionary?["links"] as? [[String:Any]] {
            self.links = []
            for dict in links {
                let link = MovieLinkModel()
                link.initFromDict(dict)
                self.links?.append(link)
            }
        }
    }
    
    func getLinkModel() -> MovieLinkModel?  {
        let size = links?.count ?? 0
        if size > 0 {
            return self.links?.first(where: {$0.lan.elementsEqual(self.lanSelected)})
        }
        return nil
    }
    
    override func createDictToSave() -> [String : Any]? {
        var dicts = super.createDictToSave()
        dicts!.updateValue(self.genres, forKey: "genres")
        dicts!.updateValue(self.isM3u, forKey: "is_m3u")
        dicts!.updateValue(self.isEpisode, forKey: "is_episode")
        let size = self.links?.count ?? 0
        if size > 0 {
            let links = MovieLinkModel.getDictFromList(self.links!)
            dicts!.updateValue(links, forKey: "links")
        }
        return dicts
    }
    
    override func copy() -> MovieModel? {
        let movie = MovieModel(id,name,img)
        movie.links = self.links?.clone()
        movie.genres = genres
        movie.isM3u = isM3u
        movie.createdAt = createdAt
        movie.isEpisode = isEpisode
        return movie
    }
    
    override func getUriArtwork(_ urlEnpoint: String) -> String {
        if !img.isEmpty && !img.starts(with: "http") {
            let urlFormat = urlEnpoint + IPTVNetUtils.FOLDER_MOVIES
            return String.init(format: urlFormat, img.replacingOccurrences(of: " ", with: "%20"))
        }
        return img
    }
    
    override func equalElement(_ otherModel: JsonModel?) -> Bool {
        if let abModel = otherModel as? MovieModel {
            return abModel.id == id && abModel.isM3u == isM3u
        }
        return false
    }
    
    override func getShareStr() -> String? {
        var mStrBuilder: String = ""
        if !name.isEmpty {
            mStrBuilder = mStrBuilder + name + "\n"
        }
        return mStrBuilder
    }
    
    func getCastMediaInfo(_ duration: Double = 0) -> GCKMediaInformation? {
        if let movieLink = self.getLinkModel() {
            guard let linkPlayURL = URL(string: movieLink.getLinkPlay()) else {
                return nil
            }
            YPYLog.logE("====>mimeType=\(linkPlayURL.mimeType())==>uri=\(linkPlayURL.absoluteString)")
            let metadata = GCKMediaMetadata(metadataType: .movie)
            metadata.setString(name, forKey: kGCKMetadataKeyTitle)
            let artist = !self.genres.isEmpty ? self.genres : getString(StringRes.app_name)
            metadata.setString(artist, forKey: kGCKMetadataKeySubtitle)
            metadata.setString(IPTVConstants.USER_AGENT, forKey: IPTVConstants.USER_AGENT_VALUE)
            
            let urlEndpoint = SettingManager.getUrlEnpoint()
            let artwork = self.getUriArtwork(urlEndpoint)
            let linkImgCast = !artwork.isEmpty && artwork.starts(with: "http") ? artwork : IPTVConstants.URL_IMAGE_DEFAULT_FOR_CHROME_CAST
            YPYLog.logE("====>linkImgCast=\(linkImgCast)")
            if let thumbUrl = URL(string: linkImgCast) {
                metadata.addImage(GCKImage(url: thumbUrl, width: 480, height: 640))
            }
            
            let mediaInfoBuilder = GCKMediaInformationBuilder(contentURL: linkPlayURL)
            mediaInfoBuilder.contentID = linkPlayURL.absoluteString
            mediaInfoBuilder.streamType = .buffered
            mediaInfoBuilder.streamDuration = TimeInterval(duration)
            mediaInfoBuilder.contentType = linkPlayURL.mimeType()
            mediaInfoBuilder.metadata = metadata
            let mediaInfo = mediaInfoBuilder.build()
            return mediaInfo
        }
        return nil
    }
}
