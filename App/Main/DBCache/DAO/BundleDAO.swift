//
//  BundleDAO.swift
//  iptv-pro
//
//  Created by YPY Global on 8/14/20.
//  Copyright © 2020 YPY Global. All rights reserved.
//

import Foundation
import SQLite

class BundleDAO: AbstractDAO<BundleModel> {
    
    public required init() {
        super.init()
    }
    
    init(_ db: Connection){
        super.init(db,"bundles")
    }
    
    override func createColumns() -> [ColumInfo]? {
        var columns: [ColumInfo] = []
        columns.append(ColumInfo(Expression<Int64>("id"),.autoincrement,true))
        columns.append(ColumInfo(Expression<String>("name")))
        columns.append(ColumInfo(Expression<String>("uri")))
        columns.append(ColumInfo(Expression<String>("api_key")))
        columns.append(ColumInfo(Expression<String>("sha1")))
        columns.append(ColumInfo(Expression<Int64>("is_m3u")))
        columns.append(ColumInfo(Expression<String>("version_code")))
        return columns
    }
    
    func getBundleWithUri(_ uri: String) -> BundleModel? {
        if !uri.isEmpty {
            if let list  = self.findListModels([["uri":uri]], 0, 1) {
                return list.count > 0 ? list[0] : nil
            }
        }
        return nil
    }
    
}
