//
//  MXMixablySongsViewController.swift
//  MixablyMac
//
//  Created by Harry Ng on 12/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Cocoa
import RealmSwift

final class MXMixablySongsViewController: NSViewController {
    
    let realm = try! Realm()
    dynamic var songs: [Song]!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        songs = realm.objects(Song).map { (song) in return song }
    }
    
}
