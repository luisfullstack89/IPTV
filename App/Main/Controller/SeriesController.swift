//
//  SeriesController.swift
//  iptv-pro
//
//  Created by Do Trung Bao on 8/18/20.
//  Copyright © 2020 YPY Global. All rights reserved.
//

import Foundation
import UIKit

class SeriesController: ActionBarCollectionController {
    
    let rateMovie = getDimen(DimenRes.rate_movies)
    
    override func setUpUI() {
        self.isAllowAddObserver = false
        self.itemsPerRow = 3
        super.setUpUI()
    }
    
    override func getIDCellOfCollectionView() -> String {
        return String(describing: SerieCell.self)
    }
        
    override func getListModelFromServer(_ offset: Int, _ limit: Int, _ completion: @escaping (ResultModel?) -> Void) {
        if ApplicationUtils.isOnline() {
            let urlEncodeKeyword = self.keyword?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
            IPTVNetUtils.getSeries(offset, limit,urlEncodeKeyword, completion)
            return
        }
        completion(nil)
    }
    
    //override function to calculate height of native ads
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let heightPerItem = rateMovie * widthItemGrid
        return CGSize(width: widthItemGrid, height: heightPerItem)
    }
    
    override func getUIType() -> UIType {
        return .FlatGrid
    }
    
}
