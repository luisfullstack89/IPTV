//
//  CacheDAO.swift
//  iLandMusic
//
//  Created by iLandMusic on 11/5/19.
//  Copyright © 2019 iLandMusic. All rights reserved.
//

import Foundation
import SQLite

class CacheDAO: AbstractDAO<CacheModel> {
    
    public required init() {
        super.init()
    }
    
    init(_ db: Connection){
        super.init(db,"caches")
    }
    
    override func createColumns() -> [ColumInfo]? {
        var columns:[ColumInfo] = []
        columns.append(ColumInfo(Expression<Int64>("id"),.autoincrement))
        columns.append(ColumInfo(Expression<Int64>("cache_id")))
        columns.append(ColumInfo(Expression<String>("name")))
        columns.append(ColumInfo(Expression<String>("type")))
        columns.append(ColumInfo(Expression<Double>("time_stamp")))
        return columns
    }
    
    func findById(_ id: Int64, _ type: String) -> CacheModel? {
        if let listModels = self.findListModels([["cache_id": id],["type": type]], 0, 1) {
            return listModels.count > 0 ? listModels[0] : nil
        }
        return nil
    }
    
    func updateTimeStamp(_ id: Int64 ,_ type: String, _ timeStamp:Double) {
        if self.updateWithCondition([["cache_id": id],["type": type]], [["time_stamp": timeStamp]]) {
            YPYLog.logD("====>updateTimeStamp=\(id)==>type=\(type) success")
        }
    }
}
