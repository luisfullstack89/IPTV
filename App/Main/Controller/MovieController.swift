//
//  MovieController.swift
//  iptv-pro
//
//  Created by YPY Global on 8/18/20.
//  Copyright © 2020 YPY Global. All rights reserved.
//

import Foundation
import UIKit
import Sheeeeeeeeet

class MovieController: ActionBarCollectionController {
    
    let rateMovie = getDimen(DimenRes.rate_movies)
    
    @IBOutlet weak var btnFilter: UIButton!
    
    var genreId: Int64 = 0
    var titleScreen: String?
    var favDelegate: FavoriteDelegate?
    var bundleM3u: BundleModel?
    var databaseMng = DatabaseManager.shared
    var groups: [String]?
    var selectGroup: String?
    
    override func setUpUI() {
        self.itemsPerRow = 3
        super.setUpUI()
        self.lblTitleScreen.text = self.getTitleScreen()
    }
    
    private func getTitleScreen() -> String {
        if self.titleScreen != nil && !self.titleScreen!.isEmpty {
            return self.titleScreen!
        }
        if self.typeVC == IPTVConstants.TYPE_VC_FEATURED_MOVIES {
            return getString(StringRes.title_featured_movies)
        }
        else if self.typeVC == IPTVConstants.TYPE_VC_NEWEST_MOVIES {
            return getString(StringRes.title_newest_movies)
        }
        else{
            return getString(StringRes.title_movies)
        }
    }
    
    override func filterListModelsInThread(_ listModels: [JsonModel]?) -> [JsonModel]? {
        self.totalDataMng.updateFavoriteForList(listModels as? [MovieModel])
        return listModels
    }
    
    override func getIDCellOfCollectionView() -> String {
        return String(describing: MovieCell.self)
    }
        
    override func getListModelFromServer(_ offset: Int, _ limit: Int, _ completion: @escaping (ResultModel?) -> Void) {
        if bundleM3u != nil {
            let bundleId = bundleM3u!.id
            if self.groups == nil {
                self.groups = self.databaseMng.appDatabase?.m3uDAO.getGroups(bundleId) ?? []
                let size =  self.groups?.count ?? 0
                if size > 0 {
                    self.groups?.insert(getString(StringRes.title_all_group), at: 0)
                }
            }
            var models: [MovieModel]?
            if selectGroup != nil && !selectGroup!.isEmpty {
                models = self.databaseMng.appDatabase?.m3uDAO.getMoviesOfGroup(bundleId,selectGroup!, offset, limit)
            }
            else{
                models  = self.databaseMng.appDatabase?.m3uDAO.getMovies(bundleId, offset, limit,self.keyword)
            }
            completion(self.convertListModelToResult(models))
            return
        }
        if ApplicationUtils.isOnline() {
            let urlEncodeKeyword = self.keyword?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
            if self.keyword != nil && !self.keyword!.isEmpty {
                IPTVNetUtils.getListMovies(offset, limit,0,urlEncodeKeyword, completion)
                return
            }
            if self.genreId > 0 {
                IPTVNetUtils.getListMovies(offset, limit,self.genreId,urlEncodeKeyword, completion)
                return
            }
            if self.typeVC == IPTVConstants.TYPE_VC_FEATURED_MOVIES {
                IPTVNetUtils.getFeaturedMovies(offset, limit,completion)
            }
            else if self.typeVC == IPTVConstants.TYPE_VC_NEWEST_MOVIES {
                IPTVNetUtils.getRecentMovies(offset, limit,completion)
            }
            return
        }
        completion(nil)
    }
    override func showSearchView(_ isShow: Bool) {
        super.showSearchView(isShow)
        if isShow {
            self.btnFilter.isHidden = isShow
        }
        else{
            let size = self.groups?.count ?? 0
            self.btnFilter.isHidden = size <= 0
        }
        
    }
    override func setUpInfo(_ listModel: [JsonModel]?) {
        if !self.isSearching() {
            let size = self.groups?.count ?? 0
            self.btnFilter.isHidden = size <= 0
        }
        super.setUpInfo(listModel)
    }
    
    //override function to calculate height of native ads
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let heightPerItem = rateMovie * widthItemGrid
        return CGSize(width: widthItemGrid, height: heightPerItem)
    }
    
    override func renderModel(cell: UICollectionViewCell, model: JsonModel) {
        let movie = model as! MovieModel
        let cell = cell as! MovieCell
        cell.favDelegate = self.favDelegate
        cell.typeVC = self.typeVC
        cell.updateUI(movie)
    }
    
    override func getUIType() -> UIType {
        return .FlatGrid
    }
    
    @IBAction func filterTap(_ sender: Any) {
        self.setUpGroupPickerView()
    }
    
    private func setUpGroupPickerView(){
        var items:[MenuItem] = []
        let menuTitle = MenuTitle(title: getString(StringRes.title_filter_buy))
        items.append(menuTitle)
        
        var index = 0
        for item in self.groups! {
            let menuItem = MenuItem(title: item, value: index)
            items.append(menuItem)
            index += 1
        }
        let menu = Menu(items: items)
        let sheet = menu.toActionSheet { (sheet, menuItem) in
            if let index = menuItem.value as? Int {
                self.startSearchGroup(index)
            }
        }
        let isPad = Display.pad
        sheet.present(in: self, from: isPad ? self.btnFilter : self.view)
    }
    
    override func startSearch(_ keyword: String, _ isClose: Bool) {
        self.selectGroup = nil
        super.startSearch(keyword, isClose)
    }
    
    private func startSearchGroup(_ index: Int) {
        if self.selectGroup == nil && index == 0 {
            return
        }
        self.selectGroup = index > 0 ? self.groups?[index] : nil
        self.isLoadedData = false
        self.startLoadData()
    }
}


