//
//  Integer.swift
//  Livr
//
//  Created by Felipe Lefèvre Marino on 9/23/18.
//  Copyright © 2018 Felipe Marino. All rights reserved.
//

struct Numeric {
    
    // must be integer
    struct Integer: LivrRule {
        static var name = "integer"
        var errorCode = "NOT_INTEGER"
        
        init() {}
        
        func validate(value: Any?) -> (LivrRule.ErrorCode?, LivrRule.UpdatedValue?) {
            guard value as? Int != nil else {
                if let stringValue = value as? String {
                    if stringValue.isEmpty {
                        return (nil, nil)
                    } else if let intValue = Int(stringValue) {
                        return (nil, intValue as AnyObject)
                    }
                }
                return (errorCode, nil)
            }
            return (nil, nil)
        }
    }
}
