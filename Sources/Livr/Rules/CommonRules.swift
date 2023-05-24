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
        var errorCode: LIVR.ErrorCode = .required
        var arguments: Any?
        
        init() {}
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            if Utils.hasNoValue(value) { return (OutputError(errors: errorCode.rawValue), nil) }
            return (nil, nil)
        }
    }
    
    // can be Any? value, including nil/null
    struct NotEmpty: LivrRule, PreDefinedRule {
        static var name = "not_empty"
        var errorCode: LIVR.ErrorCode = .cannotBeEmpty
        var arguments: Any?
        
        init() {}
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            if let value = value, String(describing: value).isEmpty {
                return (OutputError(errors: errorCode.rawValue), nil)
            }
            return (nil, nil)
        }
    }
    
    // must be a list of Any
    struct NotEmptyList: LivrRule, PreDefinedRule {
        static var name = "not_empty_list"
        var errorCode: LIVR.ErrorCode = .cannotBeEmpty
        var arguments: Any?
        
        init() {}
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            if Utils.hasNoValue(value) { return (OutputError(errors: errorCode.rawValue), nil) }
            if let value = value {
                if Utils.hasNoValue(value) { return (OutputError(errors: errorCode.rawValue), nil) }
                if !Utils.isList(value) { return (OutputError(errors: LIVR.ErrorCode.format.rawValue), nil) }
                if let value = value as? Array<Any>, value.count < 1 { return (OutputError(errors: errorCode.rawValue), nil) }
            }
            return (nil, nil)
        }
    }
    
    // must be a list of Any
    struct AnyObject: LivrRule, PreDefinedRule {
        static var name = "any_object"
        var errorCode: LIVR.ErrorCode = .format
        var arguments: Any?
        
        init() {}
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            if value as? [String: Any?] == nil {
                return (OutputError(errors: errorCode.rawValue), nil)
            }
            return (nil, nil)
        }
    }
}
