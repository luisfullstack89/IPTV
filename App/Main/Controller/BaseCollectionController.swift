//
//  BaseCollectionController.swift
//  Created by YPY Global on 4/11/19.
//  Copyright © 2019 YPY Global. All rights reserved.
//

import Foundation
import UIKit

protocol AppItemDelegate{
    func clickItem(list:[JsonModel], model : JsonModel, position: Int)
}
class BaseCollectionController: YPYRootViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblNodata : UILabel!
    @IBOutlet weak var progressBar: UIActivityIndicatorView!
    @IBOutlet weak var footerView: UIView!
    
    @IBOutlet weak var lblMore: UILabel!
    @IBOutlet weak var indicatorMore: UIActivityIndicatorView!
    @IBOutlet weak var bottomHeight: NSLayoutConstraint!
    
    var listModels: [JsonModel]?
    var itemsPerRow = 2
    var sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    let refreshControl = UIRefreshControl()
    
    var itemDelegate: AppItemDelegate?
    
    var typeVC: Int = 0
    var isAllowRefresh = true
    var isAllowLoadMore = false
    var isOfflineData = false
    var isShowHeader = false
    
    var isTab = false
    var isFirstTab = false
    var isAllowReadCache = false
    var isReadCacheWhenNoData = false
    var isAllowAddObserver = true
    
    var maxPage: Int = IPTVConstants.MAX_PAGE
    var numberItemPerPage: Int = Display.pad ? IPTVConstants.IPAD_NUMBER_ITEM_DETAIL_PAGE : IPTVConstants.IPHONE_NUMBER_ITEM_DETAIL_PAGE
    var isLoadedData = false
    
    private var isStartAddingPage = false
    private var currentPage: Int = 0
    private var idCell : String = ""
    private var isAllowAddPage = false
    private var isAddObserver = false
    
    var uiType : UIType = .FlatList
    var totalDataMng = TotalDataManager.shared
    var widthItemGrid : CGFloat = 0.0
    
    let mediumPadding = getDimen(DimenRes.medium_paddings)
    
    override func setUpUI() {
        super.setUpUI()
     
        self.uiType = getUIType()
        self.setUpCollectionView()
        self.setUpRefresh()
    
        self.lblNodata.isHidden =  true
   
        setUpFooterView()
        addObserverForData()
        setUpCustomizeView()
        
        if isFirstTab  || !isTab {
            startLoadData()
        }
    }
    
    func setUpCustomizeView(){
        
    }
    
    func startLoadData() {
        if !isLoadedData {
            isLoadedData = true
            onLoadData(false,true)
        }
    }
    
    func onRefreshData(_ isNeedHide: Bool){
        if !self.progressBar.isHidden {
            hideRefreshUI()
            return
        }
        if isAllowLoadMore && isStartAddingPage {
            hideRefreshUI()
            return
        }
        onLoadData(true,isNeedHide)
    }
    
    func onLoadData(_ isNeedRefresh: Bool,_ isNeedHideCollectView: Bool) {
        if isNeedRefresh {
            onResetDataCollection()
        }
        if isNeedHideCollectView {
            showLoading(true)
        }
        DispatchQueue.global().async {
            var listModels : [JsonModel]?
            var isNeedCheckOnline: Bool = false
            if self.isOfflineData || (!isNeedRefresh && self.isAllowReadCache && self.typeVC > 0 && !ApplicationUtils.isOnline()){
                listModels = self.getDataFromCache()
            }
            if !self.isOfflineData && (listModels == nil || isNeedRefresh) {
                isNeedCheckOnline = true
                self.getListModelFromServer(0,self.numberItemPerPage,{resultModel in
                    if resultModel != nil && resultModel!.isResultOk() {
                        if self.isAllowReadCache && self.typeVC > 0 {
                            self.totalDataMng.setListCacheData(self.typeVC, resultModel!.listModel!)
                            listModels = self.totalDataMng.getListData(self.typeVC)
                        }
                        if listModels == nil || listModels!.count == 0 {
                            listModels = resultModel!.listModel
                        }
                    }
                    else{
                        if self.isReadCacheWhenNoData {
                            listModels = self.getDataFromCache()
                        }
                    }
                    listModels = self.filterListModelsInThread(listModels)
                    DispatchQueue.main.async {
                        self.checkResultModel(resultModel, isNeedCheckOnline, listModels)
                    }
                })
                return
            }
            listModels = self.filterListModelsInThread(listModels)
            DispatchQueue.main.async {
                self.checkResultModel(nil, isNeedCheckOnline, listModels)
            }
            
        }
    }
    
    func filterListModelsInThread(_ listModels: [JsonModel]?) -> [JsonModel]?{
        return listModels
    }
        
    private func onLoadNextModel() {
        showFooterView()
        if self.listModels == nil || self.listModels?.count == 0 {
            self.isStartAddingPage = false
            hideFooterView()
            hideRefreshUI()
            return
        }
        DispatchQueue.global().async {
            let originalSize: Int  = self.listModels!.count
            self.getListModelFromServer(originalSize, self.numberItemPerPage, {resultModel in
                var listLoadMores = resultModel != nil && resultModel!.isResultOk() ? resultModel!.listModel : nil
                let sizeLoaded = listLoadMores != nil ? listLoadMores!.count :0
                let isLoadOkNumberItem = sizeLoaded >= self.numberItemPerPage
                listLoadMores = self.filterListModelsInThread(listLoadMores)
                
                DispatchQueue.main.async {
                    self.hideFooterView()
                    self.hideRefreshUI()
                    self.isAllowAddPage =  isLoadOkNumberItem && (self.maxPage == 0 || self.currentPage < self.maxPage)
                    if self.isAllowAddPage {
                        self.currentPage += 1
                    }
                    if sizeLoaded > 0 {
                        for model in listLoadMores! {
                            self.listModels!.append(model)
                        }
                        self.collectionView.reloadData()
                    }
                    self.isStartAddingPage = false
                }
                
            })
        }
        
    }
    
    
    func getListModelFromServer(_ offset: Int, _ limit: Int, _ completion: @escaping (ResultModel?)->Void){
        
    }
    
    private func checkResultModel(_ resultModel: ResultModel?, _ isNeedCheckOnline: Bool, _ listModel:[JsonModel]?){
        showLoading(false)
        hideRefreshUI()
        if isNeedCheckOnline && (resultModel == nil || !resultModel!.isResultOk()){
            if isReadCacheWhenNoData {
                self.setUpInfo(listModel)
                return
            }
            let msg = resultModel != nil && ApplicationUtils.isOnline() ? resultModel!.msg : getString(StringRes.title_no_data)
            if(!msg.isEmpty){
                self.showResult(msg)
                return
            }
            let msgId = !ApplicationUtils.isOnline() ? StringRes.info_lose_internet : getString(StringRes.title_no_data)
            self.showResult(withResId: msgId)
            return
        }
        setUpInfo(listModel)
        
        
    }
    
    func updateInfo() {
        let size = self.listModels?.count ?? 0
        self.lblNodata.isHidden = size > 0
    }
    
    func getUIType() -> UIType {
        return .FlatList
    }
  
    func setUpRefresh(){
        if(isAllowRefresh){
            self.refreshControl.tintColor = getColor(hex: ColorRes.color_pull_to_refresh)
            self.refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
            self.collectionView.refreshControl = refreshControl
        }
    }
    
    @objc private func pullToRefresh() {
        onRefreshData(false)
    }

    
    private func onResetDataCollection(){
        isAllowAddPage = false
        isStartAddingPage = false
        currentPage = 0
    }
    
    private func setUpFooterView() {
        if (self.footerView != nil) {
            self.hideFooterView()
        }
    }
    
    private func hideFooterView () {
        if (self.footerView != nil) {
            if !self.footerView.isHidden {
                self.indicatorMore.stopAnimating()
                self.bottomHeight.constant = 0
                self.footerView.isHidden = true
                self.footerView.layoutIfNeeded()
            }
        }
        
    }
    private func showFooterView () {
        if (self.footerView != nil) {
            if self.footerView.isHidden {
                self.bottomHeight.constant = 54
                self.footerView.isHidden = false
                self.footerView.layoutIfNeeded()
                self.indicatorMore.startAnimating()
            }
        }
    }
    
    private func checkAllowLoadMore(_ sizeLoaded: Int) -> Bool {
        let page: Int = Int(CGFloat(sizeLoaded) / CGFloat(numberItemPerPage))
        if sizeLoaded >= numberItemPerPage && (maxPage == 0 || page < maxPage){
            return true
        }
        return false
    }
    
    func setUpInfo(_ listModel: [JsonModel]?){
        if self.listModels != nil {
            self.listModels!.removeAll()
        }
        self.listModels = listModel
        if listModel != nil && listModel!.count>0 {
            self.collectionView.isHidden = false
            self.collectionView.reloadData()
            if isAllowLoadMore {
                self.isAllowAddPage = checkAllowLoadMore(listModel!.count)
            }
        }
        else {
            self.lblNodata.isHidden = false
            self.collectionView.isHidden = false
            self.collectionView.reloadData()
                    
        }
    }
    
    func hideRefreshUI() {
        if self.refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
        }
    }
 
    @objc func onBroadcastDataChanged(notification:Notification) -> Void {
        guard let typeVC: Int = notification.userInfo![IPTVConstants.KEY_VC_TYPE] as? Int else {
            notifyWhenDataChanged()
            return
        }
        if self.typeVC == typeVC {
            notifyWhenDataChanged()
            return
        }
        guard let id: Int64 = notification.userInfo![IPTVConstants.KEY_ID] as? Int64 else {
            notifyWhenDataChanged()
            return
        }
        guard let isFav: Bool = notification.userInfo![IPTVConstants.KEY_IS_FAV] as? Bool else {
            notifyWhenDataChanged()
            return
        }
        let isM3u: Bool = notification.userInfo![IPTVConstants.KEY_IS_M3U] as? Bool ?? false
        DispatchQueue.global().async {
            if self.listModels != nil && self.listModels!.count > 0 {
                guard let indexItem: Int = self.listModels!.firstIndex(where: {
                    let model: MovieModel = ($0 as? MovieModel)!
                    return model.id == id && model.isM3u == isM3u
                }) else{
                    return
                }
                DispatchQueue.main.async {
                    let radioModel = self.listModels![indexItem] as? AbstractModel
                    radioModel!.isFavorite = isFav
                    self.notifyWhenDataChanged()
                }
            }
        }
        
    }
   
    
    func getIDCellOfCollectionView () -> String {
        return ""
    }
    
    func notifyWhenDataChanged () {
        self.collectionView.reloadData()
    }
    
    private func setUpCollectionView(){
        let idCell: String = getIDCellOfCollectionView()
        if(!idCell.isEmpty){
            collectionView.register(UINib(nibName: idCell, bundle: nil), forCellWithReuseIdentifier: idCell)
        }
        self.idCell = idCell
        self.setUpUIType()
    }
    
    private func setUpUIType(){
        self.sectionInsets.left = uiType == .FlatList ? 0.0 : mediumPadding
        self.sectionInsets.right = uiType == .FlatList ? 0.0 : mediumPadding
        self.sectionInsets.top = uiType == .FlatList ? 0.0 : mediumPadding
        self.sectionInsets.bottom = uiType == .FlatList ? 0.0 : mediumPadding
        if uiType == .FlatGrid || uiType == .CardGrid {
            let paddingSpace = sectionInsets.left * CGFloat(itemsPerRow + 1)
            let availableWidth = view.frame.width - paddingSpace
            self.widthItemGrid = floor(availableWidth / CGFloat(itemsPerRow))
        }
    }
    
    func renderModel(cell: UICollectionViewCell, model: JsonModel) {
        let cell = cell as! YPYAbstractCell
        cell.updateUI(model)
    }

    func getDataFromCache () -> [JsonModel]? {
        return getDataFromCache(typeVC)
    }
    
    func getDataFromCache (_ type: Int) -> [JsonModel]? {
        var mListModels = self.totalDataMng.getListData(type)
        if mListModels == nil {
            totalDataMng.readTypeData(type)
            mListModels = self.totalDataMng.getListData(type)
        }
        return mListModels
    }
    
    func showLoading (_ isShow: Bool) {
        self.progressBar.isHidden = !isShow
        if(isShow){
            self.progressBar.startAnimating()
            self.lblNodata.isHidden = true
            self.collectionView.isHidden = true
        }
        else{
            self.progressBar.stopAnimating()
        }
    }
    
    func showResult( withResId: String){
        showResult(getString(withResId))
    }
    
    func showResult(_ msg: String){
        self.lblNodata.text = msg
        if self.listModels != nil && self.listModels!.count > 0  {
            self.lblNodata.isHidden = true
            self.showToast(with: msg)
        }
        else{
            self.lblNodata.isHidden = false
        }
        
    }
   
    private func addObserverForData () {
        if isAllowAddObserver {
            if !isAddObserver {
                isAddObserver = true
                NotificationCenter.default.addObserver(self, selector: #selector(onBroadcastDataChanged(notification:)), name: NSNotification.Name(rawValue: IPTVConstants.BROADCAST_DATA_CHANGE), object: nil)
            }
        }
        
    }
    
    func removeObserverForData() {
        if isAddObserver {
            isAddObserver  = false
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    func convertListModelToResult(_ list: [JsonModel]?) -> ResultModel {
        let size = list?.count ?? -1
        let resultModel = ResultModel(size >= 0 ? 200 : -1, size >= 0 ? "success" : "Error")
        resultModel.listModel = list
        return resultModel
    }

}

extension BaseCollectionController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.listModels != nil ? self.listModels!.count : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.idCell, for: indexPath)
        if self.listModels != nil {
            let item = self.listModels![indexPath.row]
            renderModel(cell: cell, model: item)
        }
        return cell
        
       
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pos: Int = indexPath.row
        if self.listModels != nil {
            let item = self.listModels![pos]
            self.itemDelegate?.clickItem(list: listModels!, model: item, position: pos)
        }
    }
    
    
}

