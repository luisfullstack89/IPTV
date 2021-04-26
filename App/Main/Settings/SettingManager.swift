//
//  SettingManager.swift
//  Created by YPY Global on 4/9/19.
//  Copyright © 2019 YPY Global. All rights reserved.
//

import Foundation
public class SettingManager {
    
    static let KEY_PIVOT_TIME = "pivot_time"
    static let KEY_URL_ENDPOINT = "url_endpoint"
    static let KEY_API_KEY = "api_key"
    static let KEY_SHA_KEY = "sha_key"
    static let KEY_VERSION_CODE = "version_code"
    
    static let KEY_MOVIE_CLICK = "movie_click"
    static let KEY_GENRE_CLICK = "genre_click"
    static let KEY_SEASON_CLICK = "season_click"
    static let KEY_EPISODE_CLICK = "episode_click"
    static let KEY_BUNDLE_CLICK = "bundle_click"
    static let KEY_SERIES_CLICK = "series_click"
    
    static let KEY_GROUP_TITLE = "has_group_title"
    static let KEY_ADS_TYPE = "ad_types"
 
    public static func setSetting (_ key: String!, _ value: String!){
        let user = UserDefaults.standard
        user.set(value, forKey: key)
    }
    
    public static func getSetting (_ key: String!, _ defautValue: String = "") -> String{
        let user = UserDefaults.standard
        let value = user.string(forKey: key) ?? defautValue
        return value
    }
    
    public static func setBool (_ key: String! , _ value: Bool) {
        setSetting(key, String(value))
    }
    
    public static func getBool (_ key: String!, _ defaultValue: Bool = false) -> Bool {
        let value = getSetting(key, String(defaultValue))
        return Bool(value) ?? defaultValue
    }
    
    public static func setInt (_ key: String! , _ value: Int) {
        setSetting(key, String(value))
    }
    
    public static func getInt (_ key: String!, _ defaultValue: Int = 0) -> Int {
        let value = getSetting(key, String(defaultValue))
        return Int(value)!
    }

    public static func getPivotTime () -> Double {
        let pivotStr = getSetting(KEY_PIVOT_TIME, "0")
        return Double(pivotStr)!
    }
    
    public static func setPivotTime (_ pivotTime: Double) {
        setSetting(KEY_PIVOT_TIME, String(pivotTime))
    }
    
    public static func getUrlEnpoint() -> String {
        return getSetting(KEY_URL_ENDPOINT)
    }
    
    public static func getAdsType() -> String {
        let adsType = getSetting(KEY_ADS_TYPE,AdsModel.TYPE_ADS_ADMOB)
        if  adsType.isEmpty {
            return AdsModel.TYPE_ADS_ADMOB
        }
        return adsType
    }
    
    public static func getApiKey() -> String {
        return getSetting(KEY_API_KEY)
    }
    
    public static func getShaKey() -> String {
        return getSetting(KEY_SHA_KEY)
    }
    
    public static func getVersionCode() -> String {
        return getSetting(KEY_VERSION_CODE)
    }
    
    public static func resetBundle() {
        setSetting(KEY_URL_ENDPOINT, "")
        setSetting(KEY_API_KEY, "")
        setSetting(KEY_VERSION_CODE, "")
        setSetting(KEY_SHA_KEY, "")
    }
    
    public static func saveBundle(_ app: BundleModel){
        setSetting(KEY_URL_ENDPOINT, app.uri)
        setSetting(KEY_API_KEY, app.apiKey)
        setSetting(KEY_VERSION_CODE, app.versionCode)
        setSetting(KEY_SHA_KEY, app.sha1)
    }
    
    public static func resetAdsClick(){
        setInt(KEY_MOVIE_CLICK, 0)
        setInt(KEY_GENRE_CLICK, 0)
        setInt(KEY_SEASON_CLICK, 0)
        setInt(KEY_EPISODE_CLICK, 0)
        setInt(KEY_BUNDLE_CLICK, 0)
        setInt(KEY_SERIES_CLICK, 0)
    }
}
