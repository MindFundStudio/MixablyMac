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

final class MXMixablySongsViewController: NSViewController {
    
    let realm = try! Realm()
    let queue = OperationQueue()
    
    @IBOutlet weak var tableView: NSTableView!
    
    dynamic var scoredSongs: [ScoredSong]! {
        didSet {
            let ids = scoredSongs.map {$0.id}
            let result = realm.objects(Song).filter("id IN %@", ids).sort { (a, b) -> Bool in
                return ids.indexOf(a.id)! < ids.indexOf(b.id)!
            }
            MXPlayerManager.sharedManager.filterList.songs.removeAll()
            MXPlayerManager.sharedManager.filterList.songs.appendContentsOf(result)
        }
    }
    
    weak var playingSong: ScoredSong?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        tableView.doubleAction = Selector("doubleClick:")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "saveNewPlaylist:", name: MXNotifications.SaveNewPlaylist.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addToPlaylist:", name: MXNotifications.AddToPlaylist.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "selectPlaylist:", name: MXNotifications.SelectPlaylist.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadMixably:", name: MXNotifications.ReloadMixably.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeSong:", name: MXNotifications.ChangeSong.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "startPlaying:", name: MXNotifications.StartPlaying.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "pausePlaying:", name: MXNotifications.PausePlaying.rawValue, object: nil)
    }
    
    override func viewDidLayout() {
        for (index, column) in tableView.tableColumns.enumerate() {
            column.headerCell = MXCustomHeaderCell(textCell: column.headerCell.stringValue)
            if index < 1 {
                (column.headerCell as? MXCustomHeaderCell)?.showSlice = false
            }
            if index == 2 {
                column.headerCell.alignment = .Center
            }
            if column.identifier == "selectSong" {
                column.headerCell.image = NSImage(named: "checkSelect")
            }
        }
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
                    if let song = MXPlayerManager.sharedManager.currentSong {
                        let scoredSong = ScoredSong(id: song.id, persistentID: song.persistentID, name: song.name, location: song.location, score: 0)
                        wself.selectSong(scoredSong)
                    }
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
            scoredSongs = scoredSongs.map { song in
                if player.selectedPlaylist?.songs.filter({(x) in return x.location == song.location}).count > 0 {
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
    
    func selectSong(song: ScoredSong) {
        playingSong?.playing = false
        playingSong?.pause = false
        
        // TODO: Implements Player
        let index = scoredSongs.indexOf { (s) -> Bool in
            return s.persistentID == song.persistentID
        }
        
        if let index = index where MXPlayerManager.sharedManager.isPlayingFilterList {
            playingSong = scoredSongs[index]
            playingSong?.playing = MXPlayerManager.sharedManager.playing
            playingSong?.pause = !MXPlayerManager.sharedManager.playing
        }
    }
    
    // MARK: - DataSource
    
    func tableView(tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let pbItem = NSPasteboardItem()
        pbItem.setString(String(scoredSongs[row].location), forType: NSPasteboardTypeString)
        pbItem.setString("MXMixably", forType: NSPasteboardTypeRTF)
        
        return pbItem
    }
    
    // MARK: - Action
    
    func doubleClick(sender: NSTableView) {
        let manager = MXPlayerManager.sharedManager
        if tableView.selectedRow != -1 {
            manager.playFilterList = true
            manager.currentSong = manager.filterList.songs[tableView.selectedRow]
        }
        manager.play()
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
    
    func changeSong(notification: NSNotification) {
        guard let song = notification.userInfo?[MXNotificationUserInfo.Song.rawValue] as? Song else { return }
        
        let scoredSong = ScoredSong(id: song.id, persistentID: song.persistentID, name: song.name, location: song.location, score: 0)
        selectSong(scoredSong)
    }
    
    func startPlaying(notification: NSNotification) {
        playingSong?.playing = true
        playingSong?.pause = false
    }
    
    func pausePlaying(notification: NSNotification) {
        playingSong?.playing = false
        playingSong?.pause = true
    }
    
}

extension MXMixablySongsViewController: NSTableViewDelegate {
    
    func tableView(tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return MXTableRowView()
    }
    
}

extension MXMixablySongsViewController: NSTableViewDataSource {
    
    func tableView(tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        let mutableSongs = NSMutableArray(array: scoredSongs)
        mutableSongs.sortUsingDescriptors(tableView.sortDescriptors)
        scoredSongs = mutableSongs as AnyObject as? [ScoredSong]
        tableView.reloadData()
    }
    
}
