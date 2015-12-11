//
//  Song.swift
//  MixablyMac
//
//  Created by Harry Ng on 8/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Cocoa
import RealmSwift
import iTunesLibrary

class Song: Object {
    
    dynamic var name = "New Song"
    dynamic var intensity = 100.0
    dynamic var rhythm = 100.0
    dynamic var bass = 100.0
    dynamic var location = ""
    dynamic var duration = 0.0
    
    convenience init(item: ITLibMediaItem) {
        self.init()
        self.name = item.title
        self.location = item.location.absoluteString
        self.duration = NSTimeInterval(item.totalTime) / 1000.0
    }
}
