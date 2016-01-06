//
//  MXPlayerViewController.swift
//  MixablyMac
//
//  Created by Leo Tumwattana on 8/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Cocoa

final class MXPlayerViewController: NSViewController {
    let manager = MXPlayerManager.sharedManager
    
    @IBOutlet weak var songLengthTextField: NSTextField!
    
    @IBOutlet weak var playPauseButton: NSButton!
    
    @IBOutlet weak var volumeSlider: NSSlider!
    
    @IBOutlet weak var backButton: NSButton!
    
    @IBOutlet weak var nextButton: NSButton!
    
    @IBOutlet weak var songNameTextField: NSTextField!
    
    @IBOutlet weak var songProgressSlider: NSSlider!
    
    @IBOutlet weak var mixablyButton: NSButton!
    
    var songTimer: NSTimer?
    
    // =================
    // MARK: - Lifecycle
    // =================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "startPlaying:", name: MXNotifications.StartPlaying.rawValue, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "pausePlaying:", name: MXNotifications.PausePlaying.rawValue, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "stopPlaying:", name: MXNotifications.StopPlaying.rawValue, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeSong:", name: MXNotifications.ChangeSong.rawValue, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showMixably:", name: MXNotifications.SelectMood.rawValue, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "backSong:", name: MXNotifications.BackSong.rawValue, object: nil)
        
        backButton.enabled = false
        nextButton.enabled = false
        songNameTextField.stringValue = ""
        songProgressSlider.hidden = true
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // ================
    // MARK: - IBAction
    // ================
    
    @IBAction func slideVolume(sender: NSSlider) {
        manager.volume = sender.floatValue
    }
    
    @IBAction func showMenu(sender: NSButton) {
        let theMenu = NSMenu()
        theMenu.addItem(NSMenuItem(title: "Quit", action: Selector("terminate:"), keyEquivalent: "q"))
        
        NSMenu.popUpContextMenu(theMenu, withEvent: NSApp.currentEvent!, forView: sender)
    }
    
    @IBAction func toogleMixably(sender: NSButton) {
        print("mixably")
        // Check Mood isNew
        if let mood = MXPlayerManager.sharedManager.selectedMood where mood.isNew {
            mixablyButton.state = NSOnState
            
            let vc = MXPopoverViewController.loadFromNib()
            vc.popover.delegate = self
            vc.showPopover(mixablyButton, title: "Create New Mood")
            return
        }
        
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
    
    @IBAction func scrollProgress(sender: NSSlider) {
        manager.seekTo(sender.doubleValue)
    }
    
    // =============
    // MARK: - Timer
    // =============
    
    func updateProgress() {
        // Display current time
        // Update Progress bar
        songProgressSlider.doubleValue = songProgressSlider.doubleValue + 0.5
        print(songProgressSlider.doubleValue)
    }
    
    // =====================
    // MARK: - Notifications
    // =====================
    
    func startPlaying(notification: NSNotification) {
        print("startPlaying")
        playPauseButton.image = NSImage(named: "Pause")
        songTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "updateProgress", userInfo: nil, repeats: true)
        backButton.enabled = true
        nextButton.enabled = true
    }
    
    func pausePlaying(notification: NSNotification) {
        playPauseButton.image = NSImage(named: "Play")
        stopTimer()
    }
    
    func stopPlaying(notification: NSNotification) {
        playPauseButton.image = NSImage(named: "Play")
        stopTimer()
    }
    
    func changeSong(notification: NSNotification) {
        guard let song = notification.userInfo?[MXNotificationUserInfo.Song.rawValue] else {
            backButton.enabled = false
            nextButton.enabled = false
            return
        }
        
        let formatter = NSDateComponentsFormatter()
        songLengthTextField.stringValue = "\(formatter.stringFromTimeInterval(song.duration)!)"
        songNameTextField.stringValue = song.name
        
        songProgressSlider.hidden = false
        songProgressSlider.intValue = 0
        songProgressSlider.maxValue = song.duration
        
        stopTimer()
    }
    
    func backSong(notification: NSNotification) {
        songProgressSlider.intValue = 0
    }
    
    private func stopTimer() {
        songTimer?.invalidate()
        songTimer = nil
    }
    
    func showMixably(notification: NSNotification) {
        mixablyButton.state = NSOnState
    }
}

extension MXPlayerViewController: NSPopoverDelegate {
    func popoverDidClose(notification: NSNotification) {
        mixablyButton.state = NSOffState
        
        let center = NSNotificationCenter.defaultCenter()
        center.postNotificationName(MXNotifications.ToggleMixably.rawValue, object: nil)
        center.postNotificationName(MXNotifications.ReloadSidebarMood.rawValue, object: nil)
    }
}
