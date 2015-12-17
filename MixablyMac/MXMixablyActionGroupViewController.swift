//
//  MXMixablyActionGroupViewController.swift
//  MixablyMac
//
//  Created by Harry Ng on 14/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Cocoa

class MXMixablyActionGroupViewController: NSViewController {

    @IBOutlet weak var saveNewButton: NSButton!
    @IBOutlet weak var addToButton: NSButton!
    
    var playlist: Playlist?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        updateAddToButton()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "selectPlaylist:", name: MXNotifications.SelectPlaylist.rawValue, object: nil)
    }
    
    @IBAction func saveNewPlaylist(sender: NSButton) {
        NSNotificationCenter.defaultCenter().postNotificationName(MXNotifications.SaveNewPlaylist.rawValue, object: self)
    }
    
    @IBAction func addToPlaylist(sender: NSButton) {
        if let playlist = MXPlayerManager.sharedManager.selectedPlaylist {
            NSNotificationCenter.defaultCenter().postNotificationName(MXNotifications.AddToPlaylist.rawValue, object: self, userInfo: [MXNotificationUserInfo.Playlist.rawValue: playlist])
        }
    }
    
    // MARK: - Helpers
    
    func updateAddToButton() {
        if let playlist = MXPlayerManager.sharedManager.selectedPlaylist {
            if playlist.name != AllSongs {
                addToButton.title = "Add to " + playlist.name
                addToButton.enabled = true
            } else {
                addToButton.title = "Add to Playlist"
                addToButton.enabled = false
            }
        }
    }
    
    // MARK: - Notifications
    
    func selectPlaylist(notification: NSNotification?) {
        updateAddToButton()
    }
}
