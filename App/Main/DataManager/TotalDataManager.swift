//
//  TotalDataManager.swift
//  Created by YPY Global on 3/5/19.
//  Copyright © 2019 YPY Global. All rights reserved.
//

import Foundation

public class TotalDataManager {
    static let shared = TotalDataManager()
    
    var cache: YPYCacheDataModel = YPYCacheDataModel()
    
    init() {
        cache.addSaveMode(IPTVConstants.TYPE_VC_HOME, HomeModel.self)
        cache.addSaveMode(IPTVConstants.TYPE_VC_FAVORITE, MovieModel.self)
        cache.addSaveMode(IPTVConstants.TYPE_VC_GENRE, GenreModel.self)
        cache.addSaveMode(IPTVConstants.TYPE_VC_SERIES, SeriesModel.self)
    }
    
    func getListData(_ id : Int) -> [JsonModel]? {
        if (id == IPTVConstants.TYPE_VC_FAVORITE) {
            updateListCacheFavorite()
        }
        return cache.getListCacheData(id)
    }
    
    func isCacheExisted(_ id : Int) -> Bool {
        return cache.isCacheExisted(id)
    }
    
    func readTypeData (_ id: Int) {
        cache.readCacheData(id)
    }
    
    func onResetBundle() {
        self.setListCacheData(IPTVConstants.TYPE_VC_HOME, [])
        self.setListCacheData(IPTVConstants.TYPE_VC_GENRE, [])
        self.setListCacheData(IPTVConstants.TYPE_VC_SERIES, [])
        
        if let listFav = self.getListData(IPTVConstants.TYPE_VC_FAVORITE) as? [MovieModel] {
            YPYLog.logE("====>before listFav=\(listFav.count)")
            var newFav: [MovieModel] = []
            for model in listFav {
                if model.isM3u {
                    newFav.append(model)
                }
            }
            YPYLog.logE("====>after remove=\(newFav.count)")
            self.setListCacheData(IPTVConstants.TYPE_VC_FAVORITE, newFav)
        }
               
    }
    
    func setListCacheData(_ id: Int, _ listModel: [JsonModel]){
        cache.setListCacheData(id, listModel)
    }
    
    func readCache() {
        self.cache.readAllCache()
        self.updateListCacheFavorite()
    }

    func onDestroy() {
        cache.onDestroy()
    }
    
    func addModelToCache(_ type: Int, _ model: JsonModel){
        addModelToCache(type,0,model)
    }
    func addModelToCache(_ type: Int,_ pos: Int, _ model: JsonModel){
        cache.addModelInCache(type,pos, model)
    }
    
    func removeModelInCache(_ type: Int, _ model: JsonModel) -> Bool {
        return cache.removeModelInCache(type, model)
    }
    
    func saveDataInThread(_ idSaveModel: Int){
        DispatchQueue.global().async {
            self.cache.saveDataCache(idSaveModel)
        }
    }
    
    private func updateListCacheFavorite() {
            if let mListFav = cache.getListCacheData(IPTVConstants.TYPE_VC_FAVORITE)  as? [MovieModel] {
                if mListFav.count>0 {
                    for model in mListFav {
                        model.isFavorite = true
                    }
                }
            }
        }

     func updateFavoriteForList (_ listModels: [MovieModel]?){
         if let listFav = getListData(IPTVConstants.TYPE_VC_FAVORITE) as? [MovieModel] {
             if listFav.count > 0 && listModels != nil && listModels!.count > 0 {
                 for model in listModels! {
                     model.isFavorite = isInFavoriteList(listFav, model)
                 }
             }
         }
         
     }
     
     func isInFavoriteList(_ listModels: [MovieModel]? , _ compare: MovieModel) -> Bool {
         if listModels != nil && listModels!.count > 0 {
             for model in listModels! {
                 if model.equalElement(compare) {
                    return true
                 }
             }
         }
         return false
     }
    
    func updateFavorite(_ model: MovieModel, _ isFav: Bool, _ completion: @escaping (Int64,Bool)->Void ) {
        DispatchQueue.global().async {
            if !isFav {
                let isRemoved = self.removeModelInCache(IPTVConstants.TYPE_VC_FAVORITE, model)
                if isRemoved {
                    model.isFavorite = false
                    DispatchQueue.main.async {
                        completion(model.id, isFav)
                    }
                }
            }
            else{
                if let modelClone = model.copy() {
                    modelClone.isFavorite = true
                    self.addModelToCache(IPTVConstants.TYPE_VC_FAVORITE, modelClone)
                    model.isFavorite = true
                    DispatchQueue.main.async {
                        completion(model.id, isFav)
                    }
                }
            }
        }
    }
    
    
}
