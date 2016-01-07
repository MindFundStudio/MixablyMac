//
//  MXTableHeaderView.swift
//  MixablyMac
//
//  Created by Harry Ng on 7/1/2016.
//  Copyright © 2016 MiQ. All rights reserved.
//

import Cocoa

class MXTableHeaderView: NSTableHeaderView {

    override var allowsVibrancy: Bool {
        return false
    }
    
    override func awakeFromNib() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.blackColor().CGColor
    }
    
}
