//
//  MXCircularSliderCell.swift
//  MixablyMac
//
//  Created by Leo Tumwattana on 6/1/2016.
//  Copyright © 2016 MiQ. All rights reserved.
//

import Cocoa

final class MXCircularSliderCell: NSSliderCell {
    
    let knobRadius:CGFloat = 10
    let pointerRadius:CGFloat = 17
    let dotWidth:CGFloat = 5
    let degreesOfRotation:CGFloat = 180
    
    var dotColors:[NSColor]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        numberOfTickMarks = 7
        
        dotColors = [
            NSColor(calibratedRed: 79/255, green: 230/255, blue: 255/255, alpha: 1),
            NSColor(calibratedRed: 79/255, green: 230/255, blue: 255/255, alpha: 1),
            NSColor(calibratedRed: 31/255, green: 167/255, blue: 231/255, alpha: 1),
            NSColor(calibratedRed: 70/255, green: 117/255, blue: 213/255, alpha: 1),
            NSColor(calibratedRed: 133/255, green: 112/255, blue: 201/255, alpha: 1),
            NSColor(calibratedRed: 187/255, green: 69/255, blue: 153/255, alpha: 1),
            NSColor(calibratedRed: 213/255, green: 48/255, blue: 126/255, alpha: 1)
        ]
    }
    
    override func drawInteriorWithFrame(cellFrame: NSRect, inView controlView: NSView) {
        
        drawPointer(inRect: cellFrame)
        
        let inset:CGFloat = (cellFrame.width - knobRadius * 2) / 2
        let knobBodyRect = cellFrame.insetBy(dx: inset, dy: inset)
        drawKnobBody(inRect: knobBodyRect)
    }
    
    override func drawWithFrame(cellFrame: NSRect, inView controlView: NSView) {
        drawInteriorWithFrame(cellFrame, inView: controlView)
        drawTickMarks()
    }
    
    override func drawTickMarks() {
        print("controlView: \(controlView!.frame)")
        
        
        let frame = controlView!.frame
        let baseDotFrame = NSMakeRect(0, frame.height / 2 - dotWidth / 2, dotWidth, dotWidth)
        
        for i in 0..<numberOfTickMarks {
            let degree = degreesOfRotation / CGFloat(numberOfTickMarks - 1) * CGFloat(i)
            let angle = CGFloat(degree).degreesToRadians()
            let dot = NSBezierPath(ovalInRect: baseDotFrame)
                .rotatePath(angle, aboutPoint: NSMakePoint(frame.width / 2, frame.height / 2))
            dotColors[i].setFill()
            dot.fill()
        }
    }
    
    override func rectOfTickMarkAtIndex(index: Int) -> NSRect {
        let rect = controlView!.frame
        return NSMakeRect(0, rect.height / 2 - 2.5, 5, 5)
    }
    
    // ===============
    // MARK: - Helpers
    // ===============
    
    private func drawPointer(inRect rect: NSRect) {
        
        let value = (doubleValue - minValue) / (maxValue - minValue)
        let angle = degreesOfRotation.degreesToRadians() * CGFloat(value)
        let anchorPoint = NSMakePoint(NSMidX(rect), NSMidY(rect))
        
        let x = (rect.width / 2) - pointerRadius
        let knobPointerRect = NSMakeRect(x, NSMidY(rect) - 2.5, rect.width / 2, 5)
        let knobPointer = NSBezierPath(roundedRect: knobPointerRect, xRadius: 2.5, yRadius: 2.5)
            .rotatePath(angle, aboutPoint: anchorPoint)
        
        NSColor.whiteColor().setFill()
        knobPointer.fill()
 
    }
    
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
