//
//  AbstractDAO.swift
//  iLandMusic
//
//  Created by YPYGlobal on 11/5/19.
//  Copyright © 2019 YPYGlobal. All rights reserved.
//

import Foundation
import SQLite

class AbstractDAO<T: AbstractModel>: NSObject {
    
    var db: Connection?
    var nameTable = ""
    var table: Table?
    var columns: [ColumInfo]?
    
    required override init() {
        super.init()
    }
    
    init(_ db: Connection, _ nameTable: String){
        super.init()
        self.db = db
        self.nameTable = nameTable
        self.table = Table(self.nameTable)
        self.columns = self.createColumns()
        self.createTable()
    }
    
    func createColumns() ->  [ColumInfo]? {
        var columns: [ColumInfo] = []
        columns.append(ColumInfo(Expression<Int64>("id"),.default))
        columns.append(ColumInfo(Expression<String>("name")))
        columns.append(ColumInfo(Expression<String>("img")))
        return columns
    }
    
    func getColumnInfo(_ name: String) -> ColumInfo? {
        if self.isConnectedDb() {
            for column in self.columns! {
                if let nameCheck = column.getColumnName() {
                    if nameCheck.elementsEqual(name) {
                        return column
                    }
                }
            }
        }
        return nil
    }
    
    func getSQLSetter(_ name: String, _ value: Any?) -> SQLite.Setter? {
        if let columnInfo = self.getColumnInfo(name) {
            return columnInfo.getSQLSetter(value: value)
        }
        return nil
    }
    
    private func isConnectedDb() -> Bool {
        return self.columns != nil && self.columns!.count > 0 && self.db != nil
    }
    
    @discardableResult
    func insert(listModels: [T]) -> [Int64] {
        if self.isConnectedDb() {
            var rows: [Int64] = []
            for model in listModels {
                let id = self.insert(model: model)
                if id > 0 {
                    rows.append(id)
                }
            }
            return rows
        }
        return []
    }
    
    @discardableResult
    func insert(model: T) -> Int64 {
        if self.isConnectedDb(), let dict = model.createDictToSave() {
            var setters: [SQLite.Setter] = []
            for (key, value) in dict {
                if let column = self.getColumnInfo(key) {
                    if let setter = column.getSQLSetter(value: value) {
                        setters.append(setter)
                    }
                }
            }
            if setters.count > 0 {
                if let sqlInsert = self.table?.insert(or : SQLite.OnConflict.replace, setters) {
                    if let rowid = try? self.db?.run(sqlInsert) {
                        return rowid
                    }
                }
            }
        }
        return -1
    }
    
    //return number of update row
    @discardableResult
    func update(listModels: [T]) -> Int {
        if self.isConnectedDb() {
            var numberUpdate: Int  = 0
            for model in listModels {
                let numRow = self.update(model: model)
                if numRow > 0 {
                    numberUpdate += numRow
                }
            }
            return numberUpdate
        }
        return 0
    }
    
    
    //return number of update row
    @discardableResult
    func update(model: T) -> Int  {
        if self.isConnectedDb(), let dict = model.createDictToSave() {
            var setters: [SQLite.Setter] = []
            for colum in self.columns! {
                if let columnName = colum.getColumnName() {
                    if let setter = self.getSQLSetter(columnName,dict[columnName] as Any) {
                        setters.append(setter)
                    }
                }
            }
            if setters.count > 0 {
                if let sqlUpdate = self.table?.update(setters) {
                    if let rowid = try? self.db?.run(sqlUpdate) {
                        return rowid
                    }
                }
            }
        }
        return 0
    }

    
    //return the row deleted
    @discardableResult
    func delete(_ id: Int64) -> Int {
        if self.isConnectedDb()  {
            if let ids = self.columns?[0].type as? Expression<Int64> {
                if let dbModel = self.table?.filter(ids == id) {
                    if let rowid = try? self.db?.run(dbModel.delete()) {
                       return rowid
                   }
                }
            }
        }
        return 0
    }
    @discardableResult
    func delete(_ queries: [[String:Any]]) -> Int {
        if let filter = self.createFilterFromDict(queries) {
            if let query = self.table?.filter(filter) {
                if let rowid = try? self.db?.run(query.delete()) {
                    return rowid
                }
            }
        }
        return 0
    }
    
    //just add for existing table with new colum, not accept primary key, unique same
    func addColumn<T: Value>(_ colName: String, _ defaultVal: T) -> Bool {
        if self.isConnectedDb()  {
            let col = Expression<T>(colName)
            let addCol =  self.table?.addColumn(col, check: nil, defaultValue: defaultVal)
            if addCol != nil && !addCol!.isEmpty {
                if (try? self.db?.run(addCol!)) != nil {
                    return true
                }
            }
        }
        return false
    }
    
