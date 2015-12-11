//
//  Constants.swift
//  MixablyMac
//
//  Created by Leo Tumwattana on 8/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Foundation

// MARK: - Notifications

enum MXNotifications: String {
    case ToggleMixably = "toggleMixably"
    case StartPlaying = "startPlaying"
    case PausePlaying = "pausePlaying"
    case StopPlaying = "stopPlaying"
    case ChangeSong = "changeSong"
    case SelectPlaylist = "selectPlaylist"
}

enum MXNotificationUserInfo: String {
    case Song = "song"
    case Playlist = "playlist"
}

// MARK: - Display

let AllSongs = "All Songs"

// MARK: - AppKit

let dragType = "public.text"

// MARK: - NSUserDefaults

let MX_INITIAL_LAUNCH = "appInitLaunch"
