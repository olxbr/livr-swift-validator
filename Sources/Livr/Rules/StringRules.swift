//
//  String.swift
//  Livr
//
//  Created by Felipe Lefèvre Marino on 9/25/18.
//  Copyright © 2018 Felipe Marino. All rights reserved.
//

import Foundation

typealias StringType = String

struct StringRules {
    
    // must be a string or is converted to
    struct String: LivrRule, PreDefinedRule {
        static var name = "string"
        var errorCode: LIVR.ErrorCode = .format
        var arguments: Any?
        
        init() {}
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            if let value = value {
                if Utils.isString(value) { return (nil, nil) }
                if !Utils.isPrimitive(value) { return (OutputError(errors: errorCode.rawValue), nil) }
                return (nil, StringType(describing: value) as AnyObject)
            }
            return (nil, nil)
        }
    }
    
    // must be equal defined value
    struct Eq: LivrRule, PreDefinedRule {
        static var name = "eq"
        var errorCode: LIVR.ErrorCode = .notAllowedValue
        var arguments: Any?
        
        init() {}
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            guard let arguments = arguments else { return (OutputError(errors: LIVR.ErrorCode.format.rawValue, args: [Eq.name: arguments]), nil) }
            if Utils.hasNoValue(value) { return (nil, nil) }
            if let value = value {
                if !Utils.isPrimitive(value) { return (OutputError(errors: LIVR.ErrorCode.format.rawValue, args: [Eq.name: arguments]), nil) }
                if let listOfArguments = arguments as? [Any],
                    let firstArgument = listOfArguments.first,
                    StringType(describing: firstArgument) == StringType(describing: value) {
                    
                    return (nil, firstArgument as AnyObject)
                }
                if StringType(describing: value) == StringType(describing: arguments) {
                    return (nil, arguments as AnyObject)
                }
                return (OutputError(errors: errorCode.rawValue, args: [Eq.name: arguments]), nil)
            }
            return (nil, nil)
        }
    }

    struct OneOf: LivrRule, PreDefinedRule {
        static var name = "one_of"
        var errorCode: LIVR.ErrorCode = .notAllowedValue
        var arguments: Any?
        
        init() {}
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            guard let arguments = arguments else { return (OutputError(errors: LIVR.ErrorCode.format.rawValue, args: [OneOf.name: arguments]), nil) }
            if Utils.hasNoValue(value) { return (nil, nil) }
            if let value = value {
                if !Utils.isPrimitive(value) { return (OutputError(errors: LIVR.ErrorCode.format.rawValue, args: [OneOf.name: arguments]), nil) }
                if StringType(describing: arguments) == StringType(describing: value) {
                    return (nil, arguments as AnyObject)
                }
                if let arrayOfArguments = arguments as? [Any] {
                    for argument in arrayOfArguments where StringType(describing: argument) == StringType(describing: value) {
                        
                        return (nil, argument as AnyObject)
                    }
                }
                if let arrayOfArguments = arguments as? [[Any]] {
                    for argumentsArray in arrayOfArguments {
                        for argument in argumentsArray where StringType(describing: argument) == StringType(describing: value) {
                            
                            return (nil, argument as AnyObject)
                        }
                    }
                }
                return (OutputError(errors: errorCode.rawValue, args: [OneOf.name: arguments]), nil)
            }
            return (nil, nil)
        }
    }
    
    struct MaxLength: LivrRule, PreDefinedRule {
        static var name = "max_length"
        var errorCode: LIVR.ErrorCode = .tooLong
        var arguments: Any?
        
        init() {}
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            guard let arguments = arguments else { return (OutputError(errors: LIVR.ErrorCode.format.rawValue, args: [MaxLength.name: arguments]), nil) }
            if Utils.hasNoValue(value) { return (nil, nil) }
            if let value = value {
                if !Utils.isPrimitive(value) { return (OutputError(errors: LIVR.ErrorCode.format.rawValue, args: [MaxLength.name: arguments]), nil) }
                
                var maxLengthAsString = StringType(describing: arguments)
                let valueAsString = StringType(describing: value)
                if let maxLength = Int(maxLengthAsString) {
                    if valueAsString.count > maxLength {
                        return (OutputError(errors: errorCode.rawValue, args: [MaxLength.name: arguments]), nil)
                    }
                    return (nil, valueAsString as AnyObject)
                } else if let arrayOfArguments = arguments as? [Any], let firstArgument = arrayOfArguments.first {
                    
                    maxLengthAsString = StringType(describing: firstArgument)
                    if let maxLength = Int(maxLengthAsString),
                        valueAsString.count > maxLength {
                    
                        return (OutputError(errors: errorCode.rawValue, args: [MaxLength.name: arrayOfArguments]), nil)
                    }
                    return (nil, valueAsString as AnyObject)
                }
            }
            return (nil, nil)
        }
    }
    
    struct MinLength: LivrRule, PreDefinedRule {
        static var name = "min_length"
        var errorCode: LIVR.ErrorCode = .tooShort
        var arguments: Any?
        
        init() {}
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            guard let arguments = arguments else { return (OutputError(errors: LIVR.ErrorCode.format.rawValue, args: [MinLength.name: arguments]), nil) }
            if Utils.hasNoValue(value) { return (nil, nil) }
            if let value = value {
                if !Utils.isPrimitive(value) { return (OutputError(errors: LIVR.ErrorCode.format.rawValue, args: [MinLength.name: arguments]), nil) }
                
                var minLengthAsString = StringType(describing: arguments)
                let valueAsString = StringType(describing: value)
                if let minLength = Int(minLengthAsString) {
                    if valueAsString.count < minLength {
                        return (OutputError(errors: errorCode.rawValue, args: [MinLength.name: arguments]), nil)
                    }
                    return (nil, valueAsString as AnyObject)
                } else if let arrayOfArguments = arguments as? [Any], let firstArgument = arrayOfArguments.first {
                    
                    minLengthAsString = StringType(describing: firstArgument)
                    if let minLength = Int(minLengthAsString),
                        valueAsString.count < minLength {
                        
                        return (OutputError(errors: errorCode.rawValue, args: [MinLength.name: arrayOfArguments]), nil)
                    }
                    return (nil, valueAsString as AnyObject)
                }
            }
            return (nil, nil)
        }
    }
    
    struct LengthBetween: LivrRule, PreDefinedRule {
        static var name = "length_between"
        var errorCode: LIVR.ErrorCode = .format
        var arguments: Any?
        
        init() {}
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            guard let arguments = arguments else { return (OutputError(errors: LIVR.ErrorCode.format.rawValue, args: [LengthBetween.name: arguments]), nil) }
            if Utils.hasNoValue(value) { return (nil, nil) }
            if let value = value {
                if !Utils.isPrimitive(value) { return (OutputError(errors: LIVR.ErrorCode.format.rawValue, args: [LengthBetween.name: arguments]), nil) }
                
                let valueAsString = StringType(describing: value)
                if let arrayOfArguments = arguments as? [Any], let minLengthArgument = arrayOfArguments.first, arrayOfArguments.count > 1 {
                    
                    let maxLengthArgument = arrayOfArguments[1]
                    
                    let minLengthAsString = StringType(describing: minLengthArgument)
                    let maxLengthAsString = StringType(describing: maxLengthArgument)
                    if let minLength = Int(minLengthAsString),
                        valueAsString.count < minLength {
                        
                        return (OutputError(errors: LIVR.ErrorCode.tooShort.rawValue, args: [LengthBetween.name: arrayOfArguments]), nil)
                    } else if let maxLength = Int(maxLengthAsString),
                        valueAsString.count > maxLength {
                        
                        return (OutputError(errors: LIVR.ErrorCode.tooLong.rawValue, args: [LengthBetween.name: arrayOfArguments]), nil)
                    }
                    return (nil, valueAsString as AnyObject)
                }
                return (nil, valueAsString as AnyObject)
            }
            return (nil, nil)
        }
    }
    
    struct LengthEqual: LivrRule, PreDefinedRule {
        static var name = "length_equal"
        var errorCode: LIVR.ErrorCode = .format
        var arguments: Any?
        
        init() {}
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            guard let arguments = arguments else { return (OutputError(errors: LIVR.ErrorCode.format.rawValue, args: [LengthEqual.name: arguments]), nil) }
            if Utils.hasNoValue(value) { return (nil, nil) }
            if let value = value {
                if !Utils.isPrimitive(value) { return (OutputError(errors: LIVR.ErrorCode.format.rawValue, args: [LengthEqual.name: arguments]), nil) }
                
                var allowedLengthAsString = StringType(describing: arguments)
                let valueAsString = StringType(describing: value)
                if let allowedLength = Int(allowedLengthAsString) {
                    if valueAsString.count < allowedLength {
                        return (OutputError(errors: LIVR.ErrorCode.tooShort.rawValue, args: [LengthEqual.name: arguments]), nil)
                    } else if 
                        valueAsString.count > allowedLength {
                        return (OutputError(errors: LIVR.ErrorCode.tooLong.rawValue, args: [LengthEqual.name: arguments]), nil)
                    }
                    return (nil, valueAsString as AnyObject)
                } else if let arrayOfArguments = arguments as? [Any], let firstArgument = arrayOfArguments.first {
                    
                    allowedLengthAsString = StringType(describing: firstArgument)
                    if let allowedLength = Int(allowedLengthAsString) {
                        if valueAsString.count < allowedLength {
                            return (OutputError(errors: LIVR.ErrorCode.tooShort.rawValue, args: [LengthEqual.name: arrayOfArguments]), nil)
                        } else if valueAsString.count > allowedLength {
                            return (OutputError(errors: LIVR.ErrorCode.tooLong.rawValue, args: [LengthEqual.name: arrayOfArguments]), nil)
                        }
                        return (nil, valueAsString as AnyObject)
                    }
                }
                return (nil, valueAsString as AnyObject)
            }
            return (nil, nil)
        }
    }
    
    struct Like: LivrRule, PreDefinedRule {
        static var name = "like"
        var errorCode: LIVR.ErrorCode = .wrongFormat
        var arguments: Any?
        
        init() {}
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            guard let arguments = arguments else { return (OutputError(errors: LIVR.ErrorCode.format.rawValue, args: [Like.name: arguments]), nil) }
            if Utils.hasNoValue(value) { return (nil, nil) }
            if let value = value {
                if !Utils.isPrimitive(value) { return (OutputError(errors: LIVR.ErrorCode.format.rawValue, args: [Like.name: arguments]), nil) }
                
                let valueAsString = value as? StringType ?? StringType(describing: value)
                
                if let regex = arguments as? StringType {
                    let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
                    if !predicate.evaluate(with: valueAsString) {
                        return (OutputError(errors: errorCode.rawValue, args: [Like.name: arguments]), nil)
                    }
                    return (nil, valueAsString as AnyObject)
                } else  if let arrayOfArguments = arguments as? [Any], var regex = arrayOfArguments.first as? StringType {
                    
                    if arrayOfArguments.count > 1,
                        let flag = arrayOfArguments[1] as? StringType,
                        flag == "i" {
                        
                        regex.replaceSubrange(regex.startIndex...regex.startIndex, with: "(?i)")
                    }
                    
                    let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
                    if !predicate.evaluate(with: valueAsString) {
                        return (OutputError(errors: errorCode.rawValue, args: [Like.name: arrayOfArguments]), nil)
                    }
                    return (nil, valueAsString as AnyObject)
                }
            }
            return (nil, nil)
        }
    }
}

