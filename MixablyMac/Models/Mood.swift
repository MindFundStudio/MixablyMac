//
//  Mood.swift
//  MixablyMac
//
//  Created by Harry Ng on 10/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Cocoa
import RealmSwift

final class Mood: Object {

    dynamic var name = "New Mood"
    dynamic var order = 0
    
    dynamic var tempoPredict:Double = 0.0
    dynamic var tempoCoeff:Double = 0.0
    dynamic var combinedEnergyIntensityPredict:Double = 0.0
    dynamic var combinedEnergyIntensityCoeff:Double = 0.0
    dynamic var rhythmStrengthPredict:Double = 0.0
    dynamic var rhythmStrengthCoeff:Double = 0.0
    dynamic var bassPredict:Double = 0.0
    dynamic var bassCoeff:Double = 0.0
    
    var songs = List<Song>()
    
    func isLeaf() -> Bool {
        return true
    }
    
}
