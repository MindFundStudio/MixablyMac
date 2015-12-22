//
//  MXMixablyMoodFilterViewController.swift
//  MixablyMac
//
//  Created by Harry Ng on 21/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Cocoa

class MXMixablyMoodFilterViewController: NSViewController {

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
        updateMood()
    }
    
    @IBAction func update(sender: NSSlider) {
        print("action: \(sender.doubleValue)")
        
        mainTempo = tempoMainSlider.doubleValue
        mainIntensity = intensityMainSlider.doubleValue
        mainRhythm = rhythmMainSlider.doubleValue
        mainBass = bassMainSlider.doubleValue
        
        updateMood()
    }
    
    // MARK: - Helpers
    
    func updateMood() {
        let mood = Mood()
        mood.tempoPredict = tempoMainSlider.doubleValue
        mood.tempoCoeff = tempoSubSlider.doubleValue
        mood.combinedEnergyIntensityPredict = intensityMainSlider.doubleValue
        mood.combinedEnergyIntensityCoeff = intensitySubSlider.doubleValue
        mood.rhythmStrengthPredict = rhythmMainSlider.doubleValue
        mood.rhythmStrengthCoeff = rhythmSubSlider.doubleValue
        mood.bassPredict = bassMainSlider.doubleValue
        mood.bassCoeff = bassSubSlider.doubleValue
        
        NSNotificationCenter.defaultCenter().postNotificationName(MXNotifications.ReloadMixably.rawValue, object: self, userInfo: [MXNotificationUserInfo.Mood.rawValue: mood])
    }
}
