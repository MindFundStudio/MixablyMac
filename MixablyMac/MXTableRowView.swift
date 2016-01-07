//
//  MXTableRowView.swift
//  MixablyMac
//
//  Created by Harry Ng on 7/1/2016.
//  Copyright © 2016 MiQ. All rights reserved.
//

import Cocoa

class MXTableRowView: NSTableRowView {
    
    override func drawSelectionInRect(dirtyRect: NSRect) {
        if selectionHighlightStyle != .None {
            let selectionRect = bounds
            MXColor.SelectionColor.setFill()
            NSRectFill(selectionRect)
        }
    }
    
}
