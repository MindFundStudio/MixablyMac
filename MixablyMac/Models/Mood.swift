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
    
    dynamic var tempoPredict:Double = 50.0
    dynamic var tempoCoeff:Double = 1.0
    dynamic var combinedEnergyIntensityPredict:Double = 50.0
    dynamic var combinedEnergyIntensityCoeff:Double = 1.0
    dynamic var rhythmStrengthPredict:Double = 50.0
    dynamic var rhythmStrengthCoeff:Double = 1.0
    dynamic var bassPredict:Double = 50.0
    dynamic var bassCoeff:Double = 1.0
    
    dynamic var isNew = false
    
    var songs = List<Song>()
    
    class func create() -> Mood {
        let mood = Mood()
        mood.name = ""
        mood.isNew = true
        return mood
    }
    
    func isLeaf() -> Bool {
        return true
    }
    
    override static func ignoredProperties() -> [String] {
        return ["isNew"]
    }
    
}
