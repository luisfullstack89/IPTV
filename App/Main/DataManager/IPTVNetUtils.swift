//
//  RadioNetUtils.swift
//  Created by YPY Global on 2/16/19.
//  Copyright © 2019 YPY Global. All rights reserved.
//

import Foundation
import Alamofire

open class IPTVNetUtils {
    private static let FOLDER_IPTV = "iptv"
    private static let HEADER_PKG = "X-App-Package"
    private static let HEADER_CERT = "X-App-Cert"
    private static let HEADER_HL = "X-App-Hl"
    private static let HEADER_API_KEY = "X-Api-Key"
    private static let HEADER_PLATFORM = "X-Platform"
    private static let HEADER_CACHE = "Cache-Control"
    private static let HEADER_VERSION_CODE = "X-App-Version-Code"
    private static let PLATFORM_IOS = "ios"
    private static let VALUE_NO_CACHE = "no-cache"
    
    private static let ABC_XYZ_KEY = "@~Rep31l1s0pp6789"
    private static let FORMAT_API_END_POINT = "api/%@?"
    private static let METHOD_IPTV_APP = "getIptvApp"
    private static let METHOD_IPTV_HOME = "getIpTvHome"
    private static let METHOD_GET_GENRES = "getGenres"
    private static let METHOD_GET_SERIES = "getSeries"
    private static let METHOD_GET_SEASONS = "getSeasons"
    private static let METHOD_GET_EPISODES = "getEpisodes"
    private static let METHOD_GET_MOVIES = "getMovies"
    private static let METHOD_RESOLVE_URL = "resolveUrl"
    private static let METHOD_GET_FEATURED_MOVIES = "getFeaturedMovies"
    private static let METHOD_GET_NEWEST_MOVIES = "getRecentMovies"
    
    static let KEY_SIGN = "&sign="
    static let KEY_PKG = "&pkg="
    static let KEY_PLATFORM = "&platform="
    static let KEY_API = "&api_key="
    static let KEY_QUERY = "&q="
    static let KEY_GENRE_ID = "&genre_id="
    static let KEY_OFFSET = "&offset="
    static let KEY_LIMIT = "&limit="
    static let KEY_SERIES_ID = "&series_id="
    static let KEY_SEASON_ID = "&season_id="
    
    static let FOLDER_SERIES = "uploads/series/%@"
    static let FOLDER_GENRES = "uploads/genres/%@"
    static let FOLDER_EPISODES = "uploads/episodes/%@"
    static let FOLDER_MOVIES = "uploads/movies/%@"
    static let FOLDER_SEASONS = "/uploads/seasons/%@"
    
    private static let EXT_INF = "#EXTINF:"
    private static let EXT_LOGO = "tvg-logo="
    private static let EXT_GROUP = "group-title="
    private static let EXT_NAME = "tvg-name="
    
    public static func getIpTvHome(_ offset: Int, _ limit: Int, _ completion: @escaping (ResultModel?)->Void) {
        let host = SettingManager.getUrlEnpoint()
        let url = self.getUrlApiWithPaging(host,METHOD_IPTV_HOME,offset,limit)
        let headers = getHeader()
        YPYLog.logD("====>getIpTvHome=\(url)")
        DownloadUtils.getResultJsonModel(url,headers, HomeModel.self, completion)
    }
        
    public static func getListGenreModel(_ completion: @escaping (ResultModel?)->Void){
        let host = SettingManager.getUrlEnpoint()
        let linkUrl = self.getUrlApi(host,METHOD_GET_GENRES)
        YPYLog.logD("====>getListGenreModel=\(linkUrl)")
        let headers = getHeader()
        DownloadUtils.getResultJsonModel(linkUrl, headers, GenreModel.self, completion)
    }
    
    public static func getSeries(_ offset: Int, _ limit: Int, _ q: String? = nil , _ completion: @escaping (ResultModel?)->Void) {
        let host = SettingManager.getUrlEnpoint()
        let url = self.getUrlApiWithPaging(host,METHOD_GET_SERIES,offset,limit,q)
        let headers = getHeader()
        YPYLog.logD("====>getSeries=\(url)")
        DownloadUtils.getResultJsonModel(url,headers, SeriesModel.self, completion)
    }
    
    public static func getListSeasons(_ seriesId: Int64, _ offset: Int, _ limit: Int, _ q: String? = nil , _ completion: @escaping (ResultModel?)->Void) {
        let host = SettingManager.getUrlEnpoint()
        var url = self.getUrlApiWithPaging(host,METHOD_GET_SEASONS,offset,limit,q)
        url += KEY_SERIES_ID + String(seriesId)
        YPYLog.logD("====>getListSeasons=\(url)")
        let headers = getHeader()
        DownloadUtils.getResultJsonModel(url,headers, SeasonModel.self, completion)
    }
    
