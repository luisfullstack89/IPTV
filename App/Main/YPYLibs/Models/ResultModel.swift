//
//  ResultModel.swift
//  Created by YPY Global on 3/5/19.
//  Copyright © 2019 YPY Global. All rights reserved.
//

import Foundation

public class ResultModel: JsonModel{
    var status: Int = 0
    var msg: String = ""
    var listModel: [JsonModel]?
    
    public required init() {
        super.init()
    }
    
    init(_ status: Int, _ msg: String) {
        super.init()
        self.status = status
        self.msg = msg
    }
    
    func initFromDict(_ dictionary: [String : Any]?, _ classType: JsonModel.Type) {
        super.initFromDict(dictionary)
        if dictionary != nil {
            if let parseStatus = dictionary!["status"] as? Int{
                self.status = parseStatus
            }
            if let parseMsg = dictionary!["msg"] as? String{
                self.msg = parseMsg
            }
            if let parseDatas = dictionary!["datas"] as? [[String: Any]]{
                self.listModel = [JsonModel]()
                for dic in parseDatas{
                    let model = classType.init()
                    model.initFromDict(dic)
                    self.listModel?.append(model)
                }
                
            }
        }
    }
    
    override func createDictToSave() -> [String : Any]? {
        var dicts = super.createDictToSave()
        dicts!.updateValue(status, forKey: "status")
        dicts!.updateValue(msg, forKey: "msg")
        dicts!.updateValue(JsonModel.getDictFromList(listModel!), forKey: "datas")
        return dicts
    }
    
    func isResultOk() -> Bool{
        return status == 200
    }
    
    func getFirstModel() -> JsonModel? {
        if listModel != nil && listModel!.count>0 {
            return self.listModel![0]
        }
        return nil
    }
    
    
}
