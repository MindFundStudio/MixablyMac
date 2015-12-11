//
//  Constants.swift
//  MixablyMac
//
//  Created by Leo Tumwattana on 8/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Foundation

enum MXNotifications: String {
    case ToggleMixably = "toggleMixably"
    case StartPlaying = "startPlaying"
    case PausePlaying = "pausePlaying"
    case StopPlaying = "stopPlaying"
    case ChangeSong = "changeSong"
}

let dragType = "public.text"

enum MXNotificationUserInfo: String {
    case Song = "song"
}
