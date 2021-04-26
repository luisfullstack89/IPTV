//
//  DatabaseManager.swift
//  iLandMusic
//  Created by YPYGlobal on 11/5/19.
//  Copyright © 2019 YPYGlobal. All rights reserved.
//

import Foundation
import SQLite

public class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    var appDatabase: AppDatabase?
    
    init() {
        self.createDB()
    }
    
    private func createDB(){
        self.appDatabase = AppDatabase(dbName: IPTVConstants.DATABASE_NAME)
    }
    
    func onDestroy(){
        self.appDatabase?.close()
        self.appDatabase = nil
    }
    
    func insertBundle(_ bundle: BundleModel) -> Int64 {
        if let insertId = self.appDatabase?.bundleDAO.insert(model: bundle) {
            return insertId
        }
        return -1
    }
    
    func checkMigrate() {
        let isMigrate = self.appDatabase?.checkMigrate() ?? false
        if isMigrate {
            self.onDestroy()
            self.createDB()
        }
    }
    
    func insertM3uModel(_ m3u: M3uModel) -> Int64 {
        if let insertId = self.appDatabase?.m3uDAO.insert(model: m3u) {
            return insertId
        }
        return -1
    }
    
    func getListBunlde() -> [BundleModel]? {
        return self.appDatabase?.bundleDAO?.getListModels(BundleModel.self) as? [BundleModel]
    }
    
    func getListModelFromCache(_ cacheId: Int64, _ type: String) -> [AbstractModel]? {
        return nil
    }
    
    func checkAndAddListModelToCache(_ cacheId: Int64, _ type: String, _ listModels:[AbstractModel]) {
        self.checkAndAddListModelToCache(cacheId, type, "",listModels)
    }
    
    func checkAndAddListModelToCache(_ cacheId: Int64, _ type: String, _ name : String
        , _ listModels:[AbstractModel]) {
        if cacheId != 0 {
            let isCacheExisted = self.checkOrImportCache(cacheId,type,name)
            if isCacheExisted {
                self.clearCacheJoin(cacheId, type)
                self.justAddListModel(cacheId, type, listModels)
                self.updateCacheTimeStamp(cacheId, type)
            }
        }
    }
    
    func justAddListModel(_ cacheId: Int64, _ type: String, _ listModels:[AbstractModel]) {
        for model in listModels {
            var insertId: Int64?
            if model is BundleModel {
                let bundle = model as! BundleModel
                insertId = self.appDatabase?.bundleDAO.insert(model: bundle)
            }
            if insertId != nil {
                let modelCache = CacheJoinModel(cacheId, model.id, type)
                self.appDatabase?.cacheJoinDAO.insert(model: modelCache)
            }
        }
    }
    
    private func checkOrImportCache(_ cacheId: Int64, _ type: String, _ name: String) -> Bool {
        var model = self.getCacheModel(cacheId, type)
        if model == nil {
            model = CacheModel(cacheId,name,type)
            return self.appDatabase?.cacheDAO.insert(model: model!) != 0
        }
        return true
    }
        
    func checkCacheExpired (_ cacheId: Int64, _ type: String, _ deltaTime: Double)-> Bool {
        if let model = self.getCacheModel(cacheId, type) {
            return model.isExpired(deltaTime)
        }
        return false
    }
    
    private func getCacheModel (_ cacheId: Int64, _ type: String) -> CacheModel? {
        if cacheId != 0 && !type.isEmpty {
            return self.appDatabase?.cacheDAO.findById(cacheId,type)
        }
        return nil
    }
    
    private func updateCacheTimeStamp(_ cacheId: Int64, _ type: String) {
        self.updateCacheTimeStamp(cacheId, type, DateTimeUtils.currentTimeMillis())
    }
    
    private func updateCacheTimeStamp(_ cacheId: Int64, _ type: String, _ timeStamp: Double) {
        if cacheId != 0 && !type.isEmpty {
            self.appDatabase?.cacheDAO.updateTimeStamp(cacheId, type,timeStamp)
        }
    }
    
    private func clearCacheJoin(_ cacheId: Int64, _ type: String) {
        if cacheId != 0 && !type.isEmpty {
            self.appDatabase?.cacheJoinDAO.deleteAll(cacheId, type)
        }
        
    }
   
}
