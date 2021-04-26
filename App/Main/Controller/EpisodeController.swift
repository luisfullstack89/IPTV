//
//  EpisodeController.swift
//  iptv-pro
//
//  Created by Do Trung Bao on 8/19/20.
//  Copyright © 2020 YPY Global. All rights reserved.
//

import Foundation
import UIKit

class EpisodeController: ActionBarCollectionController {
    
    var season: SeasonModel?
    @IBOutlet weak var lblNumEpisode: UILabel!
    
    override func setUpUI() {
        self.isAllowAddObserver = false
        super.setUpUI()
        self.lblTitleScreen.text = self.season?.name
        self.lblNumEpisode.text = StringUtils.formatNumberSocial(StringRes.format_episode, StringRes.format_episodes, (self.season?.numEpisode ?? 0))
    }
    
    override func getIDCellOfCollectionView() -> String {
        return String(describing: EpisodeCell.self)
    }

    override func getListModelFromServer(_ offset: Int, _ limit: Int, _ completion: @escaping (ResultModel?) -> Void) {
        if ApplicationUtils.isOnline() {
            let urlEncodeKeyword = self.keyword?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
            let seriesId = self.season?.id ?? 0
            IPTVNetUtils.getListEpisodes(seriesId,offset, limit,urlEncodeKeyword, completion)
            return
        }
        completion(nil)
    }

    override func showSearchView(_ isShow: Bool) {
        super.showSearchView(isShow)
        self.lblNumEpisode.isHidden = isShow
    }
}
