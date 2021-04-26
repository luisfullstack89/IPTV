//
//  AbstractModel.swift
//  Created by YPY Global on 3/4/19.
//  Copyright © 2019 YPY Global. All rights reserved.
//

import Foundation
public class AbstractModel: JsonModel{
    
    var id: Int64 = 0
    var name: String = ""
    var img: String = ""
    var isFavorite: Bool = false
    
    public required init() {
        super.init()
    }
  
    init(_ id: Int64, _ name: String, _ img: String) {
        super.init()
        self.id = id
        self.name = name
        self.img = img
    }
    
    init(_ id: Int64, _ name: String) {
        super.init()
        self.id = id
        self.name = name
    }
    
    func getShareStr() -> String? {
        return nil
    }
    
    func getUriArtwork (_ urlEnpoint: String) -> String {
        return img
    }
    
    override func initFromDict(_ dictionary: [String : Any]?) {
        super.initFromDict(dictionary)
        if let id = dictionary?["id"] as? Int64{
            self.id = id
        }
        if let id = dictionary?["id"] as? String{
            if id.isNumber() {
                self.id = Int64(id)!
            }
        }
        if let name = dictionary?["name"] as? String{
            self.name = name
        }
        if let img = dictionary?["img"] as? String{
            self.img = img
        }
    }
    override func createDictToSave() -> [String : Any]? {
        var dicts = super.createDictToSave()
        dicts!.updateValue(id, forKey: "id")
        dicts!.updateValue(name, forKey: "name")
        dicts!.updateValue(img, forKey: "img")
        return dicts
    }
    
    override func equalElement(_ otherModel: JsonModel?) -> Bool {
        if let abModel = otherModel as? AbstractModel {
            return abModel.id == id
        }
        return false
    }
    
}
