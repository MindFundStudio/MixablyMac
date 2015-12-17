//
//  MXPlayerViewController.swift
//  MixablyMac
//
//  Created by Leo Tumwattana on 8/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Cocoa

class MXPlayerViewController: NSViewController {
    let manager = MXPlayerManager.sharedManager
    
    @IBOutlet weak var songLengthTextField: NSTextField!
    
    @IBOutlet weak var playPauseButton: NSButton!
    
    @IBOutlet weak var volumeSlider: NSSlider!
    
    @IBOutlet weak var backButton: NSButton!
    
    @IBOutlet weak var nextButton: NSButton!
    
    @IBOutlet weak var mixablyButton: NSButton!
    
    var songTimer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "startPlaying:", name: MXNotifications.StartPlaying.rawValue, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "pausePlaying:", name: MXNotifications.PausePlaying.rawValue, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "stopPlaying:", name: MXNotifications.StopPlaying.rawValue, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeSong:", name: MXNotifications.ChangeSong.rawValue, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showMixably:", name: MXNotifications.SelectMood.rawValue, object: nil)
        
        backButton.enabled = false
        nextButton.enabled = false
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func slideVolume(sender: NSSlider) {
        manager.volume = sender.floatValue
    }
    
    @IBAction func toogleMixably(sender: NSButton) {
        print("mixably")
        NSNotificationCenter.defaultCenter().postNotificationName(MXNotifications.ToggleMixably.rawValue, object: nil, userInfo: nil)
    }
    
    @IBAction func next(sender: NSButton) {
        manager.next()
    }
    
    @IBAction func back(sender: NSButton) {
        manager.back()
    }
    
    @IBAction func setShuffle(sender: NSButton) {
        manager.isShuffle = !manager.isShuffle
        if manager.isShuffle {
            sender.state = NSOnState
        } else {
            sender.state = NSOffState
        }
    }
    
    @IBAction func setRepeat(sender: NSButton) {
        manager.isRepeat = !manager.isRepeat
        if manager.isRepeat {
            sender.state = NSOnState
        } else {
            sender.state = NSOffState
        }
    }
    
    @IBAction func togglePlay(sender: NSButton) {
        if manager.playing {
            manager.pause()
            sender.image = NSImage(named: "Play")
        } else {
            manager.play()
            sender.image = NSImage(named: "Pause")
        }
    }
    
    func updateProgress() {
        
    }
    
    // MARK: - Notifications
    
    func startPlaying(notification: NSNotification) {
        playPauseButton.image = NSImage(named: "Pause")
        songTimer = NSTimer(timeInterval: 1.0, target: self, selector: "updateProgress", userInfo: nil, repeats: true)
        backButton.enabled = true
        nextButton.enabled = true
    }
    
    func pausePlaying(notification: NSNotification) {
        playPauseButton.image = NSImage(named: "Play")
    }
    
    func stopPlaying(notification: NSNotification) {
        playPauseButton.image = NSImage(named: "Play")
    }
    
    func changeSong(notification: NSNotification) {
        guard let song = notification.userInfo?[MXNotificationUserInfo.Song.rawValue] else {
            backButton.enabled = false
            nextButton.enabled = false
            return
        }
        
        let formatter = NSDateComponentsFormatter()
        songLengthTextField.stringValue = "\(formatter.stringFromTimeInterval(song.duration)!)"
    }
    
    func showMixably(notification: NSNotification) {
        mixablyButton.state = NSOnState
    }
}
