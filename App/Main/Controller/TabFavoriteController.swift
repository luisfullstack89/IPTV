//
//  FavoriteController.swift
//  Created by YPY Global on 4/11/19.
//  Copyright © 2019 YPY Global. All rights reserved.
//

import Foundation
import UIKit

class TabFavoriteController: BaseCollectionController {
    
    let rateMovie = getDimen(DimenRes.rate_movies)
    var favDelegate: FavoriteDelegate?
    
    override func setUpUI() {
        self.itemsPerRow = 3
        super.setUpUI()
    }
    
    override func getUIType() -> UIType {
        return .FlatGrid
    }
    
    override func onBroadcastDataChanged(notification: Notification) {
        guard let id: Int64 = notification.userInfo![IPTVConstants.KEY_ID] as? Int64 else {
            notifyWhenDataChanged()
            return
        }
        guard let isFav: Bool = notification.userInfo![IPTVConstants.KEY_IS_FAV] as? Bool else {
            notifyWhenDataChanged()
            return
        }
        let isM3u: Bool = notification.userInfo![IPTVConstants.KEY_IS_M3U] as? Bool  ?? false
        if isFav {
            onRefreshData(true)
        }
        else{
            if  self.listModels != nil && self.listModels!.count > 0 {
                let indexItem: Int = self.listModels!.firstIndex(where: {
                    let model: MovieModel = ($0 as? MovieModel)!
                    return model.id == id && model.isM3u == isM3u
                })!
                if indexItem >= 0 {
                    self.listModels!.remove(at: indexItem)
                }
                self.lblNodata.isHidden = self.listModels!.count != 0
                notifyWhenDataChanged()
            }
        }
    
    }
    
    //override function to calculate height of native ads
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let heightPerItem = rateMovie * widthItemGrid
        return CGSize(width: widthItemGrid, height: heightPerItem)
    }
    
    override func getIDCellOfCollectionView() -> String {
        return String(describing: MovieCell.self)
    }
    
    override func renderModel(cell: UICollectionViewCell, model: JsonModel) {
        let item = model as! MovieModel
        let cell = cell as! MovieCell
        cell.favDelegate = self.favDelegate
        cell.typeVC = self.typeVC
        cell.updateUI(item)
    }
    
}
