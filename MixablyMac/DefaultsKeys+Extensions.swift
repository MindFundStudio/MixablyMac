//
//  DefaultsKeys+Extensions.swift
//  MixablyMac
//
//  Created by Joseph Cheung on 15/12/2015.
//  Copyright © 2015 MiQ. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
    static let appInitLaunch = DefaultsKey<Bool>("appInitLaunch")
    static let lastEventId = DefaultsKey<Int?>("lastEventId")
}