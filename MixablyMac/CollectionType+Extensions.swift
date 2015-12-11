//
//  CollectionType+Extensions.swift
//  MixablyMac
//
//  Created by Joseph Cheung on 10/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Foundation

extension CollectionType {
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}
