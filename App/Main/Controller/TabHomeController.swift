//
//  HomeController.swift
//  Created by YPY Global on 4/11/19.
//  Copyright © 2019 YPY Global. All rights reserved.
//

import Foundation
import UIKit

class TabHomeController: YPYRootViewController {
    
    @IBOutlet weak var lblNodata : UILabel!
    @IBOutlet weak var progressBar: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var stackFeatured: UIStackView!
    @IBOutlet weak var collectionFeatured: UICollectionView!
    @IBOutlet weak var constraintHeightFeatured: NSLayoutConstraint!
    @IBOutlet weak var btnMoreFeatured: AutoFillButton!
    
    @IBOutlet weak var stackNewest: UIStackView!
    @IBOutlet weak var collectionNewest: UICollectionView!
    @IBOutlet weak var constraintHeightNewest: NSLayoutConstraint!
    @IBOutlet weak var btnMoreNew: AutoFillButton!
    
    @IBOutlet weak var stackSeries: UIStackView!
    @IBOutlet weak var collectionSeries: UICollectionView!
    @IBOutlet weak var constraintHeightSeries: NSLayoutConstraint!
    @IBOutlet weak var btnMoreSeries: AutoFillButton!
    
    @IBOutlet weak var stackGenres: UIStackView!
    @IBOutlet weak var collectionGenres: UICollectionView!
    @IBOutlet weak var constraintHeightGenres: NSLayoutConstraint!
    @IBOutlet weak var btnMoreGenre: AutoFillButton!
    let refreshControl = UIRefreshControl()
    
    var itemDelegate: AppItemDelegate?
    var itemIdDelegate: ItemIdDelegate?
    
    var itemsPerRow: CGFloat = 2.5
    
    var isLoadedData = false
    var homeData: HomeModel?
    var totalDataMng = TotalDataManager.shared
    
    let movieCell = String(describing: MovieCell.self)
    let serieCell = String(describing: SerieCell.self)
    let genreCell = String(describing: GenreCell.self)
    
    let mediumPadding = getDimen(DimenRes.medium_paddings)
    var sectionInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    var cellWidth: CGFloat = 0.0
    
    var genreHeight: CGFloat = 0.0
    var movieHeight: CGFloat = 0.0
    var serieHeight: CGFloat = 0.0
    var favDelegate: FavoriteDelegate?
    
    override func setUpUI() {
        super.setUpUI()
        self.sectionInsets.left = mediumPadding
        self.sectionInsets.right = mediumPadding
        self.scrollView.isHidden = true
        
        self.setUpRefresh()
        
        self.collectionFeatured.register(UINib(nibName: movieCell, bundle: nil), forCellWithReuseIdentifier: movieCell)
        self.collectionNewest.register(UINib(nibName: movieCell, bundle: nil), forCellWithReuseIdentifier: movieCell)
        self.collectionSeries.register(UINib(nibName: serieCell, bundle: nil), forCellWithReuseIdentifier: serieCell)
        self.collectionGenres.register(UINib(nibName: genreCell, bundle: nil), forCellWithReuseIdentifier: genreCell)
        self.startLoadData()
    }
    
    override func updateCustomizeViewConstraint() {
        super.updateCustomizeViewConstraint()
        let width = self.view.frame.width - 4 * self.mediumPadding
        self.cellWidth = width / itemsPerRow
        
        let rateMovie = getDimen(DimenRes.rate_movies)
        self.movieHeight = ceil(rateMovie * self.cellWidth) + 1
        self.serieHeight = ceil(rateMovie * self.cellWidth) + 1
        
        self.genreHeight = IPTVConstants.RATE_4_3 * self.cellWidth
        
        self.constraintHeightFeatured.constant = self.movieHeight
        self.collectionFeatured.layoutIfNeeded()
        
        self.constraintHeightNewest.constant = self.movieHeight
        self.collectionNewest.layoutIfNeeded()
        
        self.constraintHeightSeries.constant = self.serieHeight
        self.collectionSeries.layoutIfNeeded()
        
        self.constraintHeightGenres.constant = self.genreHeight
        self.collectionGenres.layoutIfNeeded()
    }
    
    
  
