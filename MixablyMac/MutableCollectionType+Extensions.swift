//
//  MutableCollectionType+Extensions.swift
//  MixablyMac
//
//  Created by Joseph Cheung on 10/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Foundation

extension MutableCollectionType where Index == Int {
    mutating func shuffleInPlace() {
        if count < 2 { return }
        
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}
