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
            if String(describing: value).isEmpty {
                return errorCode
            }
            return nil
        }
    }
}
