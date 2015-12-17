//
//  ScoredSong.swift
//  MixablyMac
//
//  Created by Leo Tumwattana on 17/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Foundation

struct ScoredSong {
    
    let id:String
    let name:String
    let location:String
    let score:Double
    
    init(id:String, name:String, location:String, score:Double) {
        self.id = id
        self.name = name
        self.location = location
        self.score = score
    }
    
}