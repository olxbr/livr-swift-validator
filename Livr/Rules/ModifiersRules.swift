//
//  Modifiers.swift
//  Livr
//
//  Created by Felipe Lefèvre Marino on 9/30/18.
//  Copyright © 2018 Felipe Marino. All rights reserved.
//

protocol Modifier {
    typealias ModifiedValue = AnyObject
    
    func modified(value: Any) -> AnyObject
}

struct ModifiersRules {
    
    struct ToLc: LivrRule, Modifier {
        static var name: String = "to_lc"
        var errorCode: ErrorCode = ""
        var arguments: Any?
        
        func validate(value: Any?) -> (Errors?, ModifiedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            
            if let value = value {
                if !Utils.isPrimitive(value: value) { return (nil, nil) }
                return (nil, modified(value: value))
            }
            return (nil, nil)
        }
        
        func modified(value: Any) -> AnyObject {
            return String(describing: value).lowercased() as AnyObject
        }
    }
    
    struct ToUc: LivrRule, Modifier {
        static var name: String = "to_uc"
        var errorCode: ErrorCode = ""
        var arguments: Any?
        
        func validate(value: Any?) -> (Errors?, ModifiedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            
            if let value = value {
                if !Utils.isPrimitive(value: value) { return (nil, nil) }
                return (nil, modified(value: value))
            }
            return (nil, nil)
        }
        
        func modified(value: Any) -> AnyObject {
            return String(describing: value).uppercased() as AnyObject
        }
    }
    
    struct Remove: LivrRule, Modifier {
        static var name: String = "remove"
        var errorCode: ErrorCode = ""
        var arguments: Any?
        
        func validate(value: Any?) -> (Errors?, ModifiedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            
            if let value = value {
                if !Utils.isPrimitive(value: value) { return (nil, nil) }
                return (nil, modified(value: value))
            }
            return (nil, nil)
        }
        
        func modified(value: Any) -> AnyObject {
            guard let charactersToRemove = arguments as? String else { return value as AnyObject }
            
            var modifiedValue = String(describing: value)
            for char in charactersToRemove {
                modifiedValue = modifiedValue.replacingOccurrences(of: String(char), with: "")
            }
            
            return modifiedValue as AnyObject
        }
    }
}

extension String {
    
    func stringByRemovingAll(characters: [Character]) -> String {
        return String(self.filter({ !characters.contains($0) }))
    }
}
