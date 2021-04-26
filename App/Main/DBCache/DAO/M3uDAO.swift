//
//  M3uDAO.swift
//  iptv-pro
//
//  Created by YPY Global on 8/19/20.
//  Copyright © 2020 YPY Global. All rights reserved.
//

import Foundation
import SQLite

class M3uDAO: AbstractDAO<M3uModel> {
    
    public required init() {
        super.init()
    }
    
    init(_ db: Connection){
        super.init(db,"m3u_movies")
    }
    
    override func createColumns() -> [ColumInfo]? {
        var columns: [ColumInfo] = []
        columns.append(ColumInfo(Expression<Int64>("id"),.autoincrement,true))
        columns.append(ColumInfo(Expression<String>("name")))
        columns.append(ColumInfo(Expression<String>("img")))
        columns.append(ColumInfo(Expression<String>("uri")))
        columns.append(ColumInfo(Expression<Int64>("duration")))
        columns.append(ColumInfo(Expression<Int64>("bundle_id")))
        columns.append(ColumInfo(Expression<String>("created_date")))
        columns.append(ColumInfo(Expression<String>("group_title")))
        return columns
    }
    func deleteAllWithBundleId(_ bundleId: Int64) {
        if bundleId != 0 {
            self.delete([["bundle_id" : bundleId]])
        }
    }
    
    func getMoviesOfGroup(_ bundleId: Int64, _ group: String, _ offset: Int, _ limit: Int) -> [MovieModel]? {
        var queryAll =  "select * from \(nameTable) where bundle_id = \(bundleId) and group_title = '\(group)'"
        queryAll += " order by id DESC limit \(offset) , \(limit)"
        if let listModels = getListModels(queryAll,M3uModel.self) as? [M3uModel] {
            var newList: [MovieModel] = []
            for item in listModels {
                newList.append(item.convertToMovieModel())
            }
            return newList
        }
        return nil
    }
    
    func getMovies(_ bundleId: Int64, _ offset: Int, _ limit: Int, _ q : String? = nil) -> [MovieModel]? {
        var queryAll =  "select * from \(nameTable) where bundle_id = \(bundleId)"
        if q != nil && !q!.isEmpty {
            let formatKey = "%" + q!.replacingOccurrences(of: "'", with: "\'") + "%"
            queryAll += " and (name like '\(formatKey)' or group_title like '\(formatKey)')"
        }
        queryAll += " order by id DESC limit \(offset) , \(limit)"
        if let listModels = getListModels(queryAll,M3uModel.self) as? [M3uModel] {
            var newList: [MovieModel] = []
            for item in listModels {
                newList.append(item.convertToMovieModel())
            }
            return newList
        }
        return nil
    }
    
    func getGroups(_ bundleId: Int64) -> [String]? {
        let queryAll =  "select * from \(nameTable) where bundle_id = \(bundleId) and group_title != '' GROUP BY group_title order by group_title ASC"
        if let listModels = getListModels(queryAll,M3uModel.self) as? [M3uModel] {
            var newList: [String] = []
            for item in listModels {
                newList.append(item.group)
            }
            return newList
        }
        return nil
    }
    
}
