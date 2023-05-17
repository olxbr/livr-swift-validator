//
//  Utils.swift
//  Livr
//
//  Created by Felipe Lefèvre Marino on 9/25/18.
//  Copyright © 2018 Felipe Marino. All rights reserved.
//

import Foundation

public struct Utils {
    
    public static func isPrimitive(_ value: Any) -> Bool{
        return value is String || value is NSNumber || value is Bool
    }
    
    public static func hasNoValue(_ value: Any?) -> Bool {
        if value == nil { return true }
        if let value = value as? String, value.isEmpty { return true }
        return false
    }
    
    public static func isNumber(_ value: Any) -> Bool {
        return value is NSNumber
    }
    
    public static func isString(_ value: Any) -> Bool {
        return value is String
    }
    
    public static func canBeCoercedToNumber(_ value: Any) -> Bool {
        return Double((value as? String) ?? "") != nil
    }
    
    public static func isList(_ value: Any) -> Bool {
        return value is Array<Any>
    }
}
