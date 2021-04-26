//
//  AppDatabase.swift
//  iLandMusic
//
//  Created by iLandMusic on 11/6/19.
//  Copyright © 2019 iLandMusic. All rights reserved.
//

import Foundation
import SQLite

class AppDatabase {
    
    private var db: Connection?
    
    var bundleDAO : BundleDAO!
    var m3uDAO : M3uDAO!
    var cacheDAO : CacheDAO!
    var cacheJoinDAO : CacheJoinDAO!
    
    init(dbName: String) {
        if let cacheDirectoryUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            YPYLog.logE("=======>cacheDirectoryUrl=\(cacheDirectoryUrl)")
            if let db = try? Connection("\(cacheDirectoryUrl)/" + dbName) {
                self.db = db
                self.initDAO(db)
            }
        }
    }
    
    private func initDAO(_ db: Connection) {
        self.bundleDAO = BundleDAO(db)
        self.m3uDAO = M3uDAO(db)
        self.cacheDAO = CacheDAO(db)
        self.cacheJoinDAO = CacheJoinDAO(db)
    }
    
    func checkMigrate() -> Bool{
        YPYLog.logE("======>checkMigrate")
        if !SettingManager.getBool(SettingManager.KEY_GROUP_TITLE) {
            let listCols = self.m3uDAO.getColumnNamesFromTable()
            let isHasGroup = listCols?.contains("group_title") ?? false
            YPYLog.logE("======>isHasGroup=\(isHasGroup)")
            if !isHasGroup {
                let isAddNew = self.m3uDAO.addColumn("group_title", "")
                if isAddNew {
                    SettingManager.setBool(SettingManager.KEY_GROUP_TITLE, true)
                    return true
                }
            }
            else{
                SettingManager.setBool(SettingManager.KEY_GROUP_TITLE, true)
            }
        }
        return false
    }
    
    func close() {
        if self.db != nil {
            self.db?.interrupt()
        }
    }
    
}
