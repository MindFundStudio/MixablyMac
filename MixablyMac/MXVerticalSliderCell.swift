//
//  MXVerticalSliderCell.swift
//  MixablyMac
//
//  Created by Leo Tumwattana on 5/1/2016.
//  Copyright © 2016 MiQ. All rights reserved.
//

import Cocoa

final class MXVerticalSliderCell: NSSliderCell {

    override func drawBarInside(var aRect: NSRect, flipped: Bool) {
        
        aRect.size.width = 5
        
        // Bar radius
        let radius:CGFloat = 2.5
        
        //// Knob position depending on control min/max value and current control value.
        let value = (doubleValue - minValue) / (maxValue - minValue)
        
        //// Final Left Part Width
        let finalHeight = CGFloat(value) * (controlView!.frame.size.height - 6)
        
        //// Active Part Rect
        var activeRect = aRect
        activeRect.size.height = finalHeight
        activeRect.origin.y = controlView!.frame.size.height - 3 - finalHeight
        
        //// Draw BG Part
        let bg = NSBezierPath(roundedRect: aRect, xRadius: radius, yRadius: radius)
        NSColor(calibratedRed: 64/255, green: 76/255, blue: 80/255, alpha: 1).setFill()
        bg.fill()
        
        //// Draw active Part
        let active = NSBezierPath(roundedRect: activeRect, xRadius: radius, yRadius: radius)
        let dark = NSColor(calibratedRed: 71/255, green: 96/255, blue: 112/255, alpha: 1)
        let light = NSColor(calibratedRed: 190/255, green: 219/255, blue: 229/255, alpha: 1)
        let gradient = NSGradient(colors: [light, dark])
        gradient?.drawInBezierPath(active, angle: 90)
    }
    
    override func drawKnob(knobRect: NSRect) {
        let radius:CGFloat = 3
        let rect = knobRect.insetBy(dx: 2, dy: 6)
        let knob = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
        NSColor.whiteColor().setFill()
        knob.fill()
    }
}
