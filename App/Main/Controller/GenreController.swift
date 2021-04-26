//
//  GenreController.swift
//  Created by YPY Global on 4/11/19.
//  Copyright © 2019 YPY Global. All rights reserved.
//

import Foundation
import UIKit

class GenreController: BaseCollectionController{
    
    @IBOutlet weak var actionBarConstraint: NSLayoutConstraint!
    @IBOutlet weak var layoutActionBar: UIView!
    
    override func setUpUI() {
        self.isAllowAddObserver = false
        super.setUpUI()
    }
    
    override func updateCustomizeViewConstraint() {
        super.updateCustomizeViewConstraint()
        self.actionBarConstraint.constant = getDimen(DimenRes.action_bar_sizes)
        self.layoutActionBar.layoutIfNeeded()
    }
    
    override func getUIType() -> UIType {
        return .FlatGrid
    }
    
    override func getListModelFromServer(_ offset: Int, _ limit: Int, _ completion: @escaping (ResultModel?) -> Void) {
        if ApplicationUtils.isOnline() {
            IPTVNetUtils.getListGenreModel(completion)
            return
        }
        completion(nil)
    }

    
    override func getIDCellOfCollectionView() -> String {
        return String(describing: GenreCell.self)
    }
    
    //override function to calculate height of native ads
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let heightPerItem = IPTVConstants.RATE_16_9 * widthItemGrid
        return CGSize(width: widthItemGrid, height: heightPerItem)
    }
    
    override func renderModel(cell: UICollectionViewCell, model: JsonModel) {
        let genre = model as! GenreModel
        let cell = cell as! GenreCell
        let index = self.listModels?.firstIndex(where: { $0.equalElement(genre) }) ?? 0
        cell.updateUI(genre,index)
    }
    
    @IBAction func backTap(_ sender: Any) {
        if self.backStack() {
            return
        }
    }
}
