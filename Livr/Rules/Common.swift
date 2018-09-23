//
//  Common.swift
//  Pods-LivrDemo
//
//  Created by Felipe Lefèvre Marino on 9/18/18.
//

struct Common {
    
    // can't be nil/null
    struct Required: LivrRule {
        static var name = "required"
        var errorCode = "REQUIRED"
        
        init() {}
        
        func validate(value: Any?) -> ErrorCode? {
            guard let value = value, !String(describing: value).isEmpty else {
                return errorCode
            }
            return nil
        }
    }
    
    // can be Any? value, including nil/null
    struct NotEmpty: LivrRule {
        static var name = "not_empty"
        var errorCode = "CANNOT_BE_EMPTY"
        
        init() {}
        
        func validate(value: Any?) -> ErrorCode? {
            if let value = value, String(describing: value).isEmpty {
                return errorCode
            }
            return nil
        }
    }
}
