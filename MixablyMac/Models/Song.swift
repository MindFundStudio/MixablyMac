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
    
    dynamic var id = NSUUID().UUIDString
    dynamic var name = "New Song"
    dynamic var location = ""
    dynamic var duration = 0.0
    
    dynamic var tonality = ""
    dynamic var rmsEnergy = 100.0
    dynamic var intensity = 100.0
    dynamic var rhythm = 100.0
    dynamic var tempo = 100.0
    dynamic var bass = 100.0
    
    
    convenience init(item: ITLibMediaItem) {
        self.init()
        self.name = item.title
        self.location = item.location.absoluteString
        self.duration = NSTimeInterval(item.totalTime) / 1000.0
    }
    
    override static func primaryKey() -> String? {
        return "id"
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
