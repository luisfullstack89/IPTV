//
//  GenreModel.swift
//  iptv-pro
//
//  Created by Do Trung Bao on 8/13/20.
//  Copyright © 2020 YPY Global. All rights reserved.
//

import Foundation
public class GenreModel: AbstractModel {
    
    override func getUriArtwork(_ urlEnpoint: String) -> String {
        if !img.isEmpty && !img.starts(with: "http") {
            let urlFormat = urlEnpoint + IPTVNetUtils.FOLDER_GENRES
            return String.init(format: urlFormat, img.replacingOccurrences(of: " ", with: "%20"))
        }
        return img
    }

}
