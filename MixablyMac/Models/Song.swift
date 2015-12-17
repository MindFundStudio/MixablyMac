//
//  Song.swift
//  MixablyMac
//
//  Created by Harry Ng on 8/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Cocoa
import RealmSwift
import iTunesLibrary

final class Song: Object {
    
    // =================
    // MARK: - Constants
    // =================
    
    @objc enum Status:Int {
        case Unanalysed = 0, InProgress, Analyzed
    }
    
    private let highlightedTextColor = NSColor(colorLiteralRed: 74/255.0, green: 144/255.0, blue: 226/255.0, alpha: 1)
    private let normalTextColor = NSColor.blackColor()
    
    // ==================
    // MARK: - Properties
    // ==================
    
    dynamic var id:String = NSUUID().UUIDString
    dynamic var name:String = "New Song"
    dynamic var location:String = ""
    dynamic var duration:Double = 0.0
    dynamic var statusRaw:Int = 0
    
    dynamic var tonality:String?
    dynamic var rmsEnergy:Double = 0
    dynamic var intensity:Double = 0
    dynamic var rhythm:Double = 0
    dynamic var tempo:Double = 0
    dynamic var bass:Double = 0
    
    dynamic var status:Status {
        get {
            return Status(rawValue: statusRaw)!
        }
        set {
            statusRaw = status.rawValue
        }
    }
    
    dynamic var selected:Bool = false
    dynamic var highlighted:Bool = false
    dynamic var textColor:NSColor {
        return highlighted ? highlightedTextColor : normalTextColor
    }
    
    convenience init(item: ITLibMediaItem) {
        self.init()
        self.name = item.title
        self.location = item.location.absoluteString
        self.duration = NSTimeInterval(item.totalTime) / 1000.0
    }
    
    func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["selected", "highlighted", "textColor", "status"]
    }
    
    // =======================
    // MARK: - Mixably Scoring
    // =======================
    
    private let bassScalingFactor:Double = 0.7
    private let tempoScalingFactor:Double = 0.9
    private let rhythmStrengthScalingFactor:Double = 0.55
    private let intensityScalingFactor:Double = 0.5
    private let rmsEnergyScalingFactor:Double = 0.5
    
    private var scaledBass:Double {
        return bass * bassScalingFactor
    }
    
    private var scaledRhythmStrength:Double {
        return rhythmStrengthScalingFactor * rhythm
    }
    
    private var scaledIntensity:Double {
        return intensityScalingFactor * intensity
    }
    
    private var scaledRmsEnergy:Double {
        return rmsEnergyScalingFactor * rmsEnergy
    }
    
    private var scaledTempo:Double {
        return tempoScalingFactor * tempo
    }
    
    private var scaledCombinedEnergyAndIntensity:Double {
        return 0.5 * (scaledRmsEnergy + scaledIntensity)
    }
    
    func score(bassPredict bassPredict:Double, bassCoeff:Double, rhythmStrengthPredict:Double, rhythmStrengthCoeff:Double, tempoPredict:Double, tempoCoeff:Double, combinedEnergyIntensityPredict:Double, combinedEnergyIntensityCoeff:Double) -> Double {
        
        let tempBass = pow(bassCoeff * (scaledBass - bassPredict), 2)
        let tempRhythmStrength = pow(rhythmStrengthCoeff * (scaledRhythmStrength - rhythmStrengthPredict), 2)
        let tempTempo = pow(tempoCoeff * (scaledTempo - tempoPredict), 2)
        let tempCombinedEnergyAndIntensity = pow(combinedEnergyIntensityCoeff * (scaledCombinedEnergyAndIntensity - combinedEnergyIntensityPredict), 2)
        
        return sqrt(tempBass + tempRhythmStrength + tempTempo + tempCombinedEnergyAndIntensity / 2)
    }
    
}
