//
//  YPYVideoPlayerDelegate.swift
//  iptv-pro
//
//  Created by YPY Global on 8/21/20.
//  Copyright © 2020 YPY Global. All rights reserved.
//

import Foundation
import UIKit

protocol YPYPlayerLoadDelegate {
    func onLoadVideo(_ isLoad: Bool)
    func preparedToPlay()
    func didFinishWithReason(reason: PlayerFinishReason)
}

protocol YPYPlayerTimelineDelegate {
    func onUpdateTimeline(_ current: TimeInterval, _ duration: TimeInterval)
}

protocol YPYPlayerPlaybackDelegate {
    func onUpdatePlaybackState(state: PlaybackState)
}

enum PlayerFinishReason: Int{
    case UnknownError = -1, PlaybackEnded, PlaybackError, NetworkError, UserExited
}
enum PlaybackState: Int{
    case Play =  0, Pause, Stop, Interrupt,SeekingForward,SeekingBackward, Error
}
