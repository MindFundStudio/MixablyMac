//
//  MXScoreSongsOperation.swift
//  MixablyMac
//
//  Created by Leo Tumwattana on 17/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Cocoa
import PSOperations
import RealmSwift

struct MXScoringInputs {
    
    let bassPredict:Double
    let bassCoeff:Double
    let rhythmStrengthPredict:Double
    let rhythmStrengthCoeff:Double
    let tempoPredict:Double
    let tempoCoeff:Double
    let combinedEnergyIntensityPredict:Double
    let combinedEnergyIntensityCoeff:Double
    
    init(bassPredict:Double, bassCoeff:Double, rhythmStrengthPredict: Double, rhythmStrengthCoeff: Double, tempoPredict: Double, tempoCoeff: Double, combinedEnergyIntensityPredict: Double, combinedEnergyIntensityCoeff: Double) {
        self.bassPredict = bassPredict
        self.bassCoeff = bassCoeff
        self.rhythmStrengthPredict = rhythmStrengthPredict
        self.rhythmStrengthCoeff = rhythmStrengthCoeff
        self.tempoPredict = tempoPredict
        self.tempoCoeff = tempoCoeff
        self.combinedEnergyIntensityPredict = combinedEnergyIntensityPredict
        self.combinedEnergyIntensityCoeff = combinedEnergyIntensityCoeff
    }
}

typealias MXScoreSongsCompletionBlock = ([ScoredSong], NSError?) -> Void

final class MXScoreSongsOperation: Operation {
    
    // ==================
    // MARK: - Properties
    // ==================
    
    let bassPredict:Double
    let bassCoeff:Double
    let rhythmStrengthPredict:Double
    let rhythmStrengthCoeff:Double
    let tempoPredict:Double
    let tempoCoeff:Double
    let combinedEnergyIntensityPredict:Double
    let combinedEnergyIntensityCoeff:Double
    
    let completion:MXScoreSongsCompletionBlock?
    
    var songs:Results<Song>!

    // ============
    // MARK: - Init
    // ============
    
    init(inputs:MXScoringInputs, completion: MXScoreSongsCompletionBlock?) {
        self.bassPredict = inputs.bassPredict
        self.bassCoeff = inputs.bassCoeff
        self.rhythmStrengthPredict = inputs.rhythmStrengthPredict
        self.rhythmStrengthCoeff = inputs.rhythmStrengthCoeff
        self.tempoPredict = inputs.tempoPredict
        self.tempoCoeff = inputs.tempoCoeff
        self.combinedEnergyIntensityPredict = inputs.combinedEnergyIntensityPredict
        self.combinedEnergyIntensityCoeff = inputs.combinedEnergyIntensityCoeff
        self.completion = completion
    }
    
    override func execute() {
        
        do {
            
            let realm = try Realm()
            songs = realm.objects(Song).filter("statusRaw == %@", Song.Status.Analyzed.rawValue)
            
            var scoredSongs = [ScoredSong]()
            
            for song in songs {
                let score = song.score(bassPredict: bassPredict,
                    bassCoeff: bassCoeff,
                    rhythmStrengthPredict: rhythmStrengthPredict,
                    rhythmStrengthCoeff: rhythmStrengthCoeff,
                    tempoPredict: tempoPredict,
                    tempoCoeff: tempoCoeff,
                    combinedEnergyIntensityPredict: combinedEnergyIntensityPredict,
                    combinedEnergyIntensityCoeff: combinedEnergyIntensityCoeff)
                
                let scoredSong = ScoredSong(id: song.id, name: song.name, location: song.location, score: score)
                scoredSongs.append(scoredSong)
            }
            
            scoredSongs.sortInPlace { (x, y) -> Bool in
                x.score < y.score
            }
            
            completion?(scoredSongs, nil)
            finish()
            
        } catch {
            finishWithError(NSError(domain: "MXScoredSongsOperationDomain",
                code: 0,
                userInfo: nil))
        }
    }
    
}
