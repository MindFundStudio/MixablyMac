//
//  MXMixablySongsViewController.swift
//  MixablyMac
//
//  Created by Harry Ng on 12/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Cocoa
import RealmSwift
import PSOperations

final class MXMixablySongsViewController: NSViewController, NSTableViewDataSource {
    
    let realm = try! Realm()
    let queue = OperationQueue()
    
    dynamic var scoredSongs: [ScoredSong]!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "saveNewPlaylist:", name: MXNotifications.SaveNewPlaylist.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addToPlaylist:", name: MXNotifications.AddToPlaylist.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "selectPlaylist:", name: MXNotifications.SelectPlaylist.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadMixably:", name: MXNotifications.ReloadMixably.rawValue, object: nil)
    }
    
    // MARK: - Helpers
    
    func loadSongsOf(mood: Mood?) {
        if let mood = mood {
            filterSongsBy(mood)
        }
    }
    
    func filterSongsBy(mood: Mood) {
        let inputs = MXScoringInputs(
            bassPredict: mood.bassPredict,
            bassCoeff: mood.bassCoeff,
            rhythmStrengthPredict: mood.rhythmStrengthPredict,
            rhythmStrengthCoeff: mood.rhythmStrengthCoeff,
            tempoPredict: mood.tempoPredict,
            tempoCoeff: mood.tempoCoeff,
            combinedEnergyIntensityPredict: mood.combinedEnergyIntensityPredict,
            combinedEnergyIntensityCoeff: mood.combinedEnergyIntensityCoeff
        )
        
        let operation = MXScoreSongsOperation(inputs: inputs) { [weak self] (var scoredSongs, error) -> Void in
            if let error = error {
                print(error.description)
            } else if let wself = self {
//                scoredSongs = scoredSongs.filter { song in song.score > -100 && song.score < 100 }
                scoredSongs = scoredSongs.sort { $0.score < $1.score }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    wself.scoredSongs = scoredSongs
                    wself.highlightSongs()
                })
            }
        }
        queue.addOperation(operation)
    }
    
    func newSelectedSongs() -> Results<Song> {
        let checkedSongs = scoredSongs.filter { (song) in return song.selected && !song.highlighted }
        print(checkedSongs.count)
        
        let ids = checkedSongs.map { song in return song.id }
        return realm.objects(Song).filter("id IN %@", ids)
    }
    
    func allSelectedSongs() -> Results<Song> {
        let checkedSongs = scoredSongs.filter { (song) in return song.selected }
        
        let ids = checkedSongs.map { song in return song.id }
        return realm.objects(Song).filter("id IN %@", ids)
    }
    
    func newPlaylistName() -> String {
        let defaultLists = realm.objects(Playlist).filter("name BEGINSWITH %@", NewPlaylistName)
        if defaultLists.count > 0 {
            let validLists = defaultLists.map { list in
                return list.name.stringByReplacingOccurrencesOfString(NewPlaylistName + " ", withString: "")
                }.map { name in
                    return Int(name)
                }.filter { number in
                    return number != nil
            }
            
            let _ = validLists.sort { return $0 < $1 }
            
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
        guard scoredSongs != nil else { return }
        
        let player = MXPlayerManager.sharedManager
        
        if playlist!.name != AllSongs {
            let selectedPlaylistSongs = player.songs
            
            scoredSongs = scoredSongs.map { song in
                if selectedPlaylistSongs.filter({(x) in return x.location == song.location}).count > 0 {
                    song.highlighted = true
                    song.selected = true
                } else {
                    song.highlighted = false
                    song.selected = false
                }
                return song
            }
        } else {
            scoredSongs = scoredSongs.map { (song) in
                song.highlighted = false
                song.selected = false
                return song
            }
        }
    }
    
    // MARK: - DataSource
    
    func tableView(tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let pbItem = NSPasteboardItem()
        pbItem.setString(scoredSongs[row].name, forType: NSPasteboardTypeString)
        pbItem.setString("MXMixably", forType: NSPasteboardTypeRTF)
        
        return pbItem
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
        MXAnalyticsManager.createPlaylist(newPlaylist.name)
        
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
    
    func reloadMixably(notification: NSNotification?) {
        if let mood = notification?.userInfo?[MXNotificationUserInfo.Mood.rawValue] as? Mood {
            filterSongsBy(mood)
        } else {
            if let mood = MXPlayerManager.sharedManager.selectedMood {
                filterSongsBy(mood)
            }
        }
    }
    
}
