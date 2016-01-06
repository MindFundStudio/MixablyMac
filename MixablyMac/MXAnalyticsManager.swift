//
//  MXAnalyticsManager.swift
//  MixablyMac
//
//  Created by Harry Ng on 31/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

let eventRunningApp = "Running the App"

import Foundation
import ARAnalytics

struct MXAnalyticsManager {
    
    static func setup() {
        ARAnalytics.setupWithAnalytics([
            ARMixpanelToken: "188e8f644e07082347a1299ca88473ae",
            ARParseApplicationID: "QWQCoOYy8hwZkzuqfOmtrgzX5F51XKYVLW6eCSYZ",
            ARParseClientKey: "Yo5xfpQkbpv5kEIzfBfnpHXzGoRJCb3onuguKngf"
        ])
    }
    
    // MARK: - Usage
    
    static func startApp() {
        ARAnalytics.startTimingEvent(eventRunningApp)
        ARAnalytics.event("launch")
    }
    
    static func terminateApp() {
        ARAnalytics.finishTimingEvent(eventRunningApp)
        ARAnalytics.event("terminate")
    }
    
    // MARK: - Playlist
    
    static func createPlaylist(name: String = "") {
        ARAnalytics.event("Playlist", withProperties: [
            "Playlist": "Create",
            "name": name
        ])
    }
    
    static func reloadPlaylist() {
        ARAnalytics.event("Playlist", withProperties: [
            "Playlist": "Reload"
        ])
    }
    
    // MARK: - Mood
    
    static func createMood(name: String = "") {
        ARAnalytics.event("Mood", withProperties: [
            "Mood": "Create",
            "name": name
            ])
    }
    
    static func reloadMoodList() {
        
    }
    
    // MARK: - Song
    
    static func importSongs(count: Int = 0) {
        ARAnalytics.event("Song", withProperties: [
            "count": count
        ])
    }
    
    static func saveSong(statusRaw: Int) {
        switch statusRaw {
        case Song.Status.Unanalysed.rawValue:
            ARAnalytics.event("Song", withProperties: [
            "Save": "Unanalyzed"
            ])
        case Song.Status.Analyzed.rawValue:
            ARAnalytics.event("Song", withProperties: [
            "Save": "Analyzed"
            ])
        default:
            break
        }
    }
}