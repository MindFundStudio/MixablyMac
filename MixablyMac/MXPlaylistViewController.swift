//
//  MXPlaylistViewController.swift
//  MixablyMac
//
//  Created by Leo Tumwattana on 8/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Cocoa
import RealmSwift

final class MXPlaylistViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, MXMixablyPresentationController {
    
    // ==================
    // MARK: - Properties
    // ==================
    
    let realm = try! Realm()
    
    var viewToShrink:NSView {
        return tableView
    }
    
    dynamic var songs: [Song]!
    
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "selectPlaylist:", name: MXNotifications.SelectPlaylist.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showMixably:", name: MXNotifications.SelectMood.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeSong:", name: MXNotifications.ChangeSong.rawValue, object: nil)
    }
    
    // MARK: - Song List Helpers
    
    func loadAllSongs() {
        // Assume All Songs playlist is selected by default
        songs = MXPlayerManager.sharedManager.songs
    }
    
    func loadSongsOfPlaylist(playlist: Playlist) {
        songs = MXPlayerManager.sharedManager.songs
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
        presentViewController(mixablyViewController!, animator: MXMixablyPresentationAnimator())
    }
    
    func hideMixably(vc: NSViewController, _ notification: NSNotification?) {
        print("Dismiss")
        guard mixablyViewController != nil else { return }
        
        dismissViewController(vc)
        mixablyViewController = nil
    }
    
    func selectPlaylist(notification: NSNotification?) {
        guard let playlist = notification?.userInfo?[MXNotificationUserInfo.Playlist.rawValue] as? Playlist else {
            return
        }
        
        if playlist.name == AllSongs {
            loadAllSongs()
        } else {
            loadSongsOfPlaylist(playlist)
        }
    }
    
    func changeSong(notification: NSNotification?) {
        guard let song = notification?.userInfo?[MXNotificationUserInfo.Song.rawValue] as? Song else {
            // no current song. Deselect row
            tableView.deselectAll(nil)
            return
        }
        
        // select song
        let index = songs.indexOf { (s) -> Bool in
            return s.location == song.location
        }
        
        if let index = index {
            tableView.selectRowIndexes(NSIndexSet(index: index), byExtendingSelection: false)
            tableView.scrollRowToVisible(index)
        }
        
    }
    
    // MARK: - Double Action
    
    func doubleClick(sender: NSTableView) {
        let manager = MXPlayerManager.sharedManager
        manager.currentSong = songs[tableView.selectedRow]
        manager.play()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
