//
//  MXMixablyMoodFilterViewController.swift
//  MixablyMac
//
//  Created by Harry Ng on 21/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Cocoa
import RealmSwift

class MXMixablyMoodFilterViewController: NSViewController {
    
    let realm = try! Realm()

    @IBOutlet weak var tempoMainValue: NSTextField!
    @IBOutlet weak var tempoMainSlider: NSSlider!
    @IBOutlet weak var tempoSubSlider: NSSlider!
    
    @IBOutlet weak var intensityMainValue: NSTextField!
    @IBOutlet weak var intensityMainSlider: NSSlider!
    @IBOutlet weak var intensitySubSlider: NSSlider!
    
    @IBOutlet weak var rhythmMainValue: NSTextField!
    @IBOutlet weak var rhythmMainSlider: NSSlider!
    @IBOutlet weak var rhythmSubSlider: NSSlider!
    
    @IBOutlet weak var bassMainValue: NSTextField!
    @IBOutlet weak var bassMainSlider: NSSlider!
    @IBOutlet weak var bassSubSlider: NSSlider!
    
    private var mainTempo = 0.0 {
        didSet {
            tempoMainValue.stringValue = "\(tempoMainSlider.intValue)"
        }
    }
    private var mainIntensity = 0.0 {
        didSet {
            intensityMainValue.stringValue = "\(intensityMainSlider.intValue)"
        }
    }
    private var mainRhythm = 0.0 {
        didSet {
            rhythmMainValue.stringValue = "\(rhythmMainSlider.intValue)"
        }
    }
    private var mainBass = 0.0 {
        didSet {
            bassMainValue.stringValue = "\(bassMainSlider.intValue)"
        }
    }
    
    override func viewDidLoad() {
        var mood = MXPlayerManager.sharedManager.selectedMood
        if mood == nil {
            mood = Mood.create()
            if let mood = mood {
                NSNotificationCenter.defaultCenter().postNotificationName(MXNotifications.SelectMood.rawValue, object: self, userInfo: [MXNotificationUserInfo.Mood.rawValue: mood])
            }
        }
        
        loadMood(mood!)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "selectMood:", name: MXNotifications.SelectMood.rawValue, object: nil)
    }
    
    @IBAction func update(sender: NSSlider) {
        print("action: \(sender.doubleValue)")
        
        updateUI()
        reloadMoodFilter()
    }
    
    // MARK: - Helpers
    
    func updateUI() {
        mainTempo = tempoMainSlider.doubleValue
        mainIntensity = intensityMainSlider.doubleValue
        mainRhythm = rhythmMainSlider.doubleValue
        mainBass = bassMainSlider.doubleValue
    }
    
    func loadMood(mood: Mood) {
        tempoMainSlider.doubleValue = mood.tempoPredict
        tempoSubSlider.doubleValue = mood.tempoCoeff
        intensityMainSlider.doubleValue = mood.combinedEnergyIntensityPredict
        intensitySubSlider.doubleValue = mood.combinedEnergyIntensityCoeff
        rhythmMainSlider.doubleValue = mood.rhythmStrengthPredict
        rhythmSubSlider.doubleValue = mood.rhythmStrengthCoeff
        bassMainSlider.doubleValue = mood.bassPredict
        bassSubSlider.doubleValue = mood.bassCoeff
        
        updateUI()
        reloadMoodFilter()
    }
    
    func reloadMoodFilter() {
        guard let mood = MXPlayerManager.sharedManager.selectedMood else { return }
        
        realm.beginWrite()
        mood.tempoPredict = tempoMainSlider.doubleValue
        mood.tempoCoeff = tempoSubSlider.doubleValue
        mood.combinedEnergyIntensityPredict = intensityMainSlider.doubleValue
        mood.combinedEnergyIntensityCoeff = intensitySubSlider.doubleValue
        mood.rhythmStrengthPredict = rhythmMainSlider.doubleValue
        mood.rhythmStrengthCoeff = rhythmSubSlider.doubleValue
        mood.bassPredict = bassMainSlider.doubleValue
        mood.bassCoeff = bassSubSlider.doubleValue
        try! realm.commitWrite()
        
        NSNotificationCenter.defaultCenter().postNotificationName(MXNotifications.ReloadMixably.rawValue, object: self, userInfo: [MXNotificationUserInfo.Mood.rawValue: mood])
    }
    
    // MARK: - Notifications
    
    func selectMood(notification: NSNotification) {
        guard let mood = notification.userInfo?[MXNotificationUserInfo.Mood.rawValue] as? Mood else {
            return
        }
        
        loadMood(mood)
    }
}
