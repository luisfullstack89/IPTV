//
//  IRadioConstants.swift
//  Created by YPY Global on 1/22/19.
//  Copyright © 2019 YPY Global. All rights reserved.
//
//

import Foundation
import GoogleMobileAds
import UIKit

class IPTVConstants {
    
    // debug
    static let DEBUG = false
    
    static let FREQ_INTERSTITIAL_MOVIES_ADS  = 1
    static let FREQ_INTERSTITIAL_GENRES_ADS  = 3
    static let FREQ_INTERSTITIAL_SEASONS_ADS  = 3
    static let FREQ_INTERSTITIAL_EPISODES_ADS  = 3
    static let FREQ_INTERSTITIAL_BUNDLE_ADS  = 3
    static let FREQ_INTERSTITIAL_SERIES_ADS  = 3
    
    static let ADMOB_APP_ID = "ca-app-pub-9006052141226885~6306062242"
    static let ADMOB_BANNER_ID = "ca-app-pub-9006052141226885/6772966105"
    static let ADMOB_INTERSTITIAL_ID = "ca-app-pub-9006052141226885/9670592187"
    static let ADMOB_MEDIUM_ID = "ca-app-pub-9006052141226885/6772966105"
    
//    static let ADMOB_APP_ID = "ca-app-pub-3940256099942544~6306062242"
//    static let ADMOB_BANNER_ID = "ca-app-pub-3940256099942544/6300978111"
//    static let ADMOB_INTERSTITIAL_ID = "ca-app-pub-3940256099942544/1033173712"
//    static let ADMOB_MEDIUM_ID = "ca-app-pub-3940256099942544/6300978111"
    
    static let FACEBOOK_BANNER_ID = "273524573980920_401722481161128"
    static let FACEBOOK_MEDIUM_ID = "273524573980920_401723047827738"
    static let FACEBOOK_INTERSTITIAL_ID = "273524573980920_401722661161110"
    
//    static let FACEBOOK_BANNER_ID = "IMG_16_9_LINK#273524573980920_401722481161128"
//    static let FACEBOOK_MEDIUM_ID = "IMG_16_9_LINK#273524573980920_401723047827738"
//    static let FACEBOOK_INTERSTITIAL_ID = "VID_HD_9_16_39S_APP_INSTALL#273524573980920_401723047827738"
    
    static let CHROME_CAST_ID = "48F67E93"
    static let USER_AGENT = "user-agent"
    static let PRELOAD_TIME_S = 3
    
    static let USER_AGENT_VALUE = "Flix Player/1.0 play-tv"
    static let URL_IMAGE_DEFAULT_FOR_CHROME_CAST = "http://iptvproplay.com/defaul.jpg"
    
    //Your App ID on App Store, need it for rate me link
    static let APP_ID = "1454657417"
    
    //Link social
    static let URL_WEBSITE = "https://iptvproplay.com" // if you want to hide it, just put it to be empty ""
    static let YOUR_CONTACT_EMAIL = "developerandresramirez@gmail.com"
    static let URL_PRIVACRY_POLICY = "https://iptvproplay.com/privacy_policy.html"
    static let URL_TERM_OF_USE = "https://iptvproplay.com/Terms&Conditions.html"
    
    static let ADMOB_TEST_ID = "fce2c0ef05df9b18cef751ec32d81fa4"
    static let FACEBOOK_TEST_ID = ""
  
    static let TYPE_VC_HOME = 2
    static let TYPE_VC_GENRE = 3
    static let TYPE_VC_FAVORITE = 5
    static let TYPE_VC_BUNDLE = 21
    static let TYPE_VC_SERIES = 9
    static let TYPE_VC_DETAIL_GENRE = 7
    static let TYPE_VC_NEWEST_MOVIES = 8
    static let TYPE_VC_FEATURED_MOVIES = 9
    static let TYPE_VC_SEASON = 17
    static let TYPE_VC_EPISODE = 12
    static let TYPE_VC_VIDEO_M3U = 19
    static let TYPE_VC_VIDEO = 11
    static let TYPE_PLAYING_LIST = 13

    static let SHOW_ADS = true
    
    //show or hide video ads in landscap mode
    static let SHOW_ADS_IN_VIDEO_LANDSCAPE = false
    
    static let INTERSTITIAL_FREQUENCY = 3
    
    static let MAX_PAGE = 10
    static let MAX_ITEM_HOME_PAGE = 10
    
    static let IPHONE_NUMBER_ITEM_DETAIL_PAGE = 15
    static let IPAD_NUMBER_ITEM_DETAIL_PAGE = 21
    static let OFFLINE_NUMBER_ITEM_DETAIL_PAGE = 30
    
    static let RATE_VIDEO: CGFloat = 0.5625
    
    //id for cell item
    static let ID_VIDEO_FLAT_LIST_CELL = "VideoFlatListCell"
    static let ID_VIDEO_FLAT_GRID_CELL = "VideoFlatGridCell"
    static let ID_VIDEO_CARD_GRID_CELL = "VideoCardGridCell"
    static let ID_VIDEO_CARD_LIST_CELL = "VideoCardListCell"
        
    //broadcast action name
    static let BROADCAST_DATA_CHANGE = "BROADCAST_DATA_CHANGED"
    static let KEY_VC_TYPE = "vcType"
    static let KEY_ID = "id"
    static let KEY_IS_FAV = "is_fav"
    static let KEY_IS_M3U = "is_m3u"
    
    //storyboard
    static let STORYBOARD_MAIN = "Main"
    static let STORYBOARD_LAUNCH_SCREEN = "LaunchScreen"

    static let FORMAT_JSON = "json"
    
    static let FONT_NORMAL = "Helvetica-Regular"
    static let FONT_BOLD = "Helvetica-Bold"
    
    static let ONE_HOUR: Double = Double(3600000) // 1 hour
    static let ONE_MINUTE: Double = Double(60000) //1 minute
    
    static let ID_RATE_US = 1
    static let ID_TELL_A_FRIEND = 3
    static let ID_VISIT_WEBSITE = 4
    static let ID_CONTACT_US = 8
    static let ID_PRIVACY_POLICY = 9
    static let ID_TERM_OF_USE = 10
    static let ID_MORE_FEATURED = 13

    static let TYPE_VIDEO_YOUTUBE = "youtube"
    static let TYPE_VIDEO_VIMEO = "vimeo"
    static let TYPE_VIDEO_NORMAL = "normal"
    
    static let ID_MENU_SHARE = 11
    static let ID_MENU_DELETE = 12
    static let ID_MORE_NEWEST = 14
    static let ID_MORE_SERIES = 15
    static let ID_MORE_GENRE = 16
    static let ID_MENU_RELOAD_BUNDLE = 17
    static let ID_MENU_VIDEO_INFO = 18
    
    static let SERVER_NEW_DATE_PATTERN = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    static let SERVER_OLD_DATE_PATTERN = "yyyy-MM-dd HH:mm:ss";
    
    static let RATE_4_3: CGFloat = 0.75
    static let RATE_16_9: CGFloat = 9.0/16.0
    
    static let DATABASE_NAME = "iptv_pro_db.db"
    static let OUTPUT_VOLUMNE = "outputVolume"

}
enum UIType: Int{
    case Hidden = 0, FlatGrid, FlatList, CardGrid, CardList
}

enum HoriTouchDirection: Int{
    case left = 0, right, none
}
enum VertiSwipeDirection: Int{
    case up = 0, down, none
}