    func startLoadData() {
        YPYLog.logE("=======>startLoadData=\(self.isLoadedData)")
        if !self.isLoadedData {
            self.isLoadedData = true
            self.onLoadData(false,true)
        }
    }
    
    func onLoadData(_ isNeedRefresh: Bool,_ isNeedHide: Bool) {
        let url = SettingManager.getUrlEnpoint()
        if url.isEmpty {
            self.hideRefreshUI()
            self.setUpUI(nil)
            return
        }
        if isNeedHide {
            self.showLoading(true)
        }
        DispatchQueue.global().async {
            var listModels : [HomeModel]?
            if !ApplicationUtils.isOnline() {
                listModels = self.totalDataMng.getListData(IPTVConstants.TYPE_VC_HOME) as? [HomeModel]
            }
            if ((listModels == nil || isNeedRefresh) && ApplicationUtils.isOnline()) {
                IPTVNetUtils.getIpTvHome(0,IPTVConstants.MAX_ITEM_HOME_PAGE) { (result) in
                    if let home = result?.getFirstModel() as? HomeModel {
                        home.updateFavorite()
                        self.totalDataMng.setListCacheData(IPTVConstants.TYPE_VC_HOME, result!.listModel!)
                        self.setUpUI(home)
                    }
                    else{
                        let listCache = self.totalDataMng.getListData(IPTVConstants.TYPE_VC_HOME) as? [HomeModel]
                        let size = listCache?.count ?? 0
                        let model = size > 0 ? listCache![0] : nil
                        model?.updateFavorite()
                        self.setUpUI(model)
                    }
                }
                return
            }
            let size = listModels?.count ?? 0
            let model = size > 0 ? listModels![0] : nil
            model?.updateFavorite()
            DispatchQueue.main.async {
                self.setUpUI(model)
            }
        }
    }

    
    func showLoading(_ isShow: Bool){
        self.progressBar.isHidden = !isShow
        if isShow {
            self.scrollView.isHidden = true
            self.lblNodata.isHidden = true
            self.progressBar.startAnimating()
        }
        else{
            self.progressBar.stopAnimating()
        }
        
    }
    
    func setUpUI(_ data: HomeModel?){
        self.hideRefreshUI()
        self.showLoading(false)
        self.homeData?.onDestroy()
        self.homeData = data
        let isHavingData = data?.havingData() ?? false
        
        self.scrollView.isHidden = !isHavingData
        self.lblNodata.isHidden = isHavingData
        
        //update stack view
        self.updateStackView(self.stackFeatured, self.collectionFeatured,self.btnMoreFeatured, self.homeData?.featuredMovies)
        self.updateStackView(self.stackNewest, self.collectionNewest,self.btnMoreNew, self.homeData?.newestMovies)
        self.updateStackView(self.stackSeries, self.collectionSeries,self.btnMoreSeries, self.homeData?.series)
        self.updateStackView(self.stackGenres, self.collectionGenres,self.btnMoreGenre, self.homeData?.genres)
        
    }
    

    private func getIDCell(_ collectionView: UICollectionView) -> String {
        if collectionView == self.collectionGenres {
            return self.genreCell
        }
        else if collectionView == self.collectionSeries {
            return self.serieCell
        }
        return self.movieCell
    }
    
    private func getListModel(_ collectionView: UICollectionView) -> [AbstractModel]? {
        if collectionView == self.collectionGenres {
            return self.homeData?.genres
        }
        else if collectionView == self.collectionFeatured {
            return self.homeData?.featuredMovies
        }
        else if collectionView == self.collectionSeries {
            return self.homeData?.series
        }
        else if collectionView == self.collectionNewest {
            return self.homeData?.newestMovies
        }
        return nil
    }
    
    private func updateStackView(_ stackView: UIStackView,_ collection: UICollectionView, _ btnMore: UIButton, _ lists: [AbstractModel]?){
        let size = lists?.count ?? 0
        collection.reloadData()
        stackView.isHidden = size <= 0
        btnMore.isHidden = size < IPTVConstants.MAX_ITEM_HOME_PAGE
    }
    
