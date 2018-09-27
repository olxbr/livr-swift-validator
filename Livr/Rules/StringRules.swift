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
        var arguments: Any?
        
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
    
    // must be equal defined value
    struct Eq: LivrRule {
        static var name = "eq"
        var errorCode = "NOT_ALLOWED_VALUE"
        var arguments: Any?
        
        init() {}
        
        func validate(value: Any?) -> (LivrRule.ErrorCode?, LivrRule.UpdatedValue?) {
            guard let arguments = arguments else { return (.formatErrorCode, nil) }
            if Utils.hasNoValue(value) { return (nil, nil) }
            if let value = value {
                if !Utils.isPrimitive(value: value) { return (.formatErrorCode, nil) }
                if let listOfArguments = arguments as? [Any],
                    let firstArgument = listOfArguments.first,
                    StringType(describing: firstArgument) == StringType(describing: value) {
                    
                    return (nil, firstArgument as AnyObject)
                }
                if StringType(describing: value) == StringType(describing: arguments) {
                    return (nil, arguments as AnyObject)
                }
                return (errorCode, nil)
            }
            return (nil, nil)
        }
    }

}

