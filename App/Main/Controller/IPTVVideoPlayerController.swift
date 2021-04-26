//
//  IPTVVideoPlayerController.swift
//  iptv-pro
//  Created by YPY Global on 8/21/20.
//  Copyright © 2020 YPY Global. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds
import MediaPlayer
import Sheeeeeeeeet
import GoogleCast
import FBAudienceNetwork

class IPTVVideoPlayerController: YPYRootAdsController {
    
    let TIME_OUT_HIDDEN = 2.5
    let TIME_OUT_VOLUME_HIDDEN = 1.5
    let MAX_CONTROL: Float = 10.0
    let DELTA_VELOCITY: CGFloat = 30.0
    let MIN_BRIGHTNESS_THRESHOLD: CGFloat = 0.01
    
    @IBOutlet weak var lblTitleScreen: UILabel!
    @IBOutlet weak var actionBarConstraint: NSLayoutConstraint!
    @IBOutlet weak var actionBar: UIView!
    @IBOutlet weak var videoContainer: UIView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var bottomActionView: UIView!
    @IBOutlet weak var bottomHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var btnLock: UIButton!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var imgLive: UIImageView!
    @IBOutlet weak var lblCurrentTime: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var btnFullScreen: UIButton!
    @IBOutlet weak var seekBar: UISlider!
    @IBOutlet weak var seekBarContainer: UIView!
    @IBOutlet weak var seekBarConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imgTapControl: UIImageView!
    @IBOutlet weak var btnPrev: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnUnlock: UIButton!
    
    @IBOutlet weak var layoutGestureView: UIStackView!
    @IBOutlet weak var imgGesture: UIImageView!
    @IBOutlet weak var lblGesture: UILabel!
    
    var mediumViewAdmob: GADBannerView? = nil
    var mediumViewFB: FBAdView? = nil
    
    @IBOutlet weak var mediumAdsConstraint: NSLayoutConstraint!
    @IBOutlet weak var layoutMediumAds: UIView!
    
    @IBOutlet weak var imgChromecast: UIImageView!
    @IBOutlet weak var btnCast: GCKUICastButton!
    var castSession: GoogleCastSession?
    var castRemoteClient: GCKRemoteMediaClient?
    
    var tempValue: Float = 0.0
    let maxSeekBar: Float = 100.0
    
    var movieModel: MovieModel?
    var listMovies : [MovieModel]?
    var videoPlayer: YPYVideoPlayer!
    var currentIndex = 0
    
    private var layoutControlWorkItem: DispatchWorkItem?
    private var gestureWorkItem: DispatchWorkItem?
    
    var isCheckPause = false
    var isAppInBackground = false
    
    private var isFullScreen = false
    private var isLocked = false
    private var initialCenter = CGPoint()
    
    var touchDirection : HoriTouchDirection = .none
    var swipeDirection : VertiSwipeDirection = .none
    
    let volumeView = MPVolumeView()
    let audioSession = AVAudioSession.sharedInstance()
    var currentVolume: Float = 0.0
    var pivotVelocity: CGPoint = CGPoint()
    private var isFirstTime = false
    
    var currentBrightness: CGFloat = 0.0
    
    override func setUpUI() {
        super.setUpUI()
        
        //hide next or prev when just only one video
        let isOnlyOne = isOnlyOneInList()
        self.btnPrev.alpha = isOnlyOne ? 0.5 : 1.0
        self.btnPrev.isEnabled = !isOnlyOne
        self.btnNext.alpha = isOnlyOne ? 0.5 : 1.0
        self.btnNext.isEnabled = !isOnlyOne
        
        self.imgTapControl.isUserInteractionEnabled = true
        self.addTapGesture()
        
        self.initVolumeView()
        
        self.initPlayer()
        self.registerObserverBackForeGround()
        
        self.initGoogleCast()
        
        self.showLoading(true)
        if let movie = self.movieModel {
            self.setUpVideoInfo(movie)
            self.setUpPlayer(movie)
        }
    
    }
    
    func initGoogleCast() {
        self.castSession = GoogleCastManager.shared.addSession(self, self.btnCast, self)
    }
    
