//
//  MXMixablySongsViewController.swift
//  MixablyMac
//
//  Created by Harry Ng on 12/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Cocoa
import RealmSwift

final class MXMixablySongsViewController: NSViewController {
    
    let realm = try! Realm()
    var results: Results<Song>! {
        didSet {
            songs = results.map { (song) in return song }
        }
    }
    dynamic var songs: [Song]!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        results = realm.objects(Song)
        
        highlightSongs()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "saveNewPlaylist:", name: MXNotifications.SaveNewPlaylist.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addToPlaylist:", name: MXNotifications.AddToPlaylist.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "selectPlaylist:", name: MXNotifications.SelectPlaylist.rawValue, object: nil)
    }
    
    // MARK: - Helpers
    
    func newSelectedSongs() -> [Song] {
        let checkedSongs = songs.filter { (song) in return song.selected && !song.highlighted }
        print(checkedSongs.count)
        return checkedSongs
    }
    
    func allSelectedSongs() -> [Song] {
        let checkedSongs = songs.filter { (song) in return song.selected }
        return checkedSongs
    }
    
    func newPlaylistName() -> String {
        let defaultLists = realm.objects(Playlist).filter("name BEGINSWITH %@", NewPlaylistName).sorted("name")
        if defaultLists.count > 0 {
            let validLists = defaultLists.map { list in
                return list.name.stringByReplacingOccurrencesOfString(NewPlaylistName + " ", withString: "")
                }.map { name in
                    return Int(name)
                }.filter { number in
                    return number != nil
            }
            
            if validLists.count > 0 {
                return NewPlaylistName + " \(validLists.last!! + 1)"
            } else {
                return NewPlaylistName + " 2"
            }
        } else {
            return NewPlaylistName
        }
    }
    
    func highlightSongs(playlist: Playlist? = MXPlayerManager.sharedManager.selectedPlaylist) {
        guard playlist != nil else { return }
        
        let player = MXPlayerManager.sharedManager
        
        if playlist!.name != AllSongs {
            let selectedPlaylistSongs = player.songs
            
            songs = songs.map { song in
                if selectedPlaylistSongs.filter({(x) in return x == song}).count > 0 {
                    song.highlighted = true
                    song.selected = true
                } else {
                    song.highlighted = false
                    song.selected = false
                }
                return song
            }
        } else {
            songs = songs.map { (song) in
                song.highlighted = false
                song.selected = false
                return song
            }
        }
    }
    
    // MARK: - Notifications
    
    func saveNewPlaylist(notification: NSNotification?) {
        let checkedSongs = allSelectedSongs()
        
        let realm = try! Realm()
        let newPlaylist = Playlist()
        newPlaylist.name = newPlaylistName()
        newPlaylist.songs.appendContentsOf(checkedSongs)
        
        try! realm.write {
            realm.add(newPlaylist)
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(MXNotifications.ReloadSidebarPlaylist.rawValue, object: self, userInfo: [MXNotificationUserInfo.Playlist.rawValue: newPlaylist])
    }
    
    func addToPlaylist(notification: NSNotification?) {
        guard let playlist = notification?.userInfo?[MXNotificationUserInfo.Playlist.rawValue] as? Playlist else { return }
        
        let checkedSongs = newSelectedSongs()
        
        try! realm.write {
            playlist.songs.appendContentsOf(checkedSongs)
        }
    }
    
    func selectPlaylist(notification: NSNotification?) {
        // Update colouring
        guard let playlist = notification?.userInfo?[MXNotificationUserInfo.Playlist.rawValue] as? Playlist else { return }
        
        print("Highlighting \(playlist.songs.count)")
        
        highlightSongs(playlist)
    }
    
}
