//
//  MXSongManager.swift
//  MixablyMac
//
//  Created by Harry Ng on 11/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Foundation
import iTunesLibrary
import RealmSwift

class MXSongManager {
    
    class func importSongs() throws -> [Song]? {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if userDefaults.boolForKey(MX_INITIAL_LAUNCH) {
            return nil
        }
        
        // Import from iTunes
        do {
            let realm = try Realm()
            
            let library = try ITLibrary(APIVersion: "1.0")
            let allItems = library.allMediaItems as! [ITLibMediaItem]
            let songs = allItems.filter({ (item) -> Bool in
                return item.mediaKind == UInt(ITLibMediaItemMediaKindSong) && item.locationType == UInt(ITLibMediaItemLocationTypeFile)
            }).map({ (item) -> Song in
                return Song(item: item)
            })
            
            try realm.write {
                realm.add(songs)
            }
            
            return songs
        } catch let error as NSError {
            print("error loading iTunesLibrary")
            throw error
        }
    }
    
}