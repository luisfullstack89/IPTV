//
//  GoogleCastManager.swift
//  iptv-pro
//
//  Created by GoogleCastManager on 8/25/20.
//  Copyright © 2020 YPY Global. All rights reserved.
//

import Foundation
import GoogleCast

public class GoogleCastManager: NSObject {
    
    static let shared = GoogleCastManager()
    var listSession: [GoogleCastSession] = []

    private override init() {
        super.init()
    }
    
    func initCast(_ appId: String = kGCKDefaultMediaReceiverApplicationID){
        let criteria = GCKDiscoveryCriteria(applicationID: appId)
        let options = GCKCastOptions(discoveryCriteria: criteria)
        options.physicalVolumeButtonsWillControlDeviceVolume = true
        GCKCastContext.setSharedInstanceWith(options)
        GCKCastContext.sharedInstance().useDefaultExpandedMediaControls = true
        //set up google cast delegate
        GCKLogger.sharedInstance().delegate = self
    }

    func setCastTintColor(_ color: UIColor) {
        GCKUICastButton.appearance().tintColor = color
    }
    
    func addSession(_ vc: YPYRootViewController, _ btnCast: GCKUICastButton, _ delegate: CastSessionDelegage?) -> GoogleCastSession? {
        let index = self.listSession.firstIndex(where: {return $0.currentVC == vc}) ?? -1
        if index >= 0 {return nil }
        let session = GoogleCastSession (vc, btnCast, delegate)
        listSession.append(session)
        return session
    }
    
    func removeSession(_ vc: YPYRootViewController){
        self.listSession.removeAll(where: {return $0.currentVC == vc})
    }
    
}
// MARK: - GCKLoggerDelegate
extension GoogleCastManager: GCKLoggerDelegate {
    public func logMessage(_ message: String,
                           at level: GCKLoggerLevel,
                           fromFunction function: String,
                           location: String) {
        YPYLog.logE("======google cast info: \(function) - \(message)")
    }
}
