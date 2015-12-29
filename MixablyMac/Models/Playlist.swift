//
//  Playlist.swift
//  MixablyMac
//
//  Created by Harry Ng on 10/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Cocoa
import RealmSwift

final class Playlist: Object {
    
    dynamic var name = "New Playlist"
    dynamic var order = 0
    
    var songs = List<Song>()
    
    dynamic var isNew = false
    
    static func create() -> Playlist {
        let playlist = Playlist()
        playlist.isNew = true
        return playlist
    }
    
    override static func ignoredProperties() -> [String] {
        return ["isNew"]
    }
    
}
