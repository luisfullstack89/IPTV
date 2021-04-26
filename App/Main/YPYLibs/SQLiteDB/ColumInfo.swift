//
//  DataTypeModel.swift
//  iLandMusic
//
//  Created by YPYGlobal on 11/5/19.
//  Copyright © 2019 YPYGlobal. All rights reserved.
//

import Foundation
import SQLite

public class ColumInfo: NSObject {
    
    var type: Expressible?
    var primaryKey : PrimaryKey?
    var isUnique: Bool?
    
    required override init() {
        super.init()
    }
    
    public init( _ dataType: Expressible, _ isUnique: Bool = false){
        self.type = dataType
        self.isUnique = isUnique
    }
    
    public init( _ dataType: Expressible, _ primaryKey: PrimaryKey = .default, _ isUnique: Bool = false){
        self.type = dataType
        self.primaryKey = primaryKey
        self.isUnique = isUnique
    }
    
    func getColumnName() -> String? {
        if let intType = self.type as? Expression<Int64>{
            return intType.template.replacingOccurrences(of: "\"", with: "")
        }
        if let doubeType = self.type as? Expression<Double>{
            return doubeType.template.replacingOccurrences(of: "\"", with: "")
        }
        if let strType = self.type as? Expression<String>{
            return strType.template.replacingOccurrences(of: "\"", with: "")
        }
        return nil
    }
    
    func getSQLSetter(value: Any?) -> SQLite.Setter? {
        if primaryKey != nil && primaryKey! == .autoincrement {
            return nil
        }
        if value != nil {
            if let intType = self.type as? Expression<Int64>{
                if value is Int64 {
                    return intType <- (value as! Int64)
                }
                else{
                    return intType <- Int64((value as! Int))
                }
            }
            if let doubeType = self.type as? Expression<Double>{
                return doubeType <- (value as! Double)
            }
            if let strType = self.type as? Expression<String>{
                return strType <- (value as! String)
            }
        }
        return nil
    }
    
    func createFilter(value: Any) -> Expression<Bool>? {
        if let intType = self.type as? Expression<Int64>{
            return intType == (value as! Int64)
        }
        if let doubeType = self.type as? Expression<Double>{
            return doubeType == (value as! Double)
        }
        if let strType = self.type as? Expression<String>{
            return strType == "\(value as! String)"
        }
        return nil
    }
    
    func getValue( _ row: Row) -> Any? {
       if let intType = self.type as? Expression<Int64>{
            return try? row.get(intType) as Int64
       }
       if let doubeType = self.type as? Expression<Double>{
           return try? row.get(doubeType) as Double
       }
       if let strType = self.type as? Expression<String>{
           return try? row.get(strType) as String
       }
       return nil
    }
}