    func renderModel(cell: UICollectionViewCell, model: AbstractModel, pos: Int) {
        if model is SeriesModel {
            let serie = model as! SeriesModel
            let cell = cell as! SerieCell
            cell.updateUI(serie)
        }
        else if model is GenreModel {
            let genre = model as! GenreModel
            let cell = cell as! GenreCell
            cell.updateUI(genre,pos)
        }
        else{
            let movie = model as! MovieModel
            let cell = cell as! MovieCell
            cell.favDelegate = self.favDelegate
            cell.typeVC = IPTVConstants.TYPE_VC_HOME
            cell.updateUI(movie)
        }
    }
    
    func getCellSize(_ collection: UICollectionView) -> CGSize {
        if collection == self.collectionGenres {
            return CGSize(width: self.cellWidth, height: self.genreHeight)
        }
        else if collection == self.collectionSeries {
            return CGSize(width: self.cellWidth, height: self.serieHeight)
        }
        return CGSize(width: self.cellWidth, height: self.movieHeight)
    }
    
    @IBAction func featuredMoreTap(_ sender: Any) {
        self.itemIdDelegate?.onItemIdClick(IPTVConstants.ID_MORE_FEATURED)
    }
    
    @IBAction func moreNewTap(_ sender: Any) {
        self.itemIdDelegate?.onItemIdClick(IPTVConstants.ID_MORE_NEWEST)
    }
    @IBAction func moreSerieTap(_ sender: Any) {
        self.itemIdDelegate?.onItemIdClick(IPTVConstants.ID_MORE_SERIES)
    }
    @IBAction func moreGenreTap(_ sender: Any) {
        self.itemIdDelegate?.onItemIdClick(IPTVConstants.ID_MORE_GENRE)
    }
    
    func setUpRefresh(){
        self.refreshControl.tintColor = getColor(hex: ColorRes.color_pull_to_refresh)
        self.refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        self.scrollView.refreshControl = self.refreshControl
    }
    
    @objc private func pullToRefresh() {
        self.onLoadData(true, false)
    }
    
    func hideRefreshUI() {
        if self.refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
        }
    }
    
    func updateFavorite(_ model: MovieModel, _ isFav: Bool) {
        DispatchQueue.global().async {
            let indexFeatured: Int = self.homeData?.featuredMovies?.firstIndex(where: {return $0.equalElement(model)})  ?? -1
            if indexFeatured >= 0 {
                self.homeData?.featuredMovies?[indexFeatured].isFavorite = isFav
            }
            let indexNew: Int = self.homeData?.newestMovies?.firstIndex(where: {return $0.equalElement(model)})  ?? -1
            if indexNew >= 0 {
                self.homeData?.newestMovies?[indexNew].isFavorite = isFav
            }
            DispatchQueue.main.async {
                if indexFeatured >= 0 {
                    self.collectionFeatured.reloadData()
                }
                if indexNew >= 0 {
                    self.collectionNewest.reloadData()
                }
            }
        }
    }
}

extension TabHomeController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let listModel = self.getListModel(collectionView)
        return listModel?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let idCell = self.getIDCell(collectionView)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: idCell, for: indexPath)
        let listModel = self.getListModel(collectionView)
        let size = listModel?.count ?? 0
        if size > 0 && indexPath.row < size {
            let item = listModel![indexPath.row]
            renderModel(cell: cell, model: item, pos: indexPath.row)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pos: Int = indexPath.row
        let listModel = self.getListModel(collectionView)
        let size = listModel?.count ?? 0
        if size > 0 && indexPath.row < size {
            let item = listModel![indexPath.row]
            self.itemDelegate?.clickItem(list: listModel!, model: item, position: pos)
        }
    }
    
    
    
}

extension TabHomeController: UICollectionViewDelegateFlowLayout{
    @objc(collectionView:layout:sizeForItemAtIndexPath:)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.getCellSize(collectionView)
        
    }
    
    @objc(collectionView:layout:insetForSectionAtIndex:)
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    @objc(collectionView:layout:minimumLineSpacingForSectionAtIndex:)
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return mediumPadding
    }
    
    @objc(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    
}