    private func createTable() {
        if self.isConnectedDb()  {
            let create = self.table?.create(temporary: false, ifNotExists: true,withoutRowid: false,block: { t in
                for colum in self.columns! {
                    if colum.type is Expression<Int64>{
                        if colum.primaryKey != nil {
                            t.column(colum.type as! Expression<Int64>, primaryKey: colum.primaryKey!)
                        }
                        else{
                            t.column(colum.type as! Expression<Int64>, unique: colum.isUnique!)
                        }
                    }
                    else if colum.type is Expression<Double>{
                        t.column(colum.type as! Expression<Double>, unique: colum.isUnique!)
                    }
                    else if colum.type is Expression<String>{
                        t.column(colum.type as! Expression<String>, unique: colum.isUnique!)
                    }
                  }

            })
            if create != nil && !create!.isEmpty {
                if (try? self.db?.run(create!)) != nil {
                    return
                }
            }
        }
          
    }
    @discardableResult
    func update(_ id: Int64, _ values: [[String:Any]]) -> Bool {
        if let columnTypeId = self.getColumnInfo("id")?.type as? Expression<Int64> {
            var setters: [SQLite.Setter] = []
            for value in values {
                if let setter = self.getSQLSetter(value.keys.first!, value.values.first!) {
                    setters.append(setter)
                }
            }
            if let model = self.table?.filter(columnTypeId == id) {
                if let rowId = try? self.db?.run(model.update(setters)) {
                    return rowId > 0
                }
            }
        }
        return false
        
    }
    
    @discardableResult
    func updateWithCondition(_ queries: [[String:Any]], _ values: [[String:Any]]) -> Bool {
        if let filter = self.createFilterFromDict(queries) {
            var setters: [SQLite.Setter] = []
            for value in values {
              if let setter = self.getSQLSetter(value.keys.first!, value.values.first!) {
                  setters.append(setter)
              }
            }
            if let model = self.table?.filter(filter) {
              if let rowId = try? self.db?.run(model.update(setters)) {
                  return rowId > 0
              }
            }
        }
        return false
        
    }
    
    func updateCount(_ id: Int64, _ values: [[String:Int64]]) {
        if let columnTypeId = self.getColumnInfo("id")?.type as? Expression<Int64> {
            if let model = self.table?.filter(columnTypeId == id) {
                try? self.db?.transaction {
                    for value in values {
                        if let columnType = self.getColumnInfo(value.keys.first!)?.type as? Expression<Int64> {
                            try self.db?.run(model.update(columnType += value.values.first!))
                        }
                    }
                }
            }
        }
    }

    private func createFilterFromDict(_ queries: [[String:Any]]) -> Expression<Bool>? {
        if self.isConnectedDb()  {
            var filter: Expression<Bool>?
            for value in queries {
                if let column = self.getColumnInfo(value.keys.first!) {
                    if let newFilter = column.createFilter(value: value.values.first!) {
                        if filter != nil {
                            filter = newFilter && filter!
                        }
                        else{
                            filter = newFilter
                        }
                    }
                }
            }
            return filter
        }
        return nil

    }
    
    func findListModels(_ queries: [[String:Any]], _ offset: Int, _ limit: Int) -> [T]?{
        if let filter = self.createFilterFromDict(queries) {
            if let query = self.table?.filter(filter).limit(limit, offset: offset) {
                if let rows = try? self.db?.prepare(query) {
                    var listModels :[T] = []
                    for row in rows {
                        if let model = self.createModelFromRow(row: row) {
                            listModels.append(model)
                        }
                    }
                    return listModels
                }
            }
        }
        return nil

    }
    
    func createModelFromRow(row: Row) -> T? {
        if let dict = self.createDictFromRow(row: row) {
            let model = T.init()
            model.initFromDict(dict)
            return model
        }
        return nil
    }
    
    private func createDictFromRow(row: Row) -> [String: Any]? {
        var dict: [String: Any] = [:]
        for colum in self.columns! {
            if let value = colum.getValue(row) {
                if let name = colum.getColumnName() {
                    dict[name] = value
                }
            }
        }
        return dict
    }
    
    func getListModels (_ classType: AbstractModel.Type) -> [AbstractModel]?{
        if !nameTable.isEmpty {
            let queryAll =  "select * from " + nameTable + " order by id DESC"
            return getListModels(queryAll,classType)
        }
        return nil
    }
    
    func getListModels (_ singleQuery: String, _ classType: AbstractModel.Type) -> [AbstractModel]?{
        if self.isConnectedDb() {
            if let stmt = try? self.db?.prepare(singleQuery) {
                var listModels :[AbstractModel] = []
                for row in stmt {
                    var dict: [String: Any] = [:]
                    for (index, name) in stmt.columnNames.enumerated() {
                        dict[name] = row[index]!
                    }
                    let model = classType.init()
                    model.initFromDict(dict)
                    listModels.append(model)
                }
                return listModels
            }
        }
        return nil
    }
    
    func getColumnNamesFromTable()-> [String]?{
        if self.isConnectedDb() {
            let singleQuery = "PRAGMA table_info(\(self.nameTable))"
            if let stmt = try? self.db?.prepare(singleQuery) {
                var listNames :[String] = []
                for row in stmt {
                    if let colName = row[1] as? String{
                        listNames.append(colName)
                    }
                }
                return listNames
            }
        }
        return nil
    }
 
}
