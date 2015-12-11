//
//  MXPlaylistViewController.swift
//  MixablyMac
//
//  Created by Leo Tumwattana on 8/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Cocoa
import RealmSwift
import iTunesLibrary
import AVFoundation

final class MXPlaylistViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, MXMixablyPresentationController {
    
    // ==================
    // MARK: - Properties
    // ==================
    
    let realm = try! Realm()
    
    var library: ITLibrary? = nil
    var audioPlayer: AVAudioPlayer?
    
    var viewToShrink:NSView {
        return tableView
    }
    
    dynamic var mediaItems: [ITLibMediaItem] = []
    dynamic var songs: [Song] = (try! Realm()).objects(Song).map { (song) in return song }
    
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "toggleMixably:", name: MXNotifications.ToggleMixably.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeSong:", name: MXNotifications.ChangeSong.rawValue, object: nil)
        
        do {
            library = try ITLibrary(APIVersion: "1.0")
            let allItems = library!.allMediaItems as! [ITLibMediaItem]
            songs = allItems.filter({ (item) -> Bool in
                return item.mediaKind == UInt(ITLibMediaItemMediaKindSong) && item.locationType == UInt(ITLibMediaItemLocationTypeFile)
            }).map({ (item) -> Song in
                return Song(item: item)
            })
            MXPlayerManager.sharedManager.playList = songs
        } catch let error as NSError {
            print("error loading iTunesLibrary")
            NSAlert(error: error).runModal()
        }
        
        tableView.doubleAction = Selector("doubleClick:")
        
    }
    
    func toggleMixably(notification: NSNotification?) {
        if let vc = mixablyViewController {
            print("Dismiss")
            dismissViewController(vc)
            mixablyViewController = nil
        } else {
            print("Present")
            mixablyViewController = MXMixablyViewController.loadFromNib()
            presentViewController(mixablyViewController!, animator: MXMixablyPresentationAnimator())
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
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Double Action
    
    func doubleClick(sender: NSTableView) {
        let manager = MXPlayerManager.sharedManager
        manager.currentSong = songs[tableView.selectedRow]
        manager.play()
    }
}
