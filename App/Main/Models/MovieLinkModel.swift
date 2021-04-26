//
//  MovieLinkModel.swift
//  iptv-pro
//
//  Created by Do Trung Bao on 8/13/20.
//  Copyright © 2020 YPY Global. All rights reserved.
//

import Foundation
public class MovieLinkModel: JsonModel {
    
    var lan = ""
    var linkPlay = ""
    var linkDownload = ""
    
    public required init() {
        super.init()
    }
    
    init(_ lan: String, _ linkPlay: String, _ linkDownload: String) {
        super.init()
        self.lan = lan
        self.linkPlay = linkPlay
        self.linkDownload = linkDownload
    }
    
    override func initFromDict(_ dictionary: [String : Any]?) {
        super.initFromDict(dictionary)
        if let lan = dictionary?["lan"] as? String {
            self.lan = lan
        }
        if let linkPlay = dictionary?["link_play"] as? String {
            self.linkPlay = linkPlay
        }
        if let linkDownload = dictionary?["link_download"] as? String {
            self.linkDownload = linkDownload
        }
    }
    
    override func createDictToSave() -> [String : Any]? {
        var dicts = super.createDictToSave()
        dicts!.updateValue(lan, forKey: "lan")
        dicts!.updateValue(linkPlay, forKey: "link_play")
        dicts!.updateValue(linkDownload, forKey: "link_download")
        return dicts
    }
    
    func getLinkPlay() -> String {
        if self.isLinkPlayOk() {
            return linkPlay
        }
         return linkDownload
    }
    
    func isLinkPlayOk() -> Bool {
        return !linkPlay.isEmpty
    }
    
    func isLinkDownloadOk() -> Bool{
        return !linkDownload.isEmpty
    }
    
    func isNeedDecrypt() -> Bool {
        return (self.isLinkPlayOk() && !self.linkPlay.starts(with: "http"))
            || (self.isLinkDownloadOk() && !self.linkDownload.starts(with: "http"))
    }
    
    override func copy() -> MovieLinkModel? {
        return MovieLinkModel(lan,linkPlay,linkDownload)
    }
}
