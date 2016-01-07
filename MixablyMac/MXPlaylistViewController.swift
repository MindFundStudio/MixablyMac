//
//  MXPlaylistViewController.swift
//  MixablyMac
//
//  Created by Leo Tumwattana on 8/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Cocoa
import RealmSwift
import ReactKit

final class MXPlaylistViewController: NSViewController, NSTableViewDataSource, MXMixablyPresentationController {
    
    // ==================
    // MARK: - Properties
    // ==================
    
    let realm = try! Realm()
    
    var viewToShrink:NSView {
        return tableView
    }
    
    var playlist: Playlist!
    dynamic var songs: [Song]!
    weak var playingSong: Song? {
        didSet {
            playingSong?.playing = true
        }
    }
    
    private var mixablyViewController:MXMixablyViewController?
    
    // ================
    // MARK: - Subviews
    // ================
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet var arrayController: NSArrayController!
    
    // =================
    // MARK: - Lifecycle
    // =================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        loadAllSongs()
        
        // Register tableView Actions
        
        tableView.doubleAction = Selector("doubleClick:")
        
        // Register Notifications
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "toggleMixably:", name: MXNotifications.ToggleMixably.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "selectPlaylist:", name: MXNotifications.ReloadSongs.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showMixably:", name: MXNotifications.SelectMood.rawValue, object: nil)
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
            if index >= 2 {
                column.headerCell.alignment = .Center
            }
        }
    }
    
    // MARK: - Song List Helpers
    
    func loadAllSongs() {
        // Assume All Songs playlist is selected by default
        songs = realm.objects(Song).map {$0}
    }
    
    // MARK: - Notification Observers
    
    func toggleMixably(notification: NSNotification?) {
        if let vc = mixablyViewController {
            hideMixably(vc, notification)
        } else {
            showMixably(notification)
        }
    }
    
    func showMixably(notification: NSNotification?) {
        print("Present")
        guard mixablyViewController == nil else { return }
        
        mixablyViewController = MXMixablyViewController.loadFromNib()
        if let mood = notification?.userInfo?[MXNotificationUserInfo.Mood.rawValue] as? Mood {
            mixablyViewController?.selectedMood = mood
        }
        tableView.doubleAction = nil
        presentViewController(mixablyViewController!, animator: MXMixablyPresentationAnimator())
    }
    
    func hideMixably(vc: NSViewController, _ notification: NSNotification?) {
        print("Dismiss")
        guard mixablyViewController != nil else { return }
        
        dismissViewController(vc)
        mixablyViewController = nil
        
        tableView.doubleAction = Selector("doubleClick:")
        
        // Reload songs
        if let playlist = MXPlayerManager.sharedManager.selectedPlaylist {
            NSNotificationCenter.defaultCenter().postNotificationName(MXNotifications.SelectPlaylist.rawValue, object: self, userInfo: [MXNotificationUserInfo.Playlist.rawValue: playlist])
        }
    }
    
    func selectPlaylist(notification: NSNotification?) {
        guard let playlist = notification?.userInfo?[MXNotificationUserInfo.Playlist.rawValue] as? Playlist else {
            return
        }
        
        self.playlist = playlist
        
        if playlist.name == AllSongs {
            loadAllSongs()
        } else {
            self.playlist = playlist
            songs = playlist.songs.map {$0}
            
            KVO.detailedStream(playlist, "songs").ownedBy(self) ~> { [unowned self] _, kind, indexes in
                self.songs = playlist.songs.map {$0}
            }
        }
        
        if let currentSong = MXPlayerManager.sharedManager.currentSong where playlist == MXPlayerManager.sharedManager.playingPlaylist {
            selectSong(currentSong)
        }
    }
    
    func selectSong(song: Song) {
        playingSong?.playing = false
        playingSong?.pause = false
        
        let index = songs.indexOf { (s) -> Bool in
            return s.location == song.location
        }
        
        if let index = index {
            playingSong = songs[index]
            tableView.selectRowIndexes(NSIndexSet(index: index), byExtendingSelection: false)
            tableView.scrollRowToVisible(index)
        }
    }
    
    func changeSong(notification: NSNotification?) {
        guard let song = notification?.userInfo?[MXNotificationUserInfo.Song.rawValue] as? Song else {
            // no current song. Deselect row
            tableView.deselectAll(nil)
            return
        }
        
        guard playlist == MXPlayerManager.sharedManager.playingPlaylist else {
            return
        }
        
        // select song
        selectSong(song)
    }
    
    func startPlaying(notification: NSNotification) {
        playingSong?.playing = true
        playingSong?.pause = false
    }
    
    func pausePlaying(notification: NSNotification) {
        playingSong?.playing = false
        playingSong?.pause = true
    }
    
    // MARK: - Double Action
    
    func doubleClick(sender: NSTableView) {
        let manager = MXPlayerManager.sharedManager
        if tableView.selectedRow != -1 {
            manager.playingPlaylist = playlist
            manager.currentSong = songs[tableView.selectedRow]
        }
        manager.play()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}

extension MXPlaylistViewController: NSTableViewDelegate {
    
    func tableView(tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return MXTableRowView()
    }
    
}
