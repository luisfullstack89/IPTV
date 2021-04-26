//
//  SeasonController.swift
//  iptv-pro
//
//  Created by Do Trung Bao on 8/19/20.
//  Copyright © 2020 YPY Global. All rights reserved.
//

import Foundation
import UIKit

class SeasonController: ActionBarCollectionController {
        
    var series: SeriesModel?
    @IBOutlet weak var lblNumSeason: UILabel!
    
    override func setUpUI() {
        self.isAllowAddObserver = false
        super.setUpUI()
        self.lblTitleScreen.text = self.series?.name
        self.lblNumSeason.text = StringUtils.formatNumberSocial(StringRes.format_season, StringRes.format_seasons, (self.series?.numSeason ?? 0))
    }
    
    override func getIDCellOfCollectionView() -> String {
        return String(describing: SeasonCell.self)
    }
    
    override func getListModelFromServer(_ offset: Int, _ limit: Int, _ completion: @escaping (ResultModel?) -> Void) {
        if ApplicationUtils.isOnline() {
            let urlEncodeKeyword = self.keyword?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
            let seriesId = self.series?.id ?? 0
            IPTVNetUtils.getListSeasons(seriesId,offset, limit,urlEncodeKeyword, completion)
            return
        }
        completion(nil)
    }

    override func showSearchView(_ isShow: Bool) {
        super.showSearchView(isShow)
        self.lblNumSeason.isHidden = isShow
    }
}
