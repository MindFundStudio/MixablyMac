//
//  MXPlaylistViewController.swift
//  MixablyMac
//
//  Created by Leo Tumwattana on 8/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Cocoa
import RealmSwift

class MXPlaylistViewController: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet var arrayController: NSArrayController!
    
    let realm = try! Realm()
    var songs: [Song] = (try! Realm()).objects(Song).map { (song) in return song }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "toggleMixably:", name: MXNotifications.ToggleMixably.rawValue, object: nil)
    }
    
    override func viewWillAppear() {
        // FIXME - Tentative
        let song = Song()
        song.name = "Harry Ng"
        song.rhythm = 200.0
        try! realm.write {
            self.realm.add(song)
        }
        arrayController.addObject(song)
    }
    
    func toggleMixably(notification: NSNotification?) {
        let vc = MXMixablyViewController.loadFromNib()
        presentViewControllerAsSheet(vc)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
