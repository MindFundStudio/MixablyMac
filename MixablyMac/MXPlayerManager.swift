//
//  MXPlayer.swift
//  MixablyMac
//
//  Created by Joseph Cheung on 9/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Foundation
import AVFoundation
import RealmSwift

class MXPlayerManager: NSObject, AVAudioPlayerDelegate {
    static let sharedManager = MXPlayerManager()
    
    let realm = try! Realm()
    
    var selectedPlaylist: Playlist?
    var selectedMood: Mood?
    
    var isRepeat = false
    var isShuffle = false {
        didSet {
            if isShuffle {
                if let currentSong = currentSong {
                    let list = playList.filter({ (song) -> Bool in
                        return song.location != currentSong.location
                    })
                    shuffledPlayList = [currentSong] + list.shuffle()
                } else {
                    shuffledPlayList = playList.shuffle()
                }
                currentPlayList = shuffledPlayList
            } else {
                currentPlayList = playList
            }
        }
    }
    var currentSong: Song? = nil {
        didSet {
            if let currentSong = currentSong {
                currentIndex = currentPlayList.indexOf({ (song) -> Bool in
                    return song.location == currentSong.location
                })
                if currentSong.location != player?.url?.absoluteString {
                    player = try? AVAudioPlayer(contentsOfURL: NSURL(string: currentSong.location)!)
                    player?.delegate = self
                    player?.volume = volume
                }
                NSNotificationCenter.defaultCenter().postNotificationName(MXNotifications.ChangeSong.rawValue, object: self, userInfo: [MXNotificationUserInfo.Song.rawValue: currentSong])
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName(MXNotifications.ChangeSong.rawValue, object: self, userInfo: nil)
            }
            
        }
    }
    
    var volume: Float = 0.5 {
        didSet {
            player?.volume = volume
        }
    }
    
    // Current playing song list
    var songs: [Song] {
        get {
            return currentPlayList
        }
    }
    
    var playing: Bool {
        if let player = player {
            return player.playing
        } else {
            return false
        }
    }
    var currentIndex: Int? = nil

    var player: AVAudioPlayer?
    private var monitor: AnyObject?
    // Storage of playlist
    private var playList: [Song] = [] {
        didSet {
            if !isShuffle {
                currentPlayList = playList
            }
        }
    }
    private var shuffledPlayList: [Song] = []
    private var currentPlayList: [Song] = []
    private var history: [Song]? = []
    private var lastSong: Song?
    
    private override init() {
        super.init()
        monitor = NSEvent.addLocalMonitorForEventsMatchingMask(.KeyDownMask, handler: { [unowned self] (event) -> NSEvent? in
            if event.keyCode == 49 {
                self.togglePlayState()
            }
            return event
        })
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "selectPlaylist:", name: MXNotifications.SelectPlaylist.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "selectMood:", name: MXNotifications.SelectMood.rawValue, object: nil)
    }
    
    deinit {
        if let player = player {
            player.stop()
        }
        if monitor != nil {
            NSEvent.removeMonitor(monitor!)
            monitor = nil
        }
        player = nil
    }
    
    // MARK: - Player Control
    
    func play() {
        if currentSong == nil {
            currentSong = currentPlayList[0]
        }
        
        player?.play()
        NSNotificationCenter.defaultCenter().postNotificationName(MXNotifications.StartPlaying.rawValue, object: self)
    }
    
    func next() {
        guard let currentIndex = currentIndex else {
            return
        }
        
        if !isRepeat && currentIndex == currentPlayList.count - 1 {
            currentSong = nil
            stop()
            player = nil
            return
        }
        
        if isRepeat && currentIndex == currentPlayList.count - 1 {
            currentSong = currentPlayList.first
        } else {
            currentSong = currentPlayList[currentIndex + 1]
        }
        
        play()
    }
    
    func back() {
        guard let currentIndex = currentIndex else {
            return
        }
        
        if player?.currentTime > 3.0 {
            // go back to beginning
            player?.currentTime = 0.0
            play()
        } else {
            // go to previous song
            if !isRepeat && currentIndex == 0 {
                currentSong = nil
                stop()
                player = nil
                return
            }
            
            if isRepeat && currentIndex == 0 {
                currentSong = currentPlayList.last
            } else {
                currentSong = currentPlayList[currentIndex - 1]
            }
            
            play()
        }
        
        
    }
    
    func pause() {
        player?.pause()
        NSNotificationCenter.defaultCenter().postNotificationName(MXNotifications.PausePlaying.rawValue, object: self)
    }
    
    func stop() {
        player?.stop()
        NSNotificationCenter.defaultCenter().postNotificationName(MXNotifications.StopPlaying.rawValue, object: self)
    }
    
    private func togglePlayState() {
        if playing {
            pause()
        } else {
            play()
        }
    }
    
    // MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        next()
    }
    
    // MARK: - Notifications
    
    func selectPlaylist(notification: NSNotification?) {
        guard let playlist = notification?.userInfo?[MXNotificationUserInfo.Playlist.rawValue] as? Playlist else {
            return
        }
        
        selectedPlaylist = playlist
        
        if playlist.name == AllSongs {
            loadAllSongs()
        } else {
            loadSongsOfPlaylist(playlist)
        }
    }
    
    func selectMood(notification: NSNotification?) {
        guard let mood = notification?.userInfo?[MXNotificationUserInfo.Mood.rawValue] as? Mood else {
            return
        }
        
        selectedMood = mood
    }
    
    // MARK: - Song List Helpers
    
    func loadAllSongs() {
        playList = realm.objects(Song).map { (song) in return song }
    }
    
    func loadSongsOfPlaylist(playlist: Playlist) {
        playList = playlist.songs.map { (song) in return song }
    }

}