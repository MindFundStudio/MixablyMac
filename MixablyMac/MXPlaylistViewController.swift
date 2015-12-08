//
//  MXPlaylistViewController.swift
//  MixablyMac
//
//  Created by Leo Tumwattana on 8/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Cocoa

class MXPlaylistViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func toogleMixably(sender: NSButton) {
        let vc = MXMixablyViewController.loadFromNib()
        presentViewControllerAsSheet(vc)
    }
    
}
