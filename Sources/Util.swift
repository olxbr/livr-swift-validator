//
//  Util.swift
//  Pods-LivrDemo
//
//  Created by Felipe Lefèvre Marino on 9/16/18.
//

struct Util {
    
    static func isObject(value: AnyObject) -> Bool {
        if value is Json || value is [Json] {
            return true
        }
        return false
    }
}