    public static func getListEpisodes(_ seasonId: Int64, _ offset: Int, _ limit: Int, _ q: String? = nil , _ completion: @escaping (ResultModel?)->Void) {
        let host = SettingManager.getUrlEnpoint()
        var url = self.getUrlApiWithPaging(host,METHOD_GET_EPISODES,offset,limit,q)
        url += KEY_SEASON_ID + String(seasonId)
        YPYLog.logD("====>getListEpisodes=\(url)")
        let headers = getHeader()
        DownloadUtils.getResultJsonModel(url,headers, EpisodeModel.self, completion)
    }
    
    public static func getListMovies(_ offset: Int, _ limit: Int, _ genreId: Int64 = 0, _ q: String? = nil , _ completion: @escaping (ResultModel?)->Void) {
        let host = SettingManager.getUrlEnpoint()
        var url = self.getUrlApiWithPaging(host,METHOD_GET_MOVIES,offset,limit,q)
        if genreId > 0 {
            url += KEY_GENRE_ID + String(genreId)
        }
        YPYLog.logD("====>getListMovies=\(url)")
        let headers = getHeader()
        DownloadUtils.getResultJsonModel(url,headers, MovieModel.self, completion)
    }
    
    public static func getFeaturedMovies(_ offset: Int, _ limit: Int, _ completion: @escaping (ResultModel?)->Void) {
        let host = SettingManager.getUrlEnpoint()
        let url = self.getUrlApiWithPaging(host,METHOD_GET_FEATURED_MOVIES,offset,limit)
        YPYLog.logD("====>getFeaturedMovies=\(url)")
        let headers = getHeader()
        DownloadUtils.getResultJsonModel(url,headers, MovieModel.self, completion)
    }
    
    public static func getRecentMovies(_ offset: Int, _ limit: Int, _ completion: @escaping (ResultModel?)->Void) {
        let host = SettingManager.getUrlEnpoint()
        let url = self.getUrlApiWithPaging(host,METHOD_GET_NEWEST_MOVIES,offset,limit)
        YPYLog.logD("====>getRecentMovies=\(url)")
        let headers = getHeader()
        DownloadUtils.getResultJsonModel(url,headers, MovieModel.self, completion)
    }
    
    public static func resolveUrl(_ link: MovieLinkModel , _ completion: @escaping (ResultModel?)->Void) {
        let host = SettingManager.getUrlEnpoint()
        let url = self.getUrlApi(host,METHOD_RESOLVE_URL)
        let params = ["lan": link.lan, "link_play": link.linkPlay, "link_download": link.linkDownload]
        buildPostRequest(url, params, MovieLinkModel.self, completion)
    }
    
    public static func getIptvApp(_ host: String,_ completion: @escaping (ResultModel?)->Void) {
        var url = self.getUrlApi(host,METHOD_IPTV_APP)
        let pkg = Bundle.main.bundleIdentifier!
        var formatHost = host.replacingOccurrences(of: "https://", with: "")
        formatHost = formatHost.replacingOccurrences(of: "http://", with: "")
        let checkHash = formatHost + pkg + ABC_XYZ_KEY + PLATFORM_IOS
        let sign = StringUtils.getMd5Hash(checkHash) ?? ""
        url += KEY_SIGN + sign
        url += KEY_PKG + pkg
        url += KEY_PLATFORM + PLATFORM_IOS
        YPYLog.logD("====>getIptvApp=\(url)")
        DownloadUtils.getResultJsonModel(url,nil, BundleModel.self, completion)
    }
    
    private static func getUrlApiWithPaging(_ host: String, _ method: String, _ offset: Int, _ limit: Int, _ q: String? = nil) -> String{
        var url = self.getUrlApi(host, method)
        url += KEY_OFFSET + String(offset)
        url += KEY_LIMIT + String(limit)
        if q != nil && !q!.isEmpty {
            url += KEY_QUERY + q!
        }
        return url
    }
    
    public static func getListM3UModels(_ url: String) -> [M3uModel]? {
        let finalUrl = !url.starts(with: "http") ? ("http://" + url) : url
        YPYLog.logE("===>finalUrl=\(finalUrl)")
        if let content = DownloadUtils.downloadString(linkUrl: finalUrl) {
            var listModels = self.parseM3U(contentsOfFile: content)
            listModels.removeAll(where: {return $0.uri.isEmpty})
            return listModels
        }
        return nil
    }
    