    private func initPlayer() {
        self.videoPlayer = YPYVideoPlayer(self.videoContainer)
        self.videoPlayer.loadDelegate = self
        self.videoPlayer.playbackDelegate = self
        self.videoPlayer.timelineDelegate = self
    }
    
    private func initBrightness () {
        var currentBrightness = UIScreen.main.brightness
        self.currentBrightness = floor(currentBrightness * CGFloat(MAX_CONTROL))
        if currentBrightness < self.MIN_BRIGHTNESS_THRESHOLD {
            currentBrightness = self.MIN_BRIGHTNESS_THRESHOLD
            self.currentBrightness = 0.0
        }
    }
    
    
    private func initVolumeView(){
        //self.addObserverVolume()
        //hide volume view in this screen
        self.volumeView.frame = .zero
        self.volumeView.clipsToBounds = true
        self.view.addSubview(volumeView)
        
        do {
            try audioSession.setActive(true)
            self.currentVolume = audioSession.outputVolume
        }
        catch {
            YPYLog.logE("====Error Setting Up Audio Session")
        }
        
    }
    
    func addTapGesture() {
        self.imgTapControl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(controlTap)))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureTap))
        self.imgTapControl.addGestureRecognizer(panGesture)
   
    }
    
    override func onDoWhenNetworkOn() {
        super.onDoWhenNetworkOn()
        self.setUpMediumAds()
    }

    override func updateCustomizeViewConstraint() {
        self.actionBarConstraint.constant = getDimen(DimenRes.action_bar_sizes)
        self.actionBar.layoutIfNeeded()
        
        self.bottomHeightConstraint.constant = getDimen(DimenRes.row_list_height_sizes)
        self.bottomActionView.layoutIfNeeded()
        
        self.seekBarConstraint.constant = getDimen(DimenRes.medium_img_sizes)
        self.seekBarContainer.layoutIfNeeded()
    }
    
    func setUpVideoInfo(_ movie: MovieModel){
        self.movieModel = movie
        self.lblTitleScreen.text = movie.name
    }
    
    func setUpPlayer(_ movie: MovieModel) {
        if let linkModel = movie.getLinkModel() {
            let urlMovie = linkModel.getLinkPlay()
            YPYLog.logE("====>linkURI=\(urlMovie)")
            let isPlayOk = self.videoPlayer.setVideoUri(urlMovie)
            YPYLog.logE("====>isPlayOk=\(isPlayOk)")
            if isPlayOk {
                self.onStartLoadMovie()
                return
            }
        }
        YPYLog.logE("====>setUpPlayer=error")
        self.backToHome()
    }
    
    func onStartLoadMovie() {
        self.showLayoutControl(false,false)
        self.lblDuration.text = "00:00"
        self.lblCurrentTime.text = "00:00"
    }
 
    
    override func onMoveToForeground() {
        super.onMoveToForeground()
        self.isAppInBackground = false
        if self.videoPlayer != nil && self.isCheckPause {
            self.isCheckPause = false
            self.showLayoutControl(true, true)
            self.videoPlayer!.play()
        }
    }
    
    override func onMoveToBackground() {
        super.onMoveToBackground()
        self.isAppInBackground = true
        if self.videoPlayer.isPlaying() {
            self.isCheckPause = true
            self.showLayoutControl(true, false)
            self.videoPlayer.pause()
        }
    }
    
    override func onCreateAdsModel() -> AdsModel? {
        let typeAds = SettingManager.getAdsType()
        if typeAds == AdsModel.TYPE_ADS_FB {
            let adsModel = AdsModel(isAllowShow: IPTVConstants.SHOW_ADS, banner: IPTVConstants.FACEBOOK_BANNER_ID, interstitial: IPTVConstants.FACEBOOK_INTERSTITIAL_ID)
            adsModel.mediumId = IPTVConstants.FACEBOOK_MEDIUM_ID
            adsModel.addTestId(IPTVConstants.FACEBOOK_TEST_ID)
            adsModel.typeAds = typeAds
            return adsModel
        }
        else{
            let adsModel = AdsModel(isAllowShow: IPTVConstants.SHOW_ADS, banner: IPTVConstants.ADMOB_BANNER_ID, interstitial: IPTVConstants.ADMOB_INTERSTITIAL_ID)
            adsModel.mediumId = IPTVConstants.ADMOB_MEDIUM_ID
            adsModel.addTestId(IPTVConstants.ADMOB_TEST_ID)
            adsModel.typeAds = typeAds
            return adsModel
        }

    }
    
    @IBAction func backTap(_ sender: Any) {
        if self.isFullScreen {
            self.switchFullScreen()
            return
        }
        self.backToHome()
    }

    func backToHome(){
        if self.backStack() {
            self.unregisterObserverBackForeGround()
            self.videoPlayer.stopPlayBack()
            
            self.castRemoteClient?.remove(self)
            self.castSession?.destroySession()
            GoogleCastManager.shared.removeSession(self)
            return
        }
    }
    
    @IBAction func menuTap(_ sender: Any) {
        self.showDialogMenu()
    }
    
    func showDialogMenu() {
        var items:[MenuItem] = []
        let menuTitle = MenuTitle(title: getString(StringRes.title_select_language))
        items.append(menuTitle)
        
        if self.videoPlayer.isPrepared() {
            let menuItemInfo = MenuItem(title: getString(StringRes.title_information), value: IPTVConstants.ID_MENU_VIDEO_INFO)
            items.append(menuItemInfo)
        }
        
        let menuItemShare = MenuItem(title: getString(StringRes.title_share_video), value: IPTVConstants.ID_MENU_SHARE)
        items.append(menuItemShare)
        
        let menu = Menu(items: items)
        let sheet = menu.toActionSheet { (sheet, menuItem) in
            if let id = menuItem.value as? Int {
                self.processMenuItem(id)
            }
        }
        let isPad = Display.pad
        sheet.present(in: self, from: isPad ? self.btnMenu : self.view)
    }
    
    func processMenuItem(_ id: Int) {
        if id == IPTVConstants.ID_MENU_SHARE {
            if let strShare = movieModel?.getShareStr() {
                self.shareContent(strShare, IPTVConstants.APP_ID, self.btnMenu)
            }
        }
        else if id == IPTVConstants.ID_MENU_VIDEO_INFO {
            self.showVideoInfo()
        }
    }
    private func showVideoInfo() {
        var infos: [String] = []
        if self.videoPlayer.isStreamContainsVideo {
            if let bitrate = self.videoPlayer.getVideoMetaDataOfKey("bitrate"), !bitrate.isEmpty {
                if bitrate.isNumber() {
                    infos.append("Video bitrate: \(Int(bitrate)!/1000) kb")
                }
                else{
                    infos.append("Video bitrate: \(bitrate)")
                }
            }
            if let codec = self.videoPlayer.getVideoMetaDataOfKey("codec_name"), !codec.isEmpty {
                infos.append("Video codec: \(codec)")
            }
            if let codecDes = self.videoPlayer.getVideoMetaDataOfKey("codec_long_name"), !codecDes.isEmpty {
                infos.append("Video codec name: \(codecDes)")
            }
            if let width = self.videoPlayer.getVideoMetaDataOfKey("width"), !width.isEmpty {
                if let height = self.videoPlayer.getAudioMetaDataOfKey("width"), !height.isEmpty {
                    infos.append("Video size: \(width)x\(height)")
                }
            }
        }
        if self.videoPlayer.isStreamContainsAudio {
            if let bitrate = self.videoPlayer.getAudioMetaDataOfKey("bitrate"), !bitrate.isEmpty {
                if bitrate.isNumber() {
                    infos.append("Audio bitrate: \(Int(bitrate)!/1000) kb")
                }
                else{
                    infos.append("Audio bitrate: \(bitrate)")
                }
            }
            if let codec = self.videoPlayer.getAudioMetaDataOfKey("codec_name"), !codec.isEmpty {
                infos.append("Audio codec: \(codec)")
            }
            if let codecDes = self.videoPlayer.getAudioMetaDataOfKey("codec_long_name"), !codecDes.isEmpty {
                infos.append("Audio codec name: \(codecDes)")
            }
        }
        let strInfo = infos.joined(separator: "\n")
        YPYLog.logE("======>strInfo=\(strInfo)")
        self.showFullAlertWith(title: getString(StringRes.title_information), message: strInfo,positive: getString(StringRes.title_ok))
    }
    
    @IBAction func fullScreenTap(_ sender: Any) {
        self.switchFullScreen()
    }
    
   private func showLoading(_ isShow: Bool) {
        self.indicatorView.isHidden = !isShow
        if isShow {
            self.indicatorView.startAnimating()
        }
        else{
            self.indicatorView.stopAnimating()
        }
    }
    
    func onChangeVideo (_ count: Int, _ isError: Bool){
        let sizeMovie = self.listMovies?.count ?? 0
        if sizeMovie == 0 || isError { return }
        self.currentIndex = self.currentIndex + count
        if self.currentIndex >= sizeMovie {
            self.currentIndex = 0
        }
        if self.currentIndex < 0 {
            self.currentIndex = sizeMovie - 1
        }
        let movie = self.listMovies![self.currentIndex]
        self.setUpVideoInfo(movie)
        self.setUpPlayer(movie)
    }
    
    @IBAction func nextTap(_ sender: Any) {
        if isCastConnect() { return }
        self.onChangeVideo(1, false)
    }
    
    @IBAction func prevTap(_ sender: Any) {
        if isCastConnect() { return }
        self.onChangeVideo(-1, false)
    }
    
    @IBAction func playTap(_ sender: Any) {
        if isCastConnect() {
            self.sendCastStatus()
            return
        }
        self.videoPlayer?.onTogglePlay()
    }
    
    @IBAction func seekBarChange(_ sender: Any) {
        self.tempValue = self.seekBar.value
    }
       
    @IBAction func seekBarTap(_ sender: Any) {
        if self.tempValue > 0 {
            if self.videoPlayer.isPlaying() && self.imgLive.isHidden {
                let duration = self.videoPlayer.getDuration()
                if  duration > 0 {
                    let currentTime = duration * Double(self.tempValue / self.maxSeekBar)
                    self.videoPlayer.setCurrentPos(currentTime)
                }
            }
        }
    }
    
    func updateLiveStatus() {
        let isLive = self.videoPlayer.isLive()
        self.imgLive.isHidden = !isLive
        self.seekBar.isEnabled = !isLive
    }
    
    @IBAction func lockTap(_ sender: Any) {
        if isCastConnect() { return }
        self.isLocked = true
        self.showLayoutControl(true, true)
    }

    @IBAction func unlockTap(_ sender: Any) {
        self.isLocked = false
        self.showLayoutControl(true, true)
    }
    
    func showLayoutControl(_ isShow: Bool ,_ isAutoHide: Bool) {
        if isLocked {
            self.btnUnlock.isHidden = !isShow
            self.seekBarContainer.isHidden = true
            self.bottomActionView.isHidden = true
            self.actionBar.isHidden = true
        }
        else{
            if self.isCastConnect() {
                self.seekBarContainer.isHidden = true
                self.bottomActionView.isHidden = false
                self.actionBar.isHidden = false
                return
            }
            self.btnUnlock.isHidden = true
            self.seekBarContainer.isHidden = !isShow
            self.bottomActionView.isHidden = !isShow
            self.actionBar.isHidden =  !isShow && self.videoPlayer.isPrepared()
        }
        self.layoutControlWorkItem?.cancel()
        if isShow && isAutoHide {
            self.layoutControlWorkItem =  DispatchWorkItem(block: {
                if self.videoPlayer.isPrepared() {
                    self.actionBar.isHidden = true
                    self.seekBarContainer.isHidden = true
                    self.bottomActionView.isHidden = true
                    self.btnUnlock.isHidden = true
                }
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + self.TIME_OUT_HIDDEN,execute: layoutControlWorkItem!)
        }
    }
    
    func isOnlyOneInList() -> Bool {
        return listMovies != nil && listMovies!.count <= 1
    }

    func switchFullScreen(){
        let isFullScreen = !self.isFullScreen
        if isFullScreen {
            AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.landscapeRight, andRotateTo: UIInterfaceOrientation.landscapeRight)
        }
        else{
            AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.isFullScreen = UIDevice.current.orientation.isLandscape
        let image = UIImage(named: self.isFullScreen ? ImageRes.ic_fullscreen_white_exit_24dp :ImageRes.ic_fullscreen_white_24dp)
        self.btnFullScreen.setImage(image, for: .normal)
        self.resetAds()
        if !self.isFullScreen || IPTVConstants.SHOW_ADS_IN_VIDEO_LANDSCAPE {
            self.setUpBannerAds()
        }
        self.setUpMediumAds()
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        }
        else {
            return .all
        }
    }
    
    override var shouldAutorotate: Bool{
        return true
    }
    
    override func resetAds(){
        super.resetAds()
        self.mediumViewFB?.removeFromSuperview()
        self.mediumViewFB = nil
        
        self.mediumViewAdmob?.removeFromSuperview()
        self.mediumViewAdmob = nil
     }
    
    func setUpMediumAds() {
        if self.mediumViewAdmob != nil || self.mediumViewFB != nil  {
            return
        }
        let type = self.adsModel?.typeAds ?? ""
        let bannerId = self.adsModel?.mediumId ?? ""
        YPYLog.logE("======>setUpMediumAds  type=\(type)==>bannerId=\(bannerId)")
        if type == AdsModel.TYPE_ADS_ADMOB {
            self.mediumViewAdmob = self.createBannerAdMob(bannerId, kGADAdSizeMediumRectangle)
            self.mediumViewAdmob?.delegate = self
            let request = GADRequest()
            self.mediumViewAdmob?.load(request)
        }
        else if type == AdsModel.TYPE_ADS_FB {
            self.mediumViewFB = self.createBannerFacebook(bannerId,kFBAdSizeHeight250Rectangle)
            self.mediumViewFB?.loadAd()
        }
        
    }
    
    override func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        super.adViewDidReceiveAd(bannerView)
        if self.mediumViewAdmob != nil && bannerView == self.mediumViewAdmob {
            let sizeHeight: CGFloat = bannerView.bounds.height
            self.mediumAdsConstraint.constant = sizeHeight
            bannerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: sizeHeight)
            self.layoutMediumAds.addSubview(bannerView)
            self.layoutMediumAds.layoutIfNeeded()
        }
    }
    
    override func adViewDidLoad(_ bannerView: FBAdView) {
        super.adViewDidLoad(bannerView)
        if self.mediumViewFB != nil && self.mediumViewFB == bannerView {
            let sizeHeight: CGFloat = bannerView.bounds.height
            self.mediumAdsConstraint.constant = sizeHeight
            bannerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: sizeHeight)
            self.layoutMediumAds.addSubview(bannerView)
            self.layoutMediumAds.layoutIfNeeded()
        }
    }
    
    
    @objc func controlTap(gesture: UITapGestureRecognizer){
        if self.isCastConnect() {
            self.showLayoutControl(true, false)
            return
        }
        if self.videoPlayer.isPrepared() {
           self.showLayoutControl(true, true)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let position = touch.location(in: view)
            let screenW = self.view.frame.width
            self.touchDirection = position.x <= screenW/2 ? .left : .right
        }
    }
   
    @objc func panGestureTap(gesture: UIPanGestureRecognizer) {
        if self.isCastConnect() || self.isLocked {return}

        let velocity = gesture.velocity(in: self.imgTapControl)
        if self.pivotVelocity.y == 0 && self.pivotVelocity.x == 0  {
            self.pivotVelocity.x = velocity.x
            self.pivotVelocity.y = velocity.y
        }
        let deltaY = abs(velocity.y - self.pivotVelocity.y)
        if deltaY >= DELTA_VELOCITY {
            self.swipeDirection = velocity.y > 0.0 ? .down : .up
            self.implementGesture()
            self.pivotVelocity.x = velocity.x
            self.pivotVelocity.y = velocity.y
        }
    }
    
    func implementGesture() {
        let count = self.swipeDirection == .up ? 1 : -1
        if self.touchDirection == .left {
            //start edit brightness
            self.changeBrightness(count)
        }
        else if self.touchDirection == .right {
            //start edit volume
            self.changeVolume(count)
            
        }
    }
    
    func changeBrightness(_ count: Int) {
        let max = CGFloat(self.MAX_CONTROL)
        var brightness = self.currentBrightness * max + CGFloat(count)
        if brightness > max {
            brightness = max
        }
        if brightness < 0.0 {
            brightness = 0.0
        }
        self.currentBrightness = CGFloat(brightness/max)
        self.setUpBrightness(brightness)
    }
    
    func setUpBrightness(_ brightness: CGFloat) {
        let intBrightness = Int(brightness)
        let strIntBright = String(intBrightness)
        let imgRes = ImageRes.ic_brightness
        let text = String(format: getString(StringRes.format_brightness), strIntBright)
        self.showGesture(imgRes, text)
        
        //use tmp value to set brightness
        var updateValue = brightness / CGFloat(self.MAX_CONTROL)
        if updateValue < self.MIN_BRIGHTNESS_THRESHOLD {
            updateValue = self.MIN_BRIGHTNESS_THRESHOLD
        }
        UIScreen.main.brightness = updateValue
    }
    
    
    func changeVolume(_ count: Int) {
        var volume = self.currentVolume * self.MAX_CONTROL + Float(count)
        if volume > self.MAX_CONTROL {
            volume = self.MAX_CONTROL
        }
        if volume < 0.0 {
            volume = 0.0
        }
        self.currentVolume = Float(volume/self.MAX_CONTROL)
        self.setUpVolume(volume)
    }
    
    func setUpVolume(_ volumeChange: Float){
        var volume: Float  = volumeChange
        if volume < 1.0 {
            volume = 0.0
        }
        //change volume slider
        for view in volumeView.subviews {
            if let slider = view as? UISlider {
                slider.value = self.currentVolume
                break
            }
        }
        let intVolume = Int(volume)
        let strIntVolume = String(intVolume)
        let imgRes = intVolume > 0 ? ImageRes.ic_video_volume : ImageRes.ic_video_volume_mute
        let text = intVolume > 0 ? String(format: getString(StringRes.format_volume), strIntVolume) : getString(StringRes.title_muted)
        self.showGesture(imgRes, text)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.onResetVelocityPoint()
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.onResetVelocityPoint()
    }
    
    func onResetVelocityPoint() {
        self.pivotVelocity.x = 0
        self.pivotVelocity.y = 0
    }
    
    func showGesture(_ resImgId: String, _ text: String){
        self.gestureWorkItem?.cancel()
        self.lblGesture.text = text
        self.imgGesture.image = UIImage(named: resImgId)
        self.layoutGestureView.isHidden = false
        self.gestureWorkItem =  DispatchWorkItem(block: {
            self.layoutGestureView.isHidden = true
            self.touchDirection = .none
            self.swipeDirection = .none
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + self.TIME_OUT_VOLUME_HIDDEN,execute: gestureWorkItem!)
    }
  
    
}
extension IPTVVideoPlayerController: YPYPlayerLoadDelegate {
    
