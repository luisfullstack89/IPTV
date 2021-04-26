//
//  JsonModel.swift
//  Created by YPY Global on 3/4/19.
//  Copyright © 2019 YPY Global. All rights reserved.
//

import Foundation
public class JsonModel {
   
    required init() {
        
    }
    
    func initFromDict(_ dictionary: [String : Any]?){
        
    }
    
    func createDictToSave() -> [String : Any]? {
        let dictionary = [String : Any]()
        return dictionary
    }
    
    static func getDictFromList(_ listModel: [JsonModel]) -> [[String: Any]]{
        var datas = [[String: Any]]()
        if listModel.count > 0 {
            for model in listModel{
                if let dict = model.createDictToSave() {
                    datas.append(dict)
                }
            }
        }
        return datas
    }
    
    func copy() -> JsonModel? {
        return nil
    }
    
    func equalElement(_ otherModel: JsonModel?) -> Bool {
        return false
    }
}


