//
//  String.swift
//  Livr
//
//  Created by Felipe Lefèvre Marino on 9/25/18.
//  Copyright © 2018 Felipe Marino. All rights reserved.
//

typealias StringType = String

struct StringRules {
    
    // must be a string or is converted to
    struct String: LivrRule {
        static var name = "string"
        var errorCode = ""
        
        init() {}
        
        func validate(value: Any?) -> (LivrRule.ErrorCode?, LivrRule.UpdatedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            if let value = value {
                if !Utils.isPrimitive(value: value) { return (.formatErrorCode, nil) }
                return (nil, StringType(describing: value) as AnyObject)
            }
            return (nil, nil)
        }
    }
}

