//
//  NSPlayerBackgroundView.swift
//  MixablyMac
//
//  Created by Leo Tumwattana on 7/1/2016.
//  Copyright © 2016 MiQ. All rights reserved.
//

import Cocoa

final class NSPlayerBackgroundView: NSView {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        wantsLayer = true
        layer?.backgroundColor = NSColor(calibratedRed: 54/255, green: 61/255, blue: 71/255, alpha: 1).CGColor
    }
    
}
