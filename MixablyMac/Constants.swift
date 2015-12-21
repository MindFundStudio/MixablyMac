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
    // Player Control
    case StartPlaying = "startPlaying"
    case PausePlaying = "pausePlaying"
    case StopPlaying = "stopPlaying"
    case ChangeSong = "changeSong"
    // Playlist
    case SelectPlaylist = "selectPlaylist"
    case ReloadSidebarPlaylist = "reloadSidebarPlaylist"
    case ReloadSongs = "reloadSongs"
    // Mixably
    case ToggleMixably = "toggleMixably"
    case SelectMood = "selectMood"
    case AddToPlaylist = "addToPlaylist"
    case SaveNewPlaylist = "saveNewPlaylist"
    case ReloadMixably = "reloadMixably"
    case ReloadSidebarMood = "reloadSidebarMood"
}

enum MXNotificationUserInfo: String {
    case Song = "song"
    case Playlist = "playlist"
    case Mood = "mood"
}

// MARK: - Display

let AllSongs = "All Songs"
let NewPlaylistName = "New Playlist"

// MARK: - NSUserDefaults

let MX_INITIAL_LAUNCH = "appInitLaunch"
