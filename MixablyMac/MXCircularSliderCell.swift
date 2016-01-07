//
//  MXCircularSliderCell.swift
//  MixablyMac
//
//  Created by Leo Tumwattana on 6/1/2016.
//  Copyright © 2016 MiQ. All rights reserved.
//

import Cocoa

final class MXCircularSliderCell: NSSliderCell {
    
    let knobImage = NSImage(named: "CircularKnob")!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        numberOfTickMarks = 7
    }
    
    override func drawTickMarks() {
        super.drawTickMarks()
    }
    
    override func drawInteriorWithFrame(cellFrame: NSRect, inView controlView: NSView) {
        
        let value = (doubleValue - minValue) / (maxValue - minValue)
        print("value: \(value) doubleValue: \(doubleValue) minValue: \(minValue) maxValue: \(maxValue)")
        let angle = CGFloat(180).degreesToRadians() * CGFloat(value)
        let anchorPoint = NSMakePoint(NSMidX(cellFrame), NSMidY(cellFrame))
        let knobPointerRect = NSMakeRect(0, NSMidY(cellFrame) - 2.5, cellFrame.width / 2, 5)
        let knobPointer = NSBezierPath(roundedRect: knobPointerRect, xRadius: 2.5, yRadius: 2.5)
            .rotatePath(angle, aboutPoint: anchorPoint)
        
        NSColor.whiteColor().setFill()
        knobPointer.fill()
        
        let knobBodyRect = cellFrame.insetBy(dx: 7, dy: 7)
        drawKnobBody(inRect: knobBodyRect)
    }
    
    override func drawWithFrame(cellFrame: NSRect, inView controlView: NSView) {
        drawInteriorWithFrame(cellFrame, inView: controlView)
    }
    
    // ===============
    // MARK: - Helpers
    // ===============
    
    private func drawKnobBody(inRect rect: NSRect) {
        let light = NSColor(calibratedRed: 72/255, green: 82/255, blue: 97/255, alpha: 1)
        let dark = NSColor(calibratedRed: 55/255, green: 62/255, blue: 72/255, alpha: 1)
        let radialGradient = NSGradient(startingColor: light, endingColor: dark)
        let centerPoint = NSMakePoint(NSMidX(rect), NSMidY(rect))
        
        let circle = NSBezierPath(ovalInRect: rect)
        radialGradient?.drawFromCenter(centerPoint,
            radius: 0,
            toCenter: centerPoint,
            radius: rect.width / 2,
            options: 0)
        
        NSColor.whiteColor().setStroke()
        circle.lineWidth = 3
        circle.stroke()
    }
    
    
}