    func onLoadVideo(_ isLoad: Bool) {
        self.showLoading(isLoad)
    }
    
    func preparedToPlay() {
        self.showLoading(false)
        self.updateLiveStatus()
        self.showLayoutControl(true,true)
    }
        
    func didFinishWithReason(reason: PlayerFinishReason) {
        YPYLog.logE("=======>didFinishWithReason=\(reason)")
        self.updatePlayerState(false)
        if reason == .PlaybackEnded {
            if isOnlyOneInList() {
                self.backToHome()
                return
            }
            self.onChangeVideo(1, false)
        }
        else{
            self.showDialogPlayerError()
        }
    }
    func showDialogPlayerError() {
        let msg = getString(StringRes.info_play_video_error)
        let titleCancel = getString(StringRes.title_cancel)
        let titlePositive = getString(self.isOnlyOneInList() ? StringRes.title_back : StringRes.title_next)
        if isOnlyOneInList() {
            self.showAlertWith(title: getString(StringRes.title_information), message: msg, positive: titlePositive, completion: {
                 self.backToHome()
            })
        }
        else{
            self.showAlertWith(title: getString(StringRes.title_information), message: msg, positive: titlePositive, negative: titleCancel, completion: {
                self.onChangeVideo(1, false)
            }, cancel: {
                self.backToHome()
            })
        }
    }
    
}
extension IPTVVideoPlayerController : YPYPlayerPlaybackDelegate {
    
