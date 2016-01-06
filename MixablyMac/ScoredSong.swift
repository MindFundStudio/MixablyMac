//
//  ScoredSong.swift
//  MixablyMac
//
//  Created by Leo Tumwattana on 17/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Cocoa
import Foundation

class ScoredSong: NSObject {
    
    dynamic let id:String
    dynamic let persistentID:NSNumber
    dynamic let name:String
    dynamic let location:String
    dynamic let score:Double
    
    dynamic var playing: Bool = false
    dynamic var selected: Bool = false
    dynamic var highlighted: Bool = false
    dynamic var textColor:NSColor {
        return highlighted ? highlightedTextColor : normalTextColor
    }
    
    init(id:String, persistentID:NSNumber, name:String, location:String, score:Double) {
        self.id = id
        self.persistentID = persistentID
        self.name = name
        self.location = location
        self.score = score
    }
    
}