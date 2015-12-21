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
import PSOperations

final class MXSongManager {
    
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
            
            let operationQueue = OperationQueue()
            operationQueue.maxConcurrentOperationCount = 4
            
            for song in songs {
                
                let fileURL = NSURL(string: song.location)!
                let operation = MXAnalyseOperation(fileURL: fileURL) { features, error in
                    
                    // Do something with features and error
                    if let error = error {
                        print("error: \(error.description)")
                    } else {
                        // Save features to song
                        if let features = features {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                let song = realm.objects(Song).filter("id = %@", song.id).first
                                if let song = song {
                                    try! realm.write {
                                        song.tonality = features.tonality
                                        song.intensity = features.intensity
                                        song.rmsEnergy = features.rmsEnergy
                                        song.tempo = features.tempo
                                        song.rhythm = features.rhythmStrength
                                        song.bass = features.bass
                                    }
                                }
                            })
                        }
                    }
                }
                
                // Make sure to add to an OperationQueue
                operationQueue.addOperation(operation)
            }
            
            return songs
        } catch let error as NSError {
            print("error loading iTunesLibrary")
            throw error
        }
    }
    
    class func processSong(song: Song) {
        
    }
    
}