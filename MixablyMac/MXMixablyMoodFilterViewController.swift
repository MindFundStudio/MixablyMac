//
//  MXMixablyMoodFilterViewController.swift
//  MixablyMac
//
//  Created by Harry Ng on 21/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Cocoa

class MXMixablyMoodFilterViewController: NSViewController {

    @IBOutlet weak var tempoMainSlider: NSSlider!
    @IBOutlet weak var tempoSubSlider: NSSlider!
    @IBOutlet weak var intensityMainSlider: NSSlider!
    @IBOutlet weak var intensitySubSlider: NSSlider!
    @IBOutlet weak var rhythmMainSlider: NSSlider!
    @IBOutlet weak var rhythmSubSlider: NSSlider!
    @IBOutlet weak var bassMainSlider: NSSlider!
    @IBOutlet weak var bassSubSlider: NSSlider!
    
    override func viewDidLoad() {
        
    }
    
    @IBAction func update(sender: NSSlider) {
        print("action: \(sender.doubleValue)")
        
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
