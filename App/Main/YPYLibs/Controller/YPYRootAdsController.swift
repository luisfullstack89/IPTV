//
//  YPYRootAdsController.swift
//  Created by YPY Global on 9/3/19.
//  Copyright © 2019 YPY Global. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds
import FBAudienceNetwork

class YPYRootAdsController: YPYRootViewController {
    
    //Config Ads view
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var bannerHeight: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    
    var bannerViewAdmob: GADBannerView? = nil
    var admobInterstitial: GADInterstitial? = nil
    
    var bannerAdViewFB: FBAdView? = nil
    var fbIntertestial: FBInterstitialAd? = nil
    
    var adsModel: AdsModel? = nil
    
    override func setUpUI() {
        super.setUpUI()
        self.adsModel = self.onCreateAdsModel()
        let testId = self.adsModel?.testIds ?? [kGADSimulatorID as! String]
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = testId
        self.onDoWhenDone()
    }
    
    func onDoWhenDone() {
        if ApplicationUtils.isOnline() {
            self.onDoWhenNetworkOn()
        }
        self.registerObserverNetworkChange(networkDelegate: self)
    }
    
    func onDoWhenNetworkOn() {
        setUpBannerAds()
        setUpIntertestialAds()
    }
    
    func onDoWhenNetworkOff() {
        
    }

    func setUpBannerAds() {
        if self.bannerViewAdmob != nil || self.bannerAdViewFB != nil  {
            return
        }
        let type = self.adsModel?.typeAds ?? ""
        let bannerId = self.adsModel?.bannerId ?? ""
        YPYLog.logE("======>setUpBannerAds  type=\(type)==>bannerId=\(bannerId)")
        if type == AdsModel.TYPE_ADS_ADMOB {
            YPYLog.logE("======>setUpBannerAds TYPE_ADS_ADMOB")
            self.bannerViewAdmob = self.createBannerAdMob(bannerId, kGADAdSizeSmartBannerPortrait)
            let request = GADRequest()
            self.bannerViewAdmob?.load(request)
        }
        else if type == AdsModel.TYPE_ADS_FB {
            YPYLog.logE("======>setUpBannerAds TYPE_ADS_FB")
            FBAdSettings.setLogLevel(FBAdLogLevel.debug)
            let size = self.adsModel?.testIds.count ?? 0
            if size > 0 {
                for i in 0..<size {
                    YPYLog.logE("====>addTestId=\(self.adsModel!.testIds[i])")
                    FBAdSettings.addTestDevice(self.adsModel!.testIds[i])
                }
            }
            self.bannerAdViewFB = self.createBannerFacebook(bannerId,kFBAdSizeHeight50Banner)
            self.bannerAdViewFB?.loadAd()
        }
        
    }
    
    func createBannerAdMob(_ bannerId: String, _ adSize: GADAdSize) ->  GADBannerView? {
        let showAds = self.adsModel?.isAllowShowAds ?? false
        if !ApplicationUtils.isOnline() || !showAds || bannerId.isEmpty {
            return nil
        }
        let bannerViewAdmob = GADBannerView(adSize: adSize)
        bannerViewAdmob.rootViewController = self
        bannerViewAdmob.delegate = self
        bannerViewAdmob.adUnitID = bannerId
        return bannerViewAdmob
    }
    
    func createBannerFacebook(_ bannerId: String, _ fbSize: FBAdSize) ->  FBAdView? {
        let showAds = self.adsModel?.isAllowShowAds ?? false
        if !ApplicationUtils.isOnline() || !showAds || bannerId.isEmpty {
            return nil
        }
        let bannerAdViewFB = FBAdView(placementID: bannerId, adSize: fbSize, rootViewController: self)
        bannerAdViewFB.delegate = self
        return bannerAdViewFB
    }
    
