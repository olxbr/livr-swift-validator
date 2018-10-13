//
//  Disctionary+Extension.swift
//  LivrTests
//
//  Created by Felipe Lefèvre Marino on 9/23/18.
//  Copyright © 2018 Felipe Marino. All rights reserved.
//

import Foundation

extension Dictionary where Key: Hashable, Value: Any {
    
    func isEqual<K: Hashable, V: Any>(to other: [K: V]) -> Bool {
        return (self as NSDictionary).isEqual(to: other)
    }
}
