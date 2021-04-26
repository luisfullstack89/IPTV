//
//  AdsModel.swift
//  Created by YPY Global on 8/12/20.
//  Copyright © 2020 YPY Global. All rights reserved.
//

import Foundation

public class AdsModel {
    
    static let TYPE_ADS_ADMOB = "admob"
    static let TYPE_ADS_FB = "facebook"
    
    var typeAds = TYPE_ADS_FB
    var bannerId = ""
    var mediumId = ""
    var nativeId = ""
    var interstitialId = ""
    var isAllowShowAds = true
    var testIds : [String] = []
    
    init(isAllowShow : Bool = true, banner: String? = nil, interstitial : String? = nil) {
        self.bannerId = banner ?? ""
        self.interstitialId = interstitial ?? ""
        self.isAllowShowAds = isAllowShow
    }
    
    func addTestId(_ id: String){
        testIds.append(id)
    }
}
