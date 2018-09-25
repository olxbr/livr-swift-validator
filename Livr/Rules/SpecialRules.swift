//
//  SpecialRules.swift
//  Livr
//
//  Created by Felipe Lefèvre Marino on 9/25/18.
//  Copyright © 2018 Felipe Marino. All rights reserved.
//

typealias URLType = URL

struct SpecialRules {
    
    // must be a string or is converted to
    struct URL: LivrRule {
        static var name = "url"
        var errorCode = "WRONG_URL"
        
        init() {}
        
        func validate(value: Any?) -> (LivrRule.ErrorCode?, LivrRule.UpdatedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            if let value = value {
                if !Utils.isPrimitive(value: value) { return (.formatErrorCode, nil) }
                
                if let stringValue = value as? String,
                    stringValue.count < 2083, URLType(string: stringValue) != nil {
                        return (nil, nil)
                }
                return (errorCode, nil)
            }
            return (nil, nil)
        }
    }
}


