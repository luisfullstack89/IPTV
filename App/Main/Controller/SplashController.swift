//
//  Created by YPYGlobal on 1/9/19.
//  Copyright © 2019 YPYGlobal. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView
import Toast_Swift
import AppTrackingTransparency
import AdSupport

class SplashController : YPYRootViewController{
    
    let TIME_OUT_PROCESS = 2.0
    let FIREBASE_CACHE_EXPIRATION = 900.0 // seconds , 15 minutues
    
    @IBOutlet weak var imgBackground: UIImageView!
    
    var totalDataMng = TotalDataManager.shared
    private var firebaseConfig : YPYFBRemoteConfigs!
    let remoteDefaultDict : NSDictionary  = [SettingManager.KEY_ADS_TYPE: AdsModel.TYPE_ADS_ADMOB]
    
    override func setUpUI() {
        super.setUpUI()
        self.firebaseConfig = YPYFBRemoteConfigs(FIREBASE_CACHE_EXPIRATION,remoteDefaultDict)
    }
        
    override func viewDidLoad() {
        self.initFontToast()
        super.viewDidLoad()
    }
    
    private func initFontToast(){
        var toastStyle = ToastStyle()
        toastStyle.titleFont = UIFont(name: IPTVConstants.FONT_NORMAL, size: DimenRes.toast_font_size) ?? UIFont.systemFont(ofSize: DimenRes.toast_font_size)
        toastStyle.messageFont = UIFont(name: IPTVConstants.FONT_NORMAL, size: DimenRes.toast_font_size) ?? UIFont.systemFont(ofSize: DimenRes.toast_font_size)
        ToastManager.shared.style = toastStyle
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.firebaseConfig.fetchDataFromFireBase { (success) in
            self.loadDataFromFirebase(success)
        }
    }
    
    func loadDataFromFirebase(_ success: Bool){
        let adTypes = self.firebaseConfig.getStringConfig(SettingManager.KEY_ADS_TYPE)
        YPYLog.logE("======>loadDataFromFirebase=\(adTypes)")
        SettingManager.setSetting(SettingManager.KEY_ADS_TYPE, adTypes)
        DispatchQueue.main.async {
            self.requestIDFA()
        }
    }
  
    func requestIDFA() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                self.loadData()
            })
        }
        else {
            self.loadData()
        }
    }
  
    func loadData() {
        DispatchQueue.global().async {
            SettingManager.resetAdsClick()
            self.totalDataMng.readCache()
            
            //check migrate in the first time
            DatabaseManager.shared.checkMigrate()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + self.TIME_OUT_PROCESS, execute: {
                self.goToMain()
            })
        }
    }
    
    
    func goToMain(){
        let main = MainController.create()
        self.presentDetail(main)
    }

}
