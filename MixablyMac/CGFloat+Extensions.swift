//
//  CGFloat+Extensions.swift
//  MixablyMac
//
//  Created by Leo Tumwattana on 6/1/2016.
//  Copyright © 2016 MiQ. All rights reserved.
//

import Foundation

let π = CGFloat(M_PI)

extension CGFloat {
    
    /**
     * Converts an angle in degrees to radians.
     */
    public func degreesToRadians() -> CGFloat {
        return π * self / 180.0
    }
    
    /**
     * Converts an angle in radians to degrees.
     */
    public func radiansToDegrees() -> CGFloat {
        return self * 180.0 / π
    }
    
}
