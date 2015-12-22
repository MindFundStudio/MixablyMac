//
//  MXMainViewController.swift
//  MixablyMac
//
//  Created by Leo Tumwattana on 8/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Cocoa

final class MXMainViewController: NSViewController {
    
    class func loadFromNib() -> MXMainViewController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateControllerWithIdentifier("MXMainViewController") as! MXMainViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
