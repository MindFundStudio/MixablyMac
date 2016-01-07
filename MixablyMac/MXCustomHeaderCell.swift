//
//  MXCustomHeaderCell.swift
//  MixablyMac
//
//  Created by Harry Ng on 7/1/2016.
//  Copyright © 2016 MiQ. All rights reserved.
//

import Cocoa

let BG_COLOR = NSColor(deviceWhite: 0.1, alpha: 1.0)
let SLIDE_COLOR = NSColor(deviceWhite: 0.2, alpha: 1.0)

class MXCustomHeaderCell: NSTableHeaderCell {
    
    var showSlice: Bool = true
    
    func drawWithFrame(cellFrame: NSRect, isHighlighted flag: Bool, inView controlView: NSView) {
        BG_COLOR.setFill()
        NSRectFill(cellFrame)
        
        guard showSlice == true else { return }
        
        let (slice, _) = cellFrame.divide(1.0, fromEdge: .MaxXEdge)
        print("slide: \(slice)")
        let (vertical, _) = slice.divide(20.0, fromEdge: .MinYEdge)
        let (_, line) = vertical.divide(3.0, fromEdge: .MinYEdge)
        print("line: \(line)")
        SLIDE_COLOR.setFill()
        NSRectFill(line)
        
        drawInteriorWithFrame(cellFrame, inView: controlView)
    }
    
    override func drawWithFrame(cellFrame: NSRect, inView controlView: NSView) {
        drawWithFrame(cellFrame, isHighlighted: false, inView: controlView)
    }
    
    override func highlight(flag: Bool, withFrame cellFrame: NSRect, inView controlView: NSView) {
        drawWithFrame(cellFrame, isHighlighted: flag, inView: controlView)
    }
    
    override func drawInteriorWithFrame(cellFrame: NSRect, inView controlView: NSView) {
        let titleRect = titleRectForBounds(cellFrame)
        let newTitleRect = NSRect(origin: CGPoint(x: titleRect.origin.x, y: 5.0), size: titleRect.size)
        attributedStringValue.drawInRect(newTitleRect)
        
        if let image = image {
            image.drawInRect(imageRectForBounds(cellFrame))
        }
    }

}