extension BaseCollectionController: UICollectionViewDelegateFlowLayout{
    @objc(collectionView:layout:sizeForItemAtIndexPath:)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch uiType {
        case .FlatList, .CardList:
            itemsPerRow = 1
            let paddingSpace = sectionInsets.left * CGFloat(itemsPerRow + 1)
            let availableWidth = view.frame.width - paddingSpace
            let widthPerItem = availableWidth / CGFloat(itemsPerRow)
            let sizeHeight = getDimen(uiType == .CardList ? DimenRes.row_card_list_height_sizes : DimenRes.row_list_height_sizes)
            return CGSize(width: widthPerItem, height: sizeHeight)
        case .CardGrid, .FlatGrid:
            return CGSize(width: widthItemGrid, height: widthItemGrid)
        default:
            return CGSize(width: 0, height: 0)
        }
        
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
        if uiType == .FlatList{
            return 0
        }
        return mediumPadding
    }
    
    @objc(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if uiType == .FlatList{
            return 0
        }
        return mediumPadding
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let item = indexPath.item
        if self.listModels != nil {
            let count = self.listModels!.count
            if item == count - 1 && isAllowAddPage {
                if !isStartAddingPage {
                    isStartAddingPage = true
                    onLoadNextModel()
                }
            }
        }
        
    }
    
    func deleteModel(_ model: JsonModel){
        if self.listModels != nil && self.listModels!.count > 0{
            guard let indexItem: Int = self.listModels!.firstIndex(where: {
                return $0.equalElement(model)
            }) else{
                return
            }
            self.listModels!.remove(at: indexItem)
            self.notifyWhenDataChanged()
            if !self.isShowHeader {
                self.updateInfo()
            }
        }
    }
    
}





