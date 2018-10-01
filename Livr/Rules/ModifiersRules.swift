//
//  Modifiers.swift
//  Livr
//
//  Created by Felipe Lefèvre Marino on 9/30/18.
//  Copyright © 2018 Felipe Marino. All rights reserved.
//

struct ModifiersRules {
    
    struct ToLc: LivrRule {
        static var name: String = "to_lc"
        var errorCode: ErrorCode = ""
        var arguments: Any?
        var updatedValue: UpdatedValue?
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            
            if let value = value {
                if !Utils.isPrimitive(value: value) { return (nil, nil) }
                return (nil, String(describing: value).lowercased() as AnyObject)
            }
            return (nil, nil)
        }
    }
}
