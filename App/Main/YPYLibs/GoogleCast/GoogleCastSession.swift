//
//  GoogleCastSession.swift
//  iptv-pro
//
//  Created by Do Trung Bao on 8/25/20.
//  Copyright © 2020 YPY Global. All rights reserved.
//

import Foundation
import GoogleCast

protocol CastSessionDelegage {
    func onSessionStart(session: GCKSession)
    func onSessionResume(session: GCKSession)
    func onSessionEnd(session: GCKSession, error: Error?)
    func onSessionError(error: Error?)
}

public class GoogleCastSession: NSObject{
    
    var currentVC: YPYRootViewController?
    var castBt: GCKUICastButton?
    let sessionManager = GCKCastContext.sharedInstance().sessionManager
    var sessionDelegate: CastSessionDelegage?
    
    public override init() {
        super.init()
    }
    
    init(_ vc: YPYRootViewController, _ castBt: GCKUICastButton, _ delegate: CastSessionDelegage? = nil) {
        super.init()
        self.currentVC = vc
        self.castBt = castBt
        self.sessionDelegate = delegate
        self.initSession()
    }
    
    func initSession(){
        NotificationCenter.default.addObserver(self, selector: #selector(castDeviceDidChange),
                                               name: NSNotification.Name.gckCastStateDidChange,
                                               object: GCKCastContext.sharedInstance())
        self.sessionManager.add(self)
        
    }
    
    // You can present the instructions on how to use Google Cast on
    // the first time the user uses you app
    @objc func castDeviceDidChange(_: Notification) {
        if GCKCastContext.sharedInstance().castState != .noDevicesAvailable && self.castBt != nil {
            GCKCastContext.sharedInstance().presentCastInstructionsViewControllerOnce(with: self.castBt!)
        }
    }
    
    func destroySession() {
        self.sessionManager.remove(self)
        NotificationCenter.default.removeObserver(self)
    }
    
    func isConnected() -> Bool {
        let sessionManager = GCKCastContext.sharedInstance().sessionManager
        return sessionManager.hasConnectedCastSession()
    }
    
    func isLoading() -> Bool {
        if let playerState = self.getPlayerState() {
            return playerState == .loading
        }
        return false
    }
    
    func isPlay() -> Bool {
        if let playerState = self.getPlayerState() {
            return playerState == .playing
        }
        return false
    }
    
    func getPlayerState() -> GCKMediaPlayerState? {
        if let remoteMediaClient = sessionManager.currentCastSession?.remoteMediaClient {
            return remoteMediaClient.mediaStatus?.playerState
        }
        return nil
    }
    
    func getRemoteClient() -> GCKRemoteMediaClient? {
        return sessionManager.currentCastSession?.remoteMediaClient
    }
    
    func selectItem(_ mediaInfo: GCKMediaInformation) {
        if !isConnected() { return }
        if let remoteMediaClient = sessionManager.currentCastSession?.remoteMediaClient {
            //stop to clear queue
            remoteMediaClient.stop()
            
            let builder = GCKMediaQueueItemBuilder()
            builder.mediaInformation = mediaInfo
            builder.autoplay = true
            builder.preloadTime = TimeInterval(IPTVConstants.PRELOAD_TIME_S)
            let mediaQueueItem = builder.build()
            
            let queueDataBuilder = GCKMediaQueueDataBuilder(queueType: .generic)
            queueDataBuilder.items = [mediaQueueItem]
            queueDataBuilder.repeatMode = remoteMediaClient.mediaStatus?.queueRepeatMode ?? .off
            let mediaLoadRequestDataBuilder = GCKMediaLoadRequestDataBuilder()
            mediaLoadRequestDataBuilder.queueData = queueDataBuilder.build()
            let request = remoteMediaClient.loadMedia(with: mediaLoadRequestDataBuilder.build())
            request.delegate = self
        }
       
    }
    
}
extension GoogleCastSession: GCKSessionManagerListener, GCKRequestDelegate {
    public func sessionManager(_: GCKSessionManager, didStart session: GCKSession) {
        YPYLog.logD("====>sessionManager didStartSession \(session)")
        self.sessionDelegate?.onSessionStart(session: session)
    }
    
    public func sessionManager(_: GCKSessionManager, didResumeSession session: GCKSession) {
        YPYLog.logD("====>sessionManager didResumeSession \(session)")
        self.sessionDelegate?.onSessionResume(session: session)
    }
    
    public func sessionManager(_: GCKSessionManager, didEnd session: GCKSession, withError error: Error?) {
        YPYLog.logD("====>sessionManager didEnd \(session)===>error \(String(describing: error))")
        let message = getString(StringRes.info_cast_session_end)
        self.currentVC?.showToast(with: message)
        self.sessionDelegate?.onSessionEnd(session: session,error: error)
    }
    
    public func sessionManager(_: GCKSessionManager, didFailToStartSessionWithError error: Error?) {
        YPYLog.logD("====>sessionManager didFailToStartSessionWithError \(String(describing: error))")
        let message = getString(StringRes.info_cast_session_error)
        self.currentVC?.showToast(with: message)
        self.sessionDelegate?.onSessionError(error: error)
    }
    
    public func sessionManager(_: GCKSessionManager, didFailToResumeSession _: GCKSession, withError error: Error?) {
        YPYLog.logD("====>sessionManager didFailToResumeSession \(String(describing: error))")
        let message = getString(StringRes.info_cast_session_error)
        self.currentVC?.showToast(with: message)
        self.sessionDelegate?.onSessionError(error: error)
    }
    
    // MARK: - GCKRequestDelegate
    public func requestDidComplete(_ request: GCKRequest) {
        YPYLog.logD("====>requestDidComplete request \(Int(request.requestID)) completed")
    }
    
    public func request(_ request: GCKRequest, didFailWithError error: GCKError) {
        YPYLog.logD("=====>request \(Int(request.requestID)) failed with error \(error)")
    }
}
