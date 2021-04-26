//
//  AbstractEntity.swift
//  iLandMusic
//
//  Created by YPYGlobal on 11/5/19.
//  Copyright © 2019 YPYGlobal. All rights reserved.
//

import Foundation
import SQLite

public class AbstractEntity<T: AbstractModel>: NSObject {
        
    required override init() {
        super.init()
    }
    
    static func createToRealModel (_ dict: [String:Any]?) -> T? {
        let model = T.init()
        model.initFromDict(dict)
        return model
    }
    
    func getSQLSetter(_ column: ColumInfo?, _ dict: [String:Any]) -> SQLite.Setter? {
        if let columName = column?.getColumnName() {
            return column?.getSQLSetter(value: dict[columName] as Any)
        }
        return nil
    }
   
    
}
