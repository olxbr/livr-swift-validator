//
//  Modifiers.swift
//  Livr
//
//  Created by Felipe Lefèvre Marino on 9/30/18.
//  Copyright © 2018 Felipe Marino. All rights reserved.
//

import Foundation

protocol Modifier {
    typealias ModifiedValue = AnyObject
    
    func modified(value: Any) -> AnyObject
}

struct ModifiersRules {
    
    struct ToLc: LivrRule, PreDefinedRule, Modifier {
        static var name: String = "to_lc"
        var errorCode: LIVR.ErrorCode = .format
        var arguments: Any?
        
        func validate(value: Any?) -> (Errors?, ModifiedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            
            if let value = value {
                if !Utils.isPrimitive(value) { return (nil, nil) }
                return (nil, modified(value: value))
            }
            return (nil, nil)
        }
        
        func modified(value: Any) -> AnyObject {
            return String(describing: value).lowercased() as AnyObject
        }
    }
    
    struct ToUc: LivrRule, PreDefinedRule, Modifier {
        static var name: String = "to_uc"
        var errorCode: LIVR.ErrorCode = .format
        var arguments: Any?
        
        func validate(value: Any?) -> (Errors?, ModifiedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            
            if let value = value {
                if !Utils.isPrimitive(value) { return (nil, nil) }
                return (nil, modified(value: value))
            }
            return (nil, nil)
        }
        
        func modified(value: Any) -> AnyObject {
            return String(describing: value).uppercased() as AnyObject
        }
    }
    
    struct Remove: LivrRule, PreDefinedRule, Modifier {
        static var name: String = "remove"
        var errorCode: LIVR.ErrorCode = .format
        var arguments: Any?
        
        func validate(value: Any?) -> (Errors?, ModifiedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            
            if let value = value {
                if !Utils.isPrimitive(value) { return (nil, nil) }
                return (nil, modified(value: value))
            }
            return (nil, nil)
        }
        
        func modified(value: Any) -> AnyObject {
            guard let charactersToRemove = arguments as? String else { return value as AnyObject }
            return String(describing: value).removingCharacters(in: CharacterSet(charactersIn: charactersToRemove)) as AnyObject
        }
    }
    
    struct LeaveOnly: LivrRule, PreDefinedRule, Modifier {
        static var name: String = "leave_only"
        var errorCode: LIVR.ErrorCode = .format
        var arguments: Any?
        
        func validate(value: Any?) -> (Errors?, ModifiedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            
            if let value = value {
                if !Utils.isPrimitive(value) { return (nil, nil) }
                return (nil, modified(value: value))
            }
            return (nil, nil)
        }
        
        func modified(value: Any) -> AnyObject {
            guard let charactersToRemove = arguments as? String else { return value as AnyObject }
            return String(describing: value).removingCharacters(in: CharacterSet(charactersIn: charactersToRemove).inverted) as AnyObject
        }
    }
    
    struct Default: LivrRule, PreDefinedRule, Modifier {
        static var name: String = "default"
        var errorCode: LIVR.ErrorCode = .format
        var arguments: Any?
        
        func validate(value: Any?) -> (Errors?, ModifiedValue?) {
            if Utils.hasNoValue(value) || value == nil {
                return (nil, modified(value: ""))
            }
            return (nil, nil)
        }
        
        func modified(value: Any) -> AnyObject {
            if let argumentsAsArray = arguments as? [Any] {
                return argumentsAsArray.first as AnyObject
            }
            return arguments as AnyObject
        }
    }
    
    struct Trim: LivrRule, PreDefinedRule, Modifier {
        static var name: String = "trim"
        var errorCode: LIVR.ErrorCode = .format
        var arguments: Any?
        
        func validate(value: Any?) -> (Errors?, ModifiedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            
            if let value = value {
                if !Utils.isPrimitive(value) { return (nil, nil) }
                return (nil, modified(value: value))
            }
            return (nil, nil)
        }
        
        func modified(value: Any) -> AnyObject {
            let valueAsString = String(describing: value)
            
            guard !valueAsString.trimmingCharacters(in: .whitespaces).isEmpty else {
                return value as AnyObject
            }
            
            if valueAsString.contains(" ") || valueAsString.contains("\n") {
                return String(describing: value).trimmingCharacters(in: .whitespacesAndNewlines) as AnyObject
            } else {
                return value as AnyObject
            }
        }
    }
}
