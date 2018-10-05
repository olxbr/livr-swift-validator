//
//  Utils.swift
//  Livr
//
//  Created by Felipe Lefèvre Marino on 9/25/18.
//  Copyright © 2018 Felipe Marino. All rights reserved.
//

struct Utils {
    
    static func isPrimitive(value: Any) -> Bool{
        return value is String || value is NSNumber || value is Bool
    }
    
    static func hasNoValue(_ value: Any?) -> Bool {
        if value == nil { return true }
        if let value = value as? String, value.isEmpty { return true }
        return false
    }
    
    static func isNumber(_ value: Any) -> Bool {
        return value is NSNumber
    }
    
    static func isString(_ value: Any) -> Bool {
        return value is String
    }
    
    static func canBeCoercedToNumber(_ value: Any) -> Bool {
        let string = String(describing: value)
        return Double(string) != nil
    }
    
    static func isList(_ value: Any) -> Bool {
        return value is Array<Any>
    }
}
