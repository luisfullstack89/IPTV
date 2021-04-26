//
//  DateModel.swift
//  iptv-pro
//
//  Created by Do Trung Bao on 8/19/20.
//  Copyright © 2020 YPY Global. All rights reserved.
//

import Foundation

public class DateModel: AbstractModel {
    
    var strDate = ""
    var createdAt = ""
    
    override func initFromDict(_ dictionary: [String : Any]?) {
        super.initFromDict(dictionary)
        if let createdAt = dictionary?["created_date"] as? String {
            self.createdAt = createdAt
        }
    }
    
    override func createDictToSave() -> [String : Any]? {
        var dicts = super.createDictToSave()
        dicts!.updateValue(self.createdAt, forKey: "created_date")
        return dicts
    }
    
    func getDateStr() -> String {
        if strDate.isEmpty && !createdAt.isEmpty {
            let pattern = createdAt.contains("T") ? IPTVConstants.SERVER_NEW_DATE_PATTERN : IPTVConstants.SERVER_OLD_DATE_PATTERN
            if let date = DateTimeUtils.getDateFromString(createdAt, pattern) {
                self.strDate = DateTimeUtils.convertDateToString(date, .medium)
            }
            else{
                self.strDate = createdAt
            }
        }
        return strDate
    }
}
