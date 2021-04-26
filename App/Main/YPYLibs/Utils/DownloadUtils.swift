//
//  DownloadUtils.swift
//  Created by YPY Global on 2/18/19.
//  Copyright © 2019 YPY Global. All rights reserved.
//

import Foundation
import Alamofire

open class DownloadUtils {
    
    public static func downloadString(linkUrl: String?) -> String? {
        do {
            if linkUrl != nil && !(linkUrl?.isEmpty)! {
                guard let myURL = URL(string: linkUrl!) else {
                    YPYLog.logE("Error: \(String(describing: linkUrl)) doesn't seem to be a valid URL")
                    return nil
                }
                let contents = try String(contentsOf: myURL)
                return contents
            }
        }
        catch let error {
            YPYLog.logE("downloadString error= \(error)")
        }
        return nil
    }
    
    public static func getJsonModel (_ linkUrl: String, _ headers: HTTPHeaders? = nil, _ classType: JsonModel.Type, _ completion: @escaping (JsonModel?)->Void ){
        AF.request(linkUrl, method: .get, encoding:
            URLEncoding.default,headers: headers).responseData(completionHandler: { responce in
                if let data = responce.data {
                    completion(JsonParsingUtils.getModel(data, classType))
                }
                else{
                    completion(nil)
                }
            })
    }
    
    public static func getListJsonModel (_ linkUrl: String, _ headers: HTTPHeaders? = nil, _ classType: JsonModel.Type, _ completion: @escaping ([JsonModel]?)->Void ){
        AF.request(linkUrl, method: .get, encoding: URLEncoding.default,headers: headers).responseData(completionHandler: { responce in
            if let data = responce.data {
                completion(JsonParsingUtils.getListModel(data, classType))
            }
            else{
                completion([])
            }
        })
    }
    
    public static func getResultJsonModel (_ linkUrl: String, _ headers: HTTPHeaders? = nil, _ classType: JsonModel.Type, _ completion: @escaping (ResultModel?)->Void ){
        AF.request(linkUrl, method: .get, encoding: URLEncoding.default, headers: headers).responseData(completionHandler: { responce in
            if let data = responce.data {
                completion(JsonParsingUtils.getListResultModel(data, classType))
            }
            else{
                let resultModel = ResultModel(404,getString(StringRes.info_server_error))
                completion(resultModel)
            }
        })
    }
}
