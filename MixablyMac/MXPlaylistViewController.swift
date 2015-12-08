//
//  MXPlaylistViewController.swift
//  MixablyMac
//
//  Created by Leo Tumwattana on 8/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Cocoa

class MXPlaylistViewController: NSViewController {
    
    var songs: [Song] = [Song(), Song()]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "toggleMixably:", name: MXNotifications.ToggleMixably.rawValue, object: nil)
    }
    
    func toggleMixably(notification: NSNotification?) {
        let vc = MXMixablyViewController.loadFromNib()
        presentViewControllerAsSheet(vc)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
