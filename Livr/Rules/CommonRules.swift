//
//  Common.swift
//  Pods-LivrDemo
//
//  Created by Felipe Lefèvre Marino on 9/18/18.
//

struct CommonRules {

    // can't be nil/null
    struct Required: LivrRule, PreDefinedRule {
        static var name = "required"
        var errorCode = "REQUIRED"
        var arguments: Any?
        
        init() {}
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            if Utils.hasNoValue(value) { return (errorCode, nil) }
            return (nil, nil)
        }
    }
    
    // can be Any? value, including nil/null
    struct NotEmpty: LivrRule, PreDefinedRule {
        static var name = "not_empty"
        var errorCode = "CANNOT_BE_EMPTY"
        var arguments: Any?
        
        init() {}
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            if let value = value, String(describing: value).isEmpty {
                return (errorCode, nil)
            }
            return (nil, nil)
        }
    }
    
    // must be a list of Any
    struct NotEmptyList: LivrRule, PreDefinedRule {
        static var name = "not_empty_list"
        var errorCode = "CANNOT_BE_EMPTY"
        var arguments: Any?
        
        init() {}
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            if Utils.hasNoValue(value) { return (errorCode, nil) }
            if let value = value {
                if Utils.hasNoValue(value) { return (errorCode, nil) }
                if !Utils.isList(value) { return (String.formatErrorCode, nil) }
                if let value = value as? Array<Any>, value.count < 1 { return (errorCode, nil) }
            }
            return (nil, nil)
        }
    }
    
    // must be a list of Any
    struct AnyObject: LivrRule, PreDefinedRule {
        static var name = "any_object"
        var errorCode = String.formatErrorCode
        var arguments: Any?
        
        init() {}
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            if value as? JSON == nil {
                return (errorCode, nil)
            }
            return (nil, nil)
        }
    }
}
