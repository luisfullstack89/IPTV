//
//  CacheJoinDAO.swift
//  iLandMusic
//
//  Created by iLandMusic on 11/5/19.
//  Copyright © 2019 iLandMusic. All rights reserved.
//

import Foundation
import SQLite

class CacheJoinDAO: AbstractDAO<CacheJoinModel> {
    
    public required init() {
        super.init()
    }
    
    init(_ db: Connection){
        super.init(db,"caches_join")
    }
    
    override func createColumns() -> [ColumInfo]? {
        var columns:[ColumInfo] = []
        columns.append(ColumInfo(Expression<Int64>("id"),.autoincrement))
        columns.append(ColumInfo(Expression<Int64>("cache_id")))
        columns.append(ColumInfo(Expression<Int64>("value_id")))
        columns.append(ColumInfo(Expression<String>("type")))
        return columns
    }
    
    func delete(_ cacheId: Int64, _ valueId: Int64,_ type:String) {
        self.delete([["cache_id": cacheId],["value_id": valueId],["type":type]])
    }
    
    func deleteAll (_ cacheId: Int64, _ type:String){
        self.delete([["cache_id": cacheId],["type":type]])
    }
 
    private func getCacheModel(_ prefixQuery: String, _ cacheId: Int64, _ type:String, _ classType: AbstractModel.Type ) -> [AbstractModel]? {
        let query = prefixQuery + " and cj.cache_id = " + String(cacheId) + " and cj.type = '" + type + "'"
        return self.getListModels(query,classType)
    }
}
