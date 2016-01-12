//
//  DataManager.swift
//  MixablyMac
//
//  Created by Harry Ng on 11/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyUserDefaults

final class MXDataManager {
    
    class func importSeedData() {
        if Defaults[.appInitLaunch] {
            return
        }
        
        let realm = try! Realm()
        
        try! realm.write {
            realm.deleteAll()
        }
        
        let internalMood = Mood.createInternal()
        let m1 = Mood()
        m1.name = "M1"
        let m2 = Mood()
        m2.name = "M2"
        
        let pl1 = Playlist()
        pl1.name = "P1"
        let pl2 = Playlist()
        pl2.name = "P2"
        
        try! realm.write {
            realm.add(internalMood)
            realm.add(m1)
            realm.add(m2)
            realm.add(pl1)
            realm.add(pl2)
        }
    }
    
}