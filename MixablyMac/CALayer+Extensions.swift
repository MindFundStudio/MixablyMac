//
//  CALayer+Extensions.swift
//  MixablyMac
//
//  Created by Leo Tumwattana on 9/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Cocoa

extension CALayer {
    
    func moveAnchorPoint(point:CGPoint) {
        let oldOrigin = frame.origin
        anchorPoint = point
        let newOrigin = frame.origin
        
        let translation = NSMakePoint(newOrigin.x - oldOrigin.x, newOrigin.y - oldOrigin.y)
        frame.origin = NSMakePoint(frame.origin.x - translation.x, frame.origin.y - translation.y)
    }
    
}
