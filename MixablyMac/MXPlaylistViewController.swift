//
//  MXPlaylistViewController.swift
//  MixablyMac
//
//  Created by Leo Tumwattana on 8/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Cocoa
import RealmSwift
import iTunesLibrary
import AVFoundation

final class MXPlaylistViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, MXMixablyPresentationController {
    
    // ==================
    // MARK: - Properties
    // ==================
    
    let realm = try! Realm()
    
    var library: ITLibrary? = nil
    var audioPlayer: AVAudioPlayer?
    
    var viewToShrink:NSView {
        return tableView
    }
    
    dynamic var mediaItems: [ITLibMediaItem] = []
    dynamic var songs: [Song] = (try! Realm()).objects(Song).map { (song) in return song }
    
    private var mixablyViewController:MXMixablyViewController?
    
    // ================
    // MARK: - Subviews
    // ================
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet var arrayController: NSArrayController!
    
    // =================
    // MARK: - Lifecycle
    // =================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "toggleMixably:", name: MXNotifications.ToggleMixably.rawValue, object: nil)
        
        do {
            library = try ITLibrary(APIVersion: "1.0")
            let allItems = library!.allMediaItems as! [ITLibMediaItem]
            songs = allItems.filter({ (item) -> Bool in
                return item.mediaKind == UInt(ITLibMediaItemMediaKindSong) && item.locationType == UInt(ITLibMediaItemLocationTypeFile)
            }).map({ (item) -> Song in
                return Song(item: item)
            })
        } catch let error as NSError {
            print("error loading iTunesLibrary")
            NSAlert(error: error).runModal()
        }
        
        tableView.doubleAction = Selector("doubleClick:")
        
    }
    
    func toggleMixably(notification: NSNotification?) {
        if let vc = mixablyViewController {
            print("Dismiss")
            dismissViewController(vc)
            mixablyViewController = nil
        } else {
            print("Present")
            mixablyViewController = MXMixablyViewController.loadFromNib()
            presentViewController(mixablyViewController!, animator: MXMixablyPresentationAnimator())
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Double Action
    
    func doubleClick(sender: NSTableView) {
        let selectedItem = songs[tableView.selectedRow]
        audioPlayer = try? AVAudioPlayer(contentsOfURL: NSURL(string: selectedItem.location)!)
        audioPlayer?.play()
    }
    
    override func keyDown(theEvent: NSEvent) {
        interpretKeyEvents([theEvent])
    }
    
    override func insertText(insertString: AnyObject) {
        let text = insertString as! String
        if text == " " {
            toggleAudioPlayer()
        }
    }
    
    func toggleAudioPlayer() {
        if let audioPlayer = audioPlayer {
            if audioPlayer.playing {
                audioPlayer.stop()
            } else {
                audioPlayer.play()
            }
        } else if !mediaItems.isEmpty {
            audioPlayer = try? AVAudioPlayer(contentsOfURL: mediaItems[0].location)
            audioPlayer?.play()
        }
    }
}
