//
//  MXPopoverViewController.swift
//  MixablyMac
//
//  Created by Harry Ng on 28/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Cocoa
import RealmSwift
import ARAnalytics

class MXPopoverViewController: NSViewController {

    let popover = NSPopover()
    let realm = try! Realm()
    @IBOutlet weak var textField: NSTextField!
    
    class func loadFromNib() -> MXPopoverViewController {
        let storyboard = NSStoryboard(name: "Songs", bundle: nil)
        let vc = storyboard.instantiateControllerWithIdentifier("Popover") as! MXPopoverViewController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        textField.action = "returnOnNameField:"
    }
    
    func showPopover(view: NSView) {
        popover.contentViewController = self
        popover.behavior = .Transient
        popover.showRelativeToRect(view.bounds, ofView: view, preferredEdge: .MaxX)
    }
    
    func returnOnNameField(sender: NSTextField) {
        guard sender.stringValue != "" else { return }
        
        if let _ = popover.delegate as? MXSidebarMoodlistViewController {
            let mood = Mood()
            mood.name = sender.stringValue
            try! realm.write {
                realm.add(mood)
            }
        } else if let _ = popover.delegate as? MXSidebarPlaylistViewController {
            let playlist = Playlist()
            playlist.name = sender.stringValue
            try! realm.write {
                realm.add(playlist)
            }
            MXAnalyticsManager.createPlaylist(playlist.name)
        }

        popover.close()
    }
}
