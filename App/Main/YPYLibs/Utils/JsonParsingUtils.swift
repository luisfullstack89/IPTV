//
//  JsonParsingUtils.swift
//  Created by YPY Global on 3/5/19.
//  Copyright © 2019 YPY Global. All rights reserved.
//

import Foundation
public class JsonParsingUtils{
    
    public static func getListResultModel(_ dataJSON: Data, _ classType: JsonModel.Type) -> ResultModel? {
        do {
            let json = try JSONSerialization.jsonObject(with: dataJSON, options: [])
            guard let dict = json as? [String: Any] else {
                return nil
            }
            let resultModel = ResultModel()
            resultModel.initFromDict(dict,classType)
            return resultModel
        }
        catch  {
            YPYLog.logE("======>error when parsing json of resultmodel \(error)")
        }
        return nil
    }
    
    public static func getModel (_ dataJSON: Data, _ classType: JsonModel.Type) -> JsonModel? {
        do {
            let json = try JSONSerialization.jsonObject(with: dataJSON, options: [])
            guard let dict = json as? [String: Any] else {
                return nil
            }
            let model = classType.init()
            model.initFromDict(dict)
            return model
        }
        catch  {
            YPYLog.logE("======>error when parsing model \(error)")
        }
        return nil
    }
    
    public static func getListModel(_ dataJSON: Data, _ classType: JsonModel.Type) -> [JsonModel]? {
        do {
            let json = try JSONSerialization.jsonObject(with: dataJSON, options: [])
            guard let dicts = json as? [[String: Any]] else {
                return nil
            }
            var listDict = [JsonModel]()
            for dic in dicts{
                let model = classType.init()
                model.initFromDict(dic)
                listDict.append(model)
            }
            return listDict
        }
        catch  {
            YPYLog.logE("======>error when parsing model \(error)")
        }
        return nil
    }
}
