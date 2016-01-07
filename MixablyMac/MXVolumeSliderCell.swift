//
//  MXVolumeSliderCell.swift
//  MixablyMac
//
//  Created by Leo Tumwattana on 7/1/2016.
//  Copyright © 2016 MiQ. All rights reserved.
//

import Cocoa

final class MXVolumeSliderCell: NSSliderCell {
    
    override func drawBarInside(aRect: NSRect, flipped: Bool) {
        
        let height:CGFloat = 3
        let rect = aRect.insetBy(dx: 0, dy: (aRect.height - height) / 2)
        
        // Final active part Width
        let knobRect = knobRectFlipped(false)
        let finalWidth = knobRect.origin.x + (knobRect.width - 2) / 2
        
        // Draw BG Part
        let bg = NSBezierPath(roundedRect: rect, xRadius: height / 2, yRadius: height / 2)
        NSColor(white: 0.1, alpha: 0.7).setFill()
        bg.fill()
        
        // Draw active Part
        var activeRect = rect
        activeRect.size.width = finalWidth
        activeRect.origin.x = 0
        
        let active = NSBezierPath(roundedRect: activeRect, xRadius: height / 2, yRadius: height / 2)
        MXColor.Blue.setFill()
        active.fill()
    }
    
    override func drawKnob(knobRect: NSRect) {
        let diameter:CGFloat = 9
        let inset = (knobRect.width - diameter) / 2
        let rect = knobRect.insetBy(dx: inset, dy: inset)
        let knob = NSBezierPath(roundedRect: rect, xRadius: diameter / 2, yRadius: diameter / 2)
        NSColor.whiteColor().setFill()
        knob.fill()
    }

}
