//
//  MXFeatures.swift
//  MixablyMac
//
//  Created by Leo Tumwattana on 15/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

struct MXFeatures {
    
    let path:String
    let tonality:String
    let rmsEnergy:Double
    let intensity:Double
    let rhythmStrength:Double
    let tempo:Double
    let bins:[Double]
    
    var bass:Double {
        return 0.35 * bins[0] + 0.45 * bins[1] + 0.2 * bins[2]
    }
    
    init(path:String, tonality:String, intensity:Double, rhythmStrength:Double, rmsEnergy:Double, tempo:Double, bins:[Double]) {
        self.path = path
        self.tonality = tonality
        self.intensity = intensity
        self.rhythmStrength = rhythmStrength
        self.tempo = tempo
        self.bins = bins
    }
}
