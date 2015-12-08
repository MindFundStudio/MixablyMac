//
//  MXMixablyViewController.swift
//  MixablyMac
//
//  Created by Leo Tumwattana on 8/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Cocoa

class MXMixablyViewController: NSViewController {
    
    class func loadFromNib() -> MXMixablyViewController {
        let storyboard = NSStoryboard(name: "Mixably", bundle: nil)
        return storyboard.instantiateControllerWithIdentifier("MXMixablyViewController") as! MXMixablyViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
