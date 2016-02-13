//
//  String+Extensions.swift
//  MixablyMac
//
//  Created by Harry Ng on 13/2/2016.
//  Copyright © 2016 MiQ. All rights reserved.
//

import Foundation

extension String {
    
    func toEscapeString() -> String {
        let result = stringByReplacingOccurrencesOfString("\'", withString: "\\'")
        return result
    }
    
}