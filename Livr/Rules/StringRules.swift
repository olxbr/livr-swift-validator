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
                if !Utils.isPrimitive(value) { return (errorCode.rawValue, nil) }
                return (nil, StringType(describing: value) as AnyObject)
            }
            return (nil, nil)
        }
    }
    
    // must be equal defined value
    // values are compared in their string forms (LIVR 2.5), so {"eq": true} accepts true and "true",
    // and as LIVR 2.0 compared them, so it accepts "1" too
    struct Eq: LivrRule, PreDefinedRule {
        static var name = "eq"
        var errorCode: LIVR.ErrorCode = .notAllowedValue
        var arguments: Any?
        
        init() {}
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            guard let arguments = arguments else { return (LIVR.ErrorCode.format.rawValue, nil) }
            if Utils.hasNoValue(value) { return (nil, nil) }
            if let value = value {
                if !Utils.isPrimitive(value) { return (LIVR.ErrorCode.format.rawValue, nil) }
                if let listOfArguments = arguments as? [Any],
                    let firstArgument = listOfArguments.first,
                    Utils.isEqualForEqAndOneOf(value, firstArgument) {
                    
                    return (nil, firstArgument as AnyObject)
                }
                if Utils.isEqualForEqAndOneOf(value, arguments) {
                    return (nil, arguments as AnyObject)
                }
                return (errorCode.rawValue, nil)
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
            guard let arguments = arguments else { return (LIVR.ErrorCode.format.rawValue, nil) }
            if Utils.hasNoValue(value) { return (nil, nil) }
            if let value = value {
                if !Utils.isPrimitive(value) { return (LIVR.ErrorCode.format.rawValue, nil) }
                if Utils.isEqualForEqAndOneOf(value, arguments) {
                    return (nil, arguments as AnyObject)
                }
                if let arrayOfArguments = arguments as? [Any] {
                    for argument in arrayOfArguments where Utils.isEqualForEqAndOneOf(value, argument) {
                        
                        return (nil, argument as AnyObject)
                    }
                }
                if let arrayOfArguments = arguments as? [[Any]] {
                    for argumentsArray in arrayOfArguments {
                        for argument in argumentsArray where Utils.isEqualForEqAndOneOf(value, argument) {
                            
                            return (nil, argument as AnyObject)
                        }
                    }
                }
                return (errorCode.rawValue, nil)
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
            guard let arguments = arguments else { return (LIVR.ErrorCode.format.rawValue, nil) }
            if Utils.hasNoValue(value) { return (nil, nil) }
            if let value = value {
                if !Utils.isPrimitive(value) { return (LIVR.ErrorCode.format.rawValue, nil) }
                
                var maxLengthAsString = StringType(describing: arguments)
                let valueAsString = StringType(describing: value)
                if let maxLength = Int(maxLengthAsString) {
                    if valueAsString.count > maxLength {
                        return (errorCode.rawValue, nil)
                    }
                    return (nil, valueAsString as AnyObject)
                } else if let arrayOfArguments = arguments as? [Any], let firstArgument = arrayOfArguments.first {
                    
                    maxLengthAsString = StringType(describing: firstArgument)
                    if let maxLength = Int(maxLengthAsString),
                        valueAsString.count > maxLength {
                    
                        return (errorCode.rawValue, nil)
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
            guard let arguments = arguments else { return (LIVR.ErrorCode.format.rawValue, nil) }
            if Utils.hasNoValue(value) { return (nil, nil) }
            if let value = value {
                if !Utils.isPrimitive(value) { return (LIVR.ErrorCode.format.rawValue, nil) }
                
                var minLengthAsString = StringType(describing: arguments)
                let valueAsString = StringType(describing: value)
                if let minLength = Int(minLengthAsString) {
                    if valueAsString.count < minLength {
                        return (errorCode.rawValue, nil)
                    }
                    return (nil, valueAsString as AnyObject)
                } else if let arrayOfArguments = arguments as? [Any], let firstArgument = arrayOfArguments.first {
                    
                    minLengthAsString = StringType(describing: firstArgument)
                    if let minLength = Int(minLengthAsString),
                        valueAsString.count < minLength {
                        
                        return (errorCode.rawValue, nil)
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
            guard let arguments = arguments else { return (LIVR.ErrorCode.format.rawValue, nil) }
            if Utils.hasNoValue(value) { return (nil, nil) }
            if let value = value {
                if !Utils.isPrimitive(value) { return (LIVR.ErrorCode.format.rawValue, nil) }
                
                let valueAsString = StringType(describing: value)
                if let arrayOfArguments = arguments as? [Any], let minLengthArgument = arrayOfArguments.first, arrayOfArguments.count > 1 {
                    
                    let maxLengthArgument = arrayOfArguments[1]
                    
                    let minLengthAsString = StringType(describing: minLengthArgument)
                    let maxLengthAsString = StringType(describing: maxLengthArgument)
                    if let minLength = Int(minLengthAsString),
                        valueAsString.count < minLength {
                        
                        return (LIVR.ErrorCode.tooShort.rawValue, nil)
                    } else if let maxLength = Int(maxLengthAsString),
                        valueAsString.count > maxLength {
                        
                        return (LIVR.ErrorCode.tooLong.rawValue, nil)
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
            guard let arguments = arguments else { return (LIVR.ErrorCode.format.rawValue, nil) }
            if Utils.hasNoValue(value) { return (nil, nil) }
            if let value = value {
                if !Utils.isPrimitive(value) { return (LIVR.ErrorCode.format.rawValue, nil) }
                
                var allowedLengthAsString = StringType(describing: arguments)
                let valueAsString = StringType(describing: value)
                if let allowedLength = Int(allowedLengthAsString) {
                    if valueAsString.count < allowedLength {
                        return (LIVR.ErrorCode.tooShort.rawValue, nil)
                    } else if 
                        valueAsString.count > allowedLength {
                        return (LIVR.ErrorCode.tooLong.rawValue, nil)
                    }
                    return (nil, valueAsString as AnyObject)
                } else if let arrayOfArguments = arguments as? [Any], let firstArgument = arrayOfArguments.first {
                    
                    allowedLengthAsString = StringType(describing: firstArgument)
                    if let allowedLength = Int(allowedLengthAsString) {
                        if valueAsString.count < allowedLength {
                            return (LIVR.ErrorCode.tooShort.rawValue, nil)
                        } else if valueAsString.count > allowedLength {
                            return (LIVR.ErrorCode.tooLong.rawValue, nil)
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
            guard let arguments = arguments else { return (LIVR.ErrorCode.format.rawValue, nil) }
            if Utils.hasNoValue(value) { return (nil, nil) }
            if let value = value {
                if !Utils.isPrimitive(value) { return (LIVR.ErrorCode.format.rawValue, nil) }
                
                let valueAsString = value as? StringType ?? StringType(describing: value)
                
                if let regex = arguments as? StringType {
                    if !valueAsString.matches(regex: regex) {
                        return (errorCode.rawValue, nil)
                    }
                    return (nil, valueAsString as AnyObject)
                } else  if let arrayOfArguments = arguments as? [Any], let regex = arrayOfArguments.first as? StringType {
                    
                    var options: NSRegularExpression.Options = []
                    if arrayOfArguments.count > 1,
                        let flag = arrayOfArguments[1] as? StringType,
                        flag == "i" {
                        
                        options.insert(.caseInsensitive)
                    }
                    
                    if !valueAsString.matches(regex: regex, options: options) {
                        return (errorCode.rawValue, nil)
                    }
                    return (nil, valueAsString as AnyObject)
                }
            }
            return (nil, nil)
        }
    }
    
    // MARK: - LIVR 2.5
    
    struct NotOneOf: LivrRule, PreDefinedRule {
        static var name = "not_one_of"
        var errorCode: LIVR.ErrorCode = .notAllowedValue
        var arguments: Any?
        private var forbiddenValues = Set<ExactString>()
        
        init() {}
        
        mutating func prepare() throws {
            let arguments = Utils.argumentsList(self.arguments)
            let stringForms = arguments.compactMap { $0 is [Any] ? nil : Utils.stringForm($0) }
            guard !arguments.isEmpty, stringForms.count == arguments.count else {
                throw RuleGenerator.wrongArguments(NotOneOf.name, self.arguments)
            }
            forbiddenValues = Set(stringForms.map(ExactString.init))
        }
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            guard let stringForm = Utils.stringForm(value) else { return (LIVR.ErrorCode.format.rawValue, nil) }
            return forbiddenValues.contains(ExactString(stringForm)) ? (errorCode.rawValue, nil) : (nil, nil)
        }
    }
    
    /// one or more ASCII digits; leading zeros are kept and the output is a string
    struct Digits: LivrRule, PreDefinedRule {
        static var name = "digits"
        var errorCode: LIVR.ErrorCode = .notDigits
        var arguments: Any?
        
        init() {}
        
        mutating func prepare() throws {
            try RuleGenerator.checkNoArguments(arguments, of: Digits.name)
        }
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            guard let stringForm = Utils.stringForm(value) else { return (LIVR.ErrorCode.format.rawValue, nil) }
            return Utils.isDigits(stringForm) ? (nil, stringForm as AnyObject) : (errorCode.rawValue, nil)
        }
    }
    
    struct StartsWith: LivrRule, PreDefinedRule, RuleWithSubstrings {
        static var name = "starts_with"
        var errorCode: LIVR.ErrorCode = .wrongFormat
        var arguments: Any?
        var substrings: [[UInt8]] = []
        
        init() {}
        
        func contains(_ substring: [UInt8], in string: [UInt8]) -> Bool {
            return string.starts(with: substring)
        }
    }
    
    struct EndsWith: LivrRule, PreDefinedRule, RuleWithSubstrings {
        static var name = "ends_with"
        var errorCode: LIVR.ErrorCode = .wrongFormat
        var arguments: Any?
        var substrings: [[UInt8]] = []
        
        init() {}
        
        func contains(_ substring: [UInt8], in string: [UInt8]) -> Bool {
            return string.reversed().starts(with: substring.reversed())
        }
    }
    
    struct Contains: LivrRule, PreDefinedRule, RuleWithSubstrings {
        static var name = "contains"
        var errorCode: LIVR.ErrorCode = .wrongFormat
        var arguments: Any?
        var substrings: [[UInt8]] = []
        
        init() {}
        
        func contains(_ substring: [UInt8], in string: [UInt8]) -> Bool {
            guard substring.count <= string.count else { return false }
            return (0...(string.count - substring.count)).contains { string[$0..<($0 + substring.count)].elementsEqual(substring) }
        }
    }
}

/// starts_with, ends_with and contains: the string form has one of the substrings. The comparison is
/// exact (UTF-8 bytes, no Unicode normalization) and case-sensitive.
protocol RuleWithSubstrings: PreDefinedRule {
    var substrings: [[UInt8]] { get set }
    func contains(_ substring: [UInt8], in string: [UInt8]) -> Bool
}

extension RuleWithSubstrings {
    
    mutating func prepare() throws {
        let arguments = Utils.argumentsList(self.arguments)
        let substrings = arguments.compactMap { Utils.stringArgument($0) }
        guard !arguments.isEmpty, substrings.count == arguments.count, !substrings.contains("") else {
            throw RuleGenerator.wrongArguments(Self.name, self.arguments)
        }
        self.substrings = substrings.map { Array($0.utf8) }
    }
    
    func validate(value: Any?) -> (Errors?, UpdatedValue?) {
        if Utils.hasNoValue(value) { return (nil, nil) }
        guard let stringForm = Utils.stringForm(value) else { return (LIVR.ErrorCode.format.rawValue, nil) }
        let string = Array(stringForm.utf8)
        if substrings.contains(where: { contains($0, in: string) }) {
            return (nil, stringForm as AnyObject)
        }
        return (errorCode.rawValue, nil)
    }
}
