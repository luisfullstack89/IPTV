//
//  YPYSaveModel.swift
//  Created by YPY Global on 3/4/19.
//  Copyright © 2019 YPY Global. All rights reserved.
//

import Foundation
public class YPYSaveModel: NSObject{
    var id: Int = 0
    var fileName: String = ""
    var maximumObject: Int = 0
    var listSavedData: [JsonModel]?
    var classType: JsonModel.Type?
    
    init(_ id: Int, _ fileName: String, _ classType: JsonModel.Type? = nil) {
        self.id = id
        self.fileName = fileName
        self.classType = classType
    }
    
    init(_ id: Int) {
        self.id = id
    }
    
    func onDestroy() {
        if listSavedData != nil {
            listSavedData!.removeAll()
        }
    }
    
    func getListDictToSave() -> [[String: Any]]{
        var listDict = [[String : Any]]()
        if listSavedData != nil && listSavedData!.count > 0 {
            for model in listSavedData! {
                if let dic = model.createDictToSave(){
                    listDict.append(dic)
                }
            }
        }
        return listDict
        
    }
    
    func isAllowToSave() -> Bool {
        return !fileName.isEmpty && classType != nil
    }
    
    
    
}
