//
//  NSBezierPath+Extensions.swift
//  MixablyMac
//
//  Created by Leo Tumwattana on 6/1/2016.
//  Copyright © 2016 MiQ. All rights reserved.
//

// http://stackoverflow.com/questions/10533793/bezierpath-rotation-in-a-uiview
// http://svn.gna.org/svn/etoile/trunk/Etoile/Frameworks/EtoilePaint/NSBezierPath+Geometry.m

import Cocoa

extension NSBezierPath {
    
    func rotatePath(angle:CGFloat, aboutPoint point:NSPoint) -> NSBezierPath {
        if angle == 0 {
            return self
        } else {
            let c = copy()
            let xfm = RotationTransform(angle, aboutPoint: point)
            c.transformUsingAffineTransform(xfm)
            return c as! NSBezierPath
        }
    }
    
    func RotationTransform(angle:CGFloat, aboutPoint point:NSPoint) -> NSAffineTransform {
        let xfm = NSAffineTransform()
        xfm.translateXBy(point.x, yBy: point.y)
        xfm.rotateByRadians(angle)
        xfm.translateXBy(-point.x, yBy: -point.y)
        return xfm
    }
    
}