    func onUpdatePlaybackState(state: PlaybackState) {
        if self.isCastConnect() {
            self.videoPlayer.pause()
            return
        }
        let isPlay = state == .Play
        self.updatePlayerState(isPlay)
        //pause video if vc is moved to background
        if isPlay && self.isAppInBackground {
            self.onMoveToBackground()
        }
        self.layoutMediumAds.isHidden = !self.videoPlayer.isPausedByUser
        if self.videoPlayer.isPausedByUser {
            self.showLayoutControl(true, false)
        }
        else if isPlay {
            self.showLayoutControl(true, true)
        }
    }
    
    func updatePlayerState( _ isPlay: Bool){
        let img = UIImage(named: isPlay ? ImageRes.ic_pause_white_36dp : ImageRes.ic_play_white_36dp)
        self.btnPlay.setImage(img, for: .normal)
    }
    
}
extension IPTVVideoPlayerController: YPYPlayerTimelineDelegate {
    
    func onUpdateTimeline(_ current: TimeInterval, _ duration: TimeInterval) {
        self.lblCurrentTime.text = DateTimeUtils.convertToStringTime(time: current)
        if self.imgLive.isHidden && duration > 0 {
            self.lblDuration.text = DateTimeUtils.convertToStringTime(time: duration)
            let progress = self.maxSeekBar * Float(current/duration)
            self.seekBar.value = progress < maxSeekBar  ? progress : self.maxSeekBar
        }
    }
}