    private static func parseM3U(contentsOfFile: String) -> [M3uModel] {
        var mediaItems = [M3uModel]()
        contentsOfFile.enumerateLines(invoking: { line, stop in
            if line.hasPrefix(EXT_INF) {
                let infoLine = line.replacingOccurrences(of: EXT_INF, with: "")
                let infos = infoLine.split(separator: ",")
                let size = infos.count
                if size > 0 {
                    let m3uModel = M3uModel()
                    m3uModel.createdAt = DateTimeUtils.getCurrentDate(IPTVConstants.SERVER_OLD_DATE_PATTERN)
                    var index = 0
                    for item in infos {
                        let info = String(item).trimmingCharacters(in: .whitespaces)
                        if info.hasPrefix(EXT_LOGO) {
                            var img = info.replacingOccurrences(of: EXT_LOGO, with: "")
                            img = img.replacingOccurrences(of: "\"", with: "")
                            m3uModel.img = img
                        }
                        else if info.hasPrefix(EXT_GROUP) {
                            var group = info.replacingOccurrences(of: EXT_GROUP, with: "")
                            group = group.replacingOccurrences(of: "\"", with: "")
                            m3uModel.group = group
                        }
                        else if info.hasPrefix(EXT_NAME) {
                            var name = info.replacingOccurrences(of: EXT_NAME, with: "")
                            name = name.replacingOccurrences(of: "\"", with: "")
                            m3uModel.name = name
                        }
                        else if info.contains(EXT_LOGO) && info.contains(EXT_NAME) && info.contains(EXT_GROUP){
                            let dataInside = info.components(separatedBy: "\" ")
                            if dataInside.count > 0 {
                                for strCheck1 in dataInside {
                                    let str1 = String(strCheck1).trimmingCharacters(in: .whitespaces)
                                    if str1.hasPrefix(EXT_LOGO) {
                                        var img = str1.replacingOccurrences(of: EXT_LOGO, with: "")
                                        img = img.replacingOccurrences(of: "\"", with: "")
                                        m3uModel.img = img
                                    }
                                    else if str1.hasPrefix(EXT_GROUP) {
                                        var group = str1.replacingOccurrences(of: EXT_GROUP, with: "")
                                        group = group.replacingOccurrences(of: "\"", with: "")
                                        m3uModel.group = group
                                    }
                                    else if str1.hasPrefix(EXT_NAME) {
                                        var name = str1.replacingOccurrences(of: EXT_NAME, with: "")
                                        name = name.replacingOccurrences(of: "\"", with: "")
                                        m3uModel.name = name
                                    }
                                }
                            }
                        }
                        else{
                            m3uModel.name = info
                        }
                        index += 1
                    }
                    mediaItems.append(m3uModel)
                }
            }
            else {
                if mediaItems.count > 0 {
                    let item = mediaItems.last
                    item?.uri = line
                }
            }
        })
        return mediaItems
    }

    
    private static func getUrlApi(_ host: String, _ method: String) -> String{
        let newHost = host.starts(with: "http") ? host : ("https://" + host)
        return newHost + "/" + FOLDER_IPTV + "/" + String.init(format: FORMAT_API_END_POINT, method)
    }

    
    private static func buildPostRequest(_ url: String, _ params: [String: Any], _ classType: JsonModel.Type, _ completion: @escaping (ResultModel?)->Void) {
        let httpHeaders: HTTPHeaders  = getHeader()
        AF.upload(multipartFormData: {(multipartFormData) in
            for (key, value) in params {
                multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
            }
        }, to: url, usingThreshold: UInt64.init(),method: .post,headers: httpHeaders, fileManager: .default).response { response in
            if let data = response.data {
                completion(JsonParsingUtils.getListResultModel(data, classType))
            }
            else{
                let resultModel = ResultModel(404,getString(StringRes.info_server_error))
                completion(resultModel)
            }
        }
    }
    
    public static func getHeader() -> HTTPHeaders {
        var version = SettingManager.getVersionCode()
        let isNumber = version.isNumber()
        if isNumber {
            var versionInt = Int(version)!  - 1
            if versionInt < 0 {
                versionInt = 0
            }
            version = String(versionInt)
        }
        
        let httpHeaders: HTTPHeaders  = [
            HEADER_PKG: Bundle.main.bundleIdentifier!,
            HEADER_API_KEY: SettingManager.getApiKey(),
            HEADER_VERSION_CODE: version,
            HEADER_CERT : SettingManager.getShaKey(),
            HEADER_CACHE: VALUE_NO_CACHE,
            HEADER_HL: self.getLanCode(),
            HEADER_PLATFORM: PLATFORM_IOS]
        return httpHeaders
    }
    
    private static func getLanCode() -> String {
        let locale: NSLocale = NSLocale.current as NSLocale
        var lanCode = "EN"
        if let country = locale.countryCode {
            lanCode = locale.languageCode.lowercased() + "-" + country
            return lanCode
        }
        return lanCode
    }
}




