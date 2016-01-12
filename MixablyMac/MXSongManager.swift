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
import SwiftyUserDefaults

final class MXSongManager {
    private var watcher: MXFileSystemWatcher?
    lazy var operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 2
        return operationQueue
    }()

    func importSongs() throws -> [Song]? {
        if Defaults[.appInitLaunch] {
            return nil
        }

        // Import from iTunes
        do {
            let realm = try Realm()

            let library = try ITLibrary(APIVersion: "1.0")
            let allItems = library.allMediaItems as! [ITLibMediaItem]
            let songs = allItems.filter({ (item) -> Bool in
                return item.location != nil && item.mediaKind == UInt(ITLibMediaItemMediaKindSong) && item.locationType == UInt(ITLibMediaItemLocationTypeFile)
            }).map({ (item) -> Song in
                return Song(item: item)
            })

            print("import songs, song count: \(songs.count)")
            MXAnalyticsManager.importSongs(songs.count)
            try realm.write {
                realm.add(songs)
            }

            for song in songs {
                saveSong(song)
            }

            return songs
        } catch let error as NSError {
            print("error loading iTunesLibrary")
            throw error
        }
    }
    
    func stopAnalysis() {
        operationQueue.cancelAllOperations()
    }
    
    func processUnanalysedSongs() throws {
        guard Defaults[.appInitLaunch] else { return }
        
        do {
            let realm = try Realm()
            
            let songs = realm.objects(Song).filter("statusRaw != %@", Song.Status.Analyzed.rawValue)
            print("re-process song count: \(songs.count)")
            
            for song in songs {
                saveSong(song)
            }
        } catch let error as NSError {
            throw error
        }
    }

    func trackSongDirectory() {
        do {
            let library = try ITLibrary(APIVersion: "1.0")
            let location = library.musicFolderLocation

            if let lastEventId = Defaults["lastEventId"].number {
                watcher = MXFileSystemWatcher(pathsToWatch: [location.path!], sinceWhen: FSEventStreamEventId(lastEventId.unsignedLongLongValue))
            } else {
                watcher = MXFileSystemWatcher(pathsToWatch: [location.path!])
            }

            watcher?.onFileChange = { [unowned self] eventId, eventPath, eventFlags in
                let url = NSURL(fileURLWithPath: eventPath)

                if (eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemIsFile)) != 0 {
                    // file change

                    guard let pathExtension = url.pathExtension else {
                        // file doesn't have an extension
                        return
                    }

                    guard ["mp3", "ogg", "wav", "aiff", "aac", "m4a"].contains(pathExtension) else {
                        // file is not song
                        return
                    }

                    if (eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemCreated)) != 0 {
                        // file created
                        print("song created: \(eventPath) - \(eventId)")
                        self.addSongFromURL(url)
                    }

                    if (eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemRemoved)) != 0 {
                        // file removed
                        print("song removed: \(eventPath) - \(eventId)")
                        self.removeSong(url)
                    }

                    if (eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemRenamed)) != 0 {
                        // file renamed
                        var error: NSError?
                        if url.checkResourceIsReachableAndReturnError(&error) {
                            // file exists
                            print("song renamed to: \(eventPath) - \(eventId)")
                            self.addSongFromURL(url)
                        } else {
                            // file doesn't exist anymore
                            print("song renamed from: \(eventPath) - \(eventId)     ")
                            self.removeSong(url)
                        }
                    }

                    if (eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemModified)) != 0 {
                        // file modified
                        print("song modified: \(eventPath) - \(eventId)")
                        self.updateSongAtURL(url)
                    }
                }

                if (eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemIsDir)) != 0 {
                    // directory change
                    if (eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemCreated)) != 0 {
                        // directory created
                        print("directory created: \(eventPath)")
                    }

                    if (eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemRemoved)) != 0 {
                        // directory removed
                        print("directory removed: \(eventPath)")
                        self.removeSong(url)
                    }

                    if (eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemRenamed)) != 0 {
                        // directory renamed
                        print("directory renamed: \(eventPath)")
                        var error: NSError?
                        if !url.checkResourceIsReachableAndReturnError(&error) {
                            // directory doesn't exist anymore
                            self.removeSong(url)
                        }
                    }

                    if (eventFlags & FSEventStreamEventFlags(kFSEventStreamEventFlagItemModified)) != 0 {
                        // directory modified
                        print("directory modified: \(eventPath)")
                    }
                }

                let numberOffset = NSNumber(unsignedLongLong: eventId)
                Defaults["lastEventId"] = numberOffset
            }
            watcher?.start()
        } catch let error as NSError {
            print("ITunes library error: \(error)")
        }
    }

    func addSongFromURL(url: NSURL) {
        var error: NSError?
        if url.checkResourceIsReachableAndReturnError(&error) {
            let song = Song(url: url)
            print("add song: \(song)")
            do {
                let realm = try Realm()
                let existingSong = realm.objects(Song).filter("location CONTAINS '\(url.path!)'")
                if existingSong.isEmpty {
                    try! realm.write {
                        realm.add(song)
                    }
                    
                    self.updatePlaylist()
                    saveSong(song)
                    
                    MXAnalyticsManager.importSongs(1)
                }
            } catch {
                print("realm error")
            }
        } else {
            print("error getting file: \(error)")
        }
    }

    func saveSong(song: Song) {
        do {
            let realm = try Realm()
            try! realm.write {
                song.statusRaw = Song.Status.InProgress.rawValue
            }

            let fileURL = NSURL(fileURLWithPath: song.location)

            let operation = MXAnalyseOperation(fileURL: fileURL) { features, error in

                if !song.invalidated {
                    // Do something with features and error
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if let error = error {
                            print("error: \(error.description)")
                            try! realm.write {
                                song.statusRaw = Song.Status.Unanalysed.rawValue
                            }
                        } else {
                            // Save features to song
                            if let features = features {
                                try! realm.write {
                                    song.tonality = features.tonality
                                    song.intensity = features.intensity
                                    song.rmsEnergy = features.rmsEnergy
                                    song.tempo = features.tempo
                                    song.rhythm = features.rhythmStrength
                                    song.bass = features.bass
                                    song.statusRaw = Song.Status.Analyzed.rawValue
                                }
                            }
                        }
                        MXAnalyticsManager.saveSong(song.statusRaw)
                    })
                }
            }

            // Make sure to add to an OperationQueue
            operationQueue.addOperation(operation)
        } catch {
            print("realm error")
        }
    }
    
    func updateSongAtURL(url: NSURL) {
        do {
            let realm = try Realm()
            let existingSong = realm.objects(Song).filter("location CONTAINS '\(url.path!)'")
            if !existingSong.isEmpty {
                let song = existingSong[0]
                try! realm.write {
                    song.updateAttributesFromURL(url)
                }
                print("update song: \(song)")
                updatePlaylist()
            }
        } catch {
            print("realm error")
        }
    }

    func removeSong(url: NSURL) {
        do {
            let realm = try Realm()
            let song = realm.objects(Song).filter("location CONTAINS '\(url.path!)'")
            dispatch_async(dispatch_get_main_queue(), {[unowned self] in
                try! realm.write {
                    realm.delete(song)
                }
                self.updatePlaylist()
            })
        } catch {
            print("realm error")
        }
    }
    
    func updatePlaylist() {
        if let playlist = MXPlayerManager.sharedManager.selectedPlaylist {
            NSNotificationCenter.defaultCenter().postNotificationName(MXNotifications.SelectPlaylist.rawValue, object: self, userInfo: [MXNotificationUserInfo.Playlist.rawValue: playlist])
        } else {
            let playlist = Playlist()
            playlist.name = AllSongs
            NSNotificationCenter.defaultCenter().postNotificationName(MXNotifications.SelectPlaylist.rawValue, object: self, userInfo: [MXNotificationUserInfo.Playlist.rawValue: playlist])
        }
    }

    deinit {
        watcher?.stop()
    }
}