//
//  YPYCacheDataModel.swift
//  Created by YPY Global on 3/4/19.
//  Copyright © 2019 YPY Global. All rights reserved.
//

import Foundation

public class YPYCacheDataModel {
    
    private let PREFIX_CACHE = "cache_%d.json"
    
    var listSaveModels = [YPYSaveModel]()
    
    func addSaveMode(_ id: Int){
        addSaveModel(id, 0)
    }
    
    func addSaveMode(_ id:Int, _ classType: JsonModel.Type){
        addSaveModel(id, 0, classType)
    }
    
    func addSaveModel(_ id: Int, _ maxCache: Int, _ classType: JsonModel.Type? = nil) {
        if getSaveMode(id) == nil {
            let fileName = String.init(format: PREFIX_CACHE, id)
            var model: YPYSaveModel
            if let type = classType {
                model = YPYSaveModel(id,fileName,type)
            }
            else{
                model = YPYSaveModel(id,fileName)
            }
            model.maximumObject = maxCache
            listSaveModels.append(model)
        }
    }
    
    func readAllCache() {
        if listSaveModels.count > 0 {
            for model in listSaveModels{
                readCacheData(model)
            }
        }
    }
    
    func setListCacheData(_ id:Int, _ listModel: [JsonModel]){
        if let saveModel = getSaveMode(id) {
            saveModel.listSavedData = listModel
            saveDataCache(saveModel)
        }
    }
    
    func getListCacheData (_ id: Int) -> [JsonModel]? {
        if let saveModel = getSaveMode(id){
            return saveModel.listSavedData
        }
        return nil
        
    }
    
    
    func onDestroy (){
        if listSaveModels.count > 0 {
            for model in listSaveModels{
                model.onDestroy()
            }
            listSaveModels.removeAll()
        }
    }
    
    func getSaveMode(_ id: Int) -> YPYSaveModel? {
        if listSaveModels.count > 0 {
            for model in listSaveModels{
                if model.id == id {
                    return model
                }
            }
        }
        return nil
    }
    
    func readCacheData(_ id: Int){
        if let model = getSaveMode(id) {
            readCacheData(model)
        }
    }
    
    func readCacheData(_ model: YPYSaveModel) {
        if model.isAllowToSave(){
            let fileName = model.fileName
            guard let documentsDirectoryUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
                YPYLog.logE("can not get path to save")
                return
            }
            let fileUrl = documentsDirectoryUrl.appendingPathComponent(fileName)
            do {
                if FileManager.default.fileExists(atPath: fileUrl.path){
                    let dataJSON = try Data(contentsOf: fileUrl, options: [])
                    if let listSavedData = JsonParsingUtils.getListModel(dataJSON,model.classType!) {
                        model.listSavedData = listSavedData
                    }
                    YPYLog.logD("readCacheData =\(model.fileName) ==> size=\(String(describing: model.listSavedData?.count))")
                }
            }
            catch {
                YPYLog.logE("error when reading json =\(error)")
            }
        }
    }
    
    func saveDataCache(_ id:Int){
        if let saveModel = getSaveMode(id) {
            saveDataCache(saveModel)
        }
    }
    
    func saveDataCache(_ model: YPYSaveModel) {
        if model.isAllowToSave() {
            let fileName = model.fileName
            guard let cacheDirectoryUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
                YPYLog.logE("can not get path to save")
                return
            }
            let fileUrl = cacheDirectoryUrl.appendingPathComponent(fileName)
            do {
                let writeDatas = model.getListDictToSave()
                let data = try JSONSerialization.data(withJSONObject: writeDatas, options: [])
                YPYLog.logD("save of file=\(model.fileName)")
                try data.write(to: fileUrl, options: [])
            }
            catch {
               YPYLog.logE("error when creating json =\(error)")
            }
            
        }
    }
    
    func isCacheExisted(_ id: Int) -> Bool{
        if let model = getSaveMode(id) {
            if model.isAllowToSave() {
                let fileName = model.fileName
                guard let cacheDirectoryUrl = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
                    return false
                }
                let fileUrl = cacheDirectoryUrl.appendingPathComponent(fileName)
                return FileManager.default.fileExists(atPath: fileUrl.path)
            }
        }
        return false
    }
    
    func addModelInCache(_ id: Int,_ model: JsonModel) {
        addModelInCache(id, -1, model)
    }
    
    func addModelInCache(_ id: Int, _ pos: Int, _ model: JsonModel){
        if let saveModel = getSaveMode(id) {
            if saveModel.listSavedData == nil {
                saveModel.listSavedData = [JsonModel]()
            }
            let maxSize = saveModel.maximumObject
            let indexItem = getIndexExistedItemInCache(id, model)
            var isNeedSave = false
            if pos >= 0 {
                if indexItem >= 0 {
                    //saveModel.listSavedData!.remove(at: indexItem)
                    //saveModel.listSavedData!.insert(model, at: pos)
                    saveModel.listSavedData!.swapAt(indexItem, pos)
                }
                else{
                    saveModel.listSavedData!.insert(model,at: pos)
                }
                isNeedSave = true
            }
            else{
                if indexItem == -1 {
                    saveModel.listSavedData!.append(model)
                    isNeedSave = true
                }
            }
            if isNeedSave {
                let currentSize = saveModel.listSavedData!.count
                if currentSize > 0 && maxSize > 0 && currentSize > maxSize && pos == 0 {
                    saveModel.listSavedData!.remove(at: currentSize-1)
                }
                saveDataCache(saveModel)
            }
            
        }
    }
    func getIndexExistedItemInCache(_ id: Int, _ model: JsonModel) -> Int{
        if let saveModel = getSaveMode(id) {
            if saveModel.listSavedData != nil && saveModel.listSavedData!.count > 0{
                guard let indexItem: Int = saveModel.listSavedData!.firstIndex(where: {
                    return $0.equalElement(model)
                }) else{
                    return -1
                }
                return indexItem
            }
        }
        return -1
    }
    
    func removeModelInCache (_ id: Int, _ model: JsonModel) -> Bool{
        if let saveModel = getSaveMode(id) {
            if saveModel.listSavedData != nil && saveModel.listSavedData!.count > 0{
                guard let indexItem: Int = saveModel.listSavedData!.firstIndex(where: {
                    return $0.equalElement(model)
                }) else{
                    return false
                }
                saveModel.listSavedData!.remove(at: indexItem)
                saveDataCache(saveModel)
                return true
            }
        }
        return false
    }
}
