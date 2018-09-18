//
//  Common.swift
//  Pods-LivrDemo
//
//  Created by Felipe Lefèvre Marino on 9/18/18.
//

struct Common {
    
    struct Required: LivrRule {
        static var name = "required"
        var errorCode = "CANNOT_BE_EMPTY"
        
        init() {}
        
        func validate(value: Any) -> ErrorCode? {
            guard let stringValue = value as? String, !stringValue.isEmpty else {
                return errorCode
            }
            return nil
        }
    }
}
