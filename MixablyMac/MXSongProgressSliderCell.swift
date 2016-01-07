//
//  MXSongProgressSliderCell.swift
//  MixablyMac
//
//  Created by Leo Tumwattana on 7/1/2016.
//  Copyright © 2016 MiQ. All rights reserved.
//

import Cocoa

final class MXSongProgressSliderCell: NSSliderCell {
    
    override func drawBarInside(aRect: NSRect, flipped: Bool) {
        
        let height:CGFloat = 3
        let rect = aRect.insetBy(dx: 0, dy: (aRect.height - height) / 2)
        
        // Final active part Width
        let knobRect = knobRectFlipped(false)
        let finalWidth = knobRect.origin.x + (knobRect.width - 2) / 2
        
        // Draw BG Part
        let bg = NSBezierPath(rect: rect)
        NSColor(white: 0.1, alpha: 0.7).setFill()
        bg.fill()
        
        // Draw active Part
        var activeRect = rect
        activeRect.size.width = finalWidth
        activeRect.origin.x = 0
        
        let active = NSBezierPath(rect: activeRect)
        NSColor(calibratedRed: 19/255, green: 160/255, blue: 216/255, alpha: 1).setFill()
        active.fill()
    }
    
    override func drawKnob(knobRect: NSRect) {
        let radius:CGFloat = 3
        let rect = knobRect.insetBy(dx: (knobRect.width - 2) / 2, dy: 0)
        let knob = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
        NSColor.whiteColor().setFill()
        knob.fill()
    }
    
}