    func setUpIntertestialAds(){
        let showAds = self.adsModel?.isAllowShowAds ?? false
        let interstitialId = self.adsModel?.interstitialId ?? ""
        let type = self.adsModel?.typeAds ?? ""
        if !ApplicationUtils.isOnline() || !showAds || interstitialId.isEmpty {
            return
        }
        YPYLog.logE("======>setUpIntertestialAds type=\(type)==>ids=\(interstitialId)")
        if type == AdsModel.TYPE_ADS_ADMOB {
            self.admobInterstitial = GADInterstitial(adUnitID: interstitialId)
            self.admobInterstitial?.delegate = self
            let request = GADRequest()
            self.admobInterstitial?.load(request)
        }
        else if type == AdsModel.TYPE_ADS_FB {
            self.fbIntertestial = FBInterstitialAd(placementID: interstitialId)
            self.fbIntertestial?.delegate = self
            self.fbIntertestial?.load()
        }
    }
    
    func showInterstitialAds() -> Bool{
        let showAds = self.adsModel?.isAllowShowAds ?? false
        let isAdmobReady = self.admobInterstitial?.isReady ?? false
        if showAds && isAdmobReady{
            self.admobInterstitial?.present(fromRootViewController: self)
            return true
        }
        let isFBReady = self.fbIntertestial?.isAdValid ?? false
        if showAds && isFBReady  {
            self.fbIntertestial?.show(fromRootViewController: self)
            return true
        }
        return false
    }
    
    func checkShowAdsWithFreq(_ count: Int, _ freq: Int) -> Bool {
        return freq > 0 && count % freq == 0
    }
    
    func resetAds(){
        self.bannerAdViewFB?.removeFromSuperview()
        self.bannerAdViewFB = nil
        self.bannerViewAdmob?.removeFromSuperview()
        self.bannerViewAdmob = nil
        self.bannerHeight.constant = 0
        self.containerView.layoutIfNeeded()
    }
    
    func onUpdateWhenShowingBanner(_ bannerHeight: CGFloat) {
        self.containerView.layoutIfNeeded()
    }
    
    func onCreateAdsModel() -> AdsModel? {
        return nil
    }
}

extension YPYRootAdsController: NetworkDelegate{
    func onNetworkState(_ isConnect: Bool) {
        if isConnect {
            onDoWhenNetworkOn()
        }
        else {
            onDoWhenNetworkOff()
        }
    }
}

//Delegate for admob ads
extension YPYRootAdsController : GADBannerViewDelegate, GADInterstitialDelegate{
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        if self.bannerViewAdmob != nil && self.bannerViewAdmob == bannerView {
            let sizeHeight: CGFloat = bannerView.bounds.height
            self.bannerHeight.constant = sizeHeight
            bannerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: sizeHeight)
            self.bannerView.addSubview(bannerView)
            self.onUpdateWhenShowingBanner(sizeHeight)
        }
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        YPYLog.logD("========>ADBMOB BANNER ERROR="+error.localizedDescription)
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        self.onInterstitialAdClose()
        self.setUpIntertestialAds()
    }
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        YPYLog.logE("ADBMOB interstitial ERROR:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    @objc(onInterstitialAdClose)
    func onInterstitialAdClose() {
        
    }
    
}
//Delegate for facebook ads
extension YPYRootAdsController : FBInterstitialAdDelegate, FBAdViewDelegate {
    
    func interstitialAdWillClose(_ interstitialAd: FBInterstitialAd) {
        
    }
    
    func interstitialAdDidClose(_ interstitialAd: FBInterstitialAd) {
        self.onInterstitialAdClose()
        self.setUpIntertestialAds()
    }
    func interstitialAd(_ interstitialAd: FBInterstitialAd, didFailWithError error: Error) {
        YPYLog.logE("=======>FACEBOOK interstitial ERROR:didFailWithError: \(error.localizedDescription)")
    }
    
    func adView(_ adView: FBAdView, didFailWithError error: Error) {
        YPYLog.logE("=======>FACEBOOK banner view ERROR:didFailWithError: \(error.localizedDescription)")
    }
    
    func adViewDidLoad(_ bannerView: FBAdView) {
        if self.bannerAdViewFB != nil && self.bannerAdViewFB == bannerView {
            let sizeHeight: CGFloat = bannerView.bounds.height
            self.bannerHeight.constant = sizeHeight
            bannerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: sizeHeight)
            self.bannerView.addSubview(bannerView)
            self.onUpdateWhenShowingBanner(sizeHeight)
        }
    }
}
