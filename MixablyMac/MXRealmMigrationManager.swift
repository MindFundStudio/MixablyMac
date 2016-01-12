//
//  MXRealmMigrationManager.swift
//  MixablyMac
//
//  Created by Harry Ng on 6/1/2016.
//  Copyright © 2016 MiQ. All rights reserved.
//

import Foundation
import RealmSwift

class MXRealmMigrationManager {
    
    class func migrate(path: String?) {
        
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            schemaVersion: 2,
            migrationBlock: { (migration, oldSchemaVersion) -> Void in
                if (oldSchemaVersion < 1) {
                    // Add persistenceID
                }
                
                if (oldSchemaVersion < 2) {
                    // Add isInternal to Mood
                }
        })
        
    }
    
}