extension IPTVVideoPlayerController : CastSessionDelegage {
    
    func onSessionStart(session: GCKSession) {
        showCastInfo(true)
        if let mediaInfo = self.movieModel?.getCastMediaInfo() {
            self.castSession?.selectItem(mediaInfo)
        }
    }
    
    func onSessionResume(session: GCKSession) {
        
    }
    
    func onSessionEnd(session: GCKSession, error: Error?) {
        showCastInfo(false)
    }
    
    func onSessionError(error: Error?) {
        showCastInfo(false)
    }
    
    func showCastInfo(_ isShow: Bool) {
        self.layoutMediumAds.isHidden = isShow
        self.btnNext.isHidden = isShow
        self.btnPrev.isHidden = isShow
        self.btnLock.isHidden = isShow
        self.btnFullScreen.isHidden = isShow
        self.imgChromecast.isHidden = !isShow
        self.layoutMediumAds.isHidden = isShow
        self.seekBarContainer.isHidden = isShow
        
        if isShow {
            self.videoPlayer.pause()
            self.showLayoutControl(true, false)
            self.updatePlayerState(self.castSession?.isPlay() ?? false)
            
            //add or remove listener
            self.castRemoteClient?.remove(self)
            self.castRemoteClient = self.castSession?.getRemoteClient()
            self.castRemoteClient?.add(self)
        }
        else{
            self.updatePlayerState(self.videoPlayer.isPlaying())
            self.videoPlayer.onTogglePlay()
        }
     
    }
    func isCastConnect() -> Bool {
        return self.castSession?.isConnected() ?? false
    }
    
}
extension IPTVVideoPlayerController : GCKRemoteMediaClientListener{
    
    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        self.updatePlayerState(self.castSession?.isPlay() ?? false)
    }
    
    func sendCastStatus() {
        let isLoading = self.castSession?.isLoading() ?? false
        if isLoading {
            self.updatePlayerState(false)
            return
        }
        let isPlay = self.castSession?.isPlay() ?? false
        if isPlay {
            self.castRemoteClient?.pause()
        }
        else{
             self.castRemoteClient?.play()
        }
        
        
    }
}
