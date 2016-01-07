//
//  MXSlider.swift
//  MixablyMac
//
//  Created by Leo Tumwattana on 7/1/2016.
//  Copyright © 2016 MiQ. All rights reserved.
//

import Cocoa

final class MXSlider: NSSlider {
    
    override func setNeedsDisplayInRect(invalidRect: NSRect) {
        super.setNeedsDisplayInRect(bounds)
    }
    
}
