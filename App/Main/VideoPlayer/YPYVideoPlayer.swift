//
//  YPYPlayerView.swift
//  iptv-pro
//
//  Created by YPY Global on 8/21/20.
//  Copyright © 2020 YPY Global. All rights reserved.
//

import Foundation
import MobileVLCKit
import UIKit

public class YPYVideoPlayer: NSObject {
    let KEY_MAX_FPS = "max-fps"
    let KEY_TIME_OUT = "timeout"
    let KEY_VIDEO_TOOLBOX = "videotoolbox"
    let KEY_FRAME_DROP = "framedrop"
    let KEY_RECONNECT = "reconnect"
    let KEY_USER_AGENT = "user-agent"
    let KEY_AUTO_CONVERT = "auto_convert"
    let KEY_VIDEO_PICT_SIZE = "video-pictq-size"
    let KEY_VIDEO_TOOLBOX_MAX_FRAME_WIDTH = "videotoolbox-max-frame-width"
    let KEY_SYNC_AV_START = "sync-av-start"
    let KEY_DNS_CACHE = "dns_cache_clear"
    
    var autoReconnect: Int64 = 1
    var maxFPSValue: Int64 = 25
    var toolboxValue: Int64 = 0
    var frameDropValue: Int64 = 1
    var pictureSizeValue: Int64 = 3
    var autoConvertValue: Int64 = 3
    var timeoutValue: Int64 = 30 * 1000 * 1000
    var toolboxMaxFrameWidthValue: Int64 = 960
    var synchroniseAudioVideoStartTimeValue: Int64 = 1
    
    var isPausedByUser = false
    var isStreamContainsAudio = false
    var isStreamContainsVideo = false
        
    private let player: VLCMediaPlayer = {
        let player = VLCMediaPlayer()
        player.libraryInstance.debugLogging = true
        return player
    }()
    
    var loadDelegate: YPYPlayerLoadDelegate?
    var playbackDelegate: YPYPlayerPlaybackDelegate?
    var timelineDelegate: YPYPlayerTimelineDelegate?
    
    var containerView: UIView!
    private var seekTimer = Timer()
    
    override public required init() {
        super.init()
    }
    
    init(_ container: UIView) {
        super.init()
        self.containerView = container
        self.updateOption()
    }
    
    func setVideoUri(_ uri: String) -> Bool {
        self.stopPlayBack()
//        let uriTemp = "http://127.0.0.1:8080/"
//        let url = URL(string: uriTemp)
        let url = URL(string: uri)
        
        player.media = VLCMedia(url: url!)
        
        self.player.delegate = self
        self.player.drawable = self.containerView
        self.player.libraryInstance.setHumanReadableName(KEY_USER_AGENT, withHTTPUserAgent: IPTVConstants.USER_AGENT_VALUE)
        // start load player
        self.player.play()
        self.loadDelegate?.onLoadVideo(true)
        
        return true
    }
    
    func updateOption() {
//        self.options?.setFormatOptionIntValue(autoReconnect, forKey: KEY_RECONNECT)
//        self.options?.setFormatOptionValue(IPTVConstants.USER_AGENT_VALUE, forKey: KEY_USER_AGENT)
//        self.options?.setFormatOptionIntValue(autoConvertValue, forKey: KEY_AUTO_CONVERT)
//        self.options?.setFormatOptionIntValue(timeoutValue, forKey: KEY_TIME_OUT)
//        self.options?.setFormatOptionIntValue(maxFPSValue, forKey: KEY_MAX_FPS)
//        self.options?.setFormatOptionIntValue(toolboxValue, forKey: KEY_VIDEO_TOOLBOX)
//        self.options?.setFormatOptionIntValue(frameDropValue, forKey: KEY_FRAME_DROP)
//        self.options?.setFormatOptionIntValue(pictureSizeValue, forKey: KEY_VIDEO_PICT_SIZE)
//        self.options?.setFormatOptionIntValue(toolboxMaxFrameWidthValue, forKey: KEY_VIDEO_TOOLBOX_MAX_FRAME_WIDTH)
//        self.options?.setFormatOptionIntValue(synchroniseAudioVideoStartTimeValue, forKey: KEY_SYNC_AV_START)
    }
    
    func onTogglePlay() {
        if !self.isPrepared() { return }
        if !self.isPlaying() {
            self.play()
        }
        else {
            self.pause()
        }
    }
    
    func play() {
        if !self.isPrepared() { return }
        self.isPausedByUser = false
        if !self.isPlaying() {
            self.player.play()
        }
    }
    
    func pause() {
        if !self.isPrepared() { return }
        self.isPausedByUser = true
        if self.isPlaying() {
            self.player.pause()
        }
    }
    
    func stopPlayBack() {
        self.isStreamContainsAudio = false
        self.isStreamContainsVideo = false
        
        self.player.stop()
        if let view = self.player.drawable as? UIView {
            view.removeFromSuperview()
        }
        self.player.drawable = nil
    }

    func isPrepared() -> Bool {
        return true
    }
    
    func isPlaying() -> Bool {
        return self.player.isPlaying
    }
    
    func setCurrentPos(_ pos: TimeInterval) {
        let duration = self.getDuration()
        if !self.isLive(), duration > 0, pos <= duration {
            self.player.time = VLCTime(number: NSNumber(value: pos * 1000))
            return
        }
    }
    
    func getCurrentPos() -> TimeInterval {
        if let value = self.player.time?.value?.doubleValue {
            return value / 1000
        }
        return 0
    }
    
    func getDuration() -> TimeInterval {
        if let value = player.media.length.value?.doubleValue {
            return value / 1000
        }
        return 0
    }
    
    func getMetadata() -> [AnyHashable: Any]? {
        return self.player.media.metaDictionary
    }
    
    func getVideoMetadata() -> [AnyHashable: Any]? {
        return self.player.media.metaDictionary
    }
    
    func getVideoMetaDataOfKey(_ key: String) -> String? {
        return self.player.media.metadata(forKey: key)
    }
    
    func getAudioMetaDataOfKey(_ key: String) -> String? {
        return self.player.media.metadata(forKey: key)
    }

    func isLive() -> Bool {
        if self.isPrepared() {
            return (self.player.media.length.value?.doubleValue ?? 0) <= 0
        }
        return false
    }
}

// MARK: - VLC delegate
extension YPYVideoPlayer: VLCMediaPlayerDelegate {
    public func mediaPlayerStateChanged(_ aNotification: Notification!) {
        switch self.player.state {
        case .stopped:
            self.playbackDelegate?.onUpdatePlaybackState(state: .Stop)
        case .paused:
            self.playbackDelegate?.onUpdatePlaybackState(state: .Pause)
        case .playing:
            self.player.audio.volume = 100
            self.playbackDelegate?.onUpdatePlaybackState(state: .Play)
        case .ended:
            self.loadDelegate?.didFinishWithReason(reason: .PlaybackEnded)
        case .esAdded:
            self.loadDelegate?.onLoadVideo(false)
            self.isStreamContainsVideo = self.player.hasVideoOut
            self.isStreamContainsAudio = self.player.numberOfAudioTracks > 0
        case .buffering, .opening:
            break
        default:
            self.loadDelegate?.onLoadVideo(true)
            self.playbackDelegate?.onUpdatePlaybackState(state: .Interrupt)
        }
    }
    
    public func mediaPlayerTimeChanged(_ aNotification: Notification!) {
        var current = self.getCurrentPos()
        let duration = self.getDuration()
        if duration > 0, current >= duration {
            current = duration
        }
        self.timelineDelegate?.onUpdateTimeline(current, duration)
    }
}
