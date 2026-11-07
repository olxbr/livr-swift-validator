//
//  Common.swift
//  Pods-LivrDemo
//
//  Created by Felipe Lefèvre Marino on 9/18/18.
//

import Foundation

struct CommonRules {

    // can't be nil/null
    struct Required: LivrRule, PreDefinedRule {
        static var name = "required"
        var errorCode: LIVR.ErrorCode = .required
        var arguments: Any?
        
        init() {}
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            if Utils.hasNoValue(value) { return (errorCode.rawValue, nil) }
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
                return (errorCode.rawValue, nil)
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
            if Utils.hasNoValue(value) { return (errorCode.rawValue, nil) }
            if let value = value {
                if Utils.hasNoValue(value) { return (errorCode.rawValue, nil) }
                if !Utils.isList(value) { return (LIVR.ErrorCode.format.rawValue, nil) }
                if let value = value as? Array<Any>, value.count < 1 { return (errorCode.rawValue, nil) }
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
                return (errorCode.rawValue, nil)
            }
            return (nil, nil)
        }
    }
    
    // MARK: - LIVR 2.5
    
    /// required when all the referenced fields have one of the given values
    struct RequiredIf: LivrRule, PreDefinedRule, RuleThatCreatesValidator {
        static var name = "required_if"
        var errorCode: LIVR.ErrorCode = .required
        var arguments: Any?
        /// references see the trimmed input with the automatic trim
        var isAutoTrim: Bool = true
        private var conditions: [(reference: FieldReference, values: Set<ExactString>)] = []
        
        init() {}
        
        mutating func prepare() throws {
            guard let entries = Utils.argumentsList(arguments).first as? [String: Any?], !entries.isEmpty else {
                throw RuleGenerator.wrongArguments(RequiredIf.name, arguments)
            }
            conditions = try entries.map { entry in
                let values = entry.value.map { Utils.argumentsList($0) } ?? []
                let stringForms = values.compactMap { $0 is [Any] ? nil : Utils.stringForm($0) }
                guard !values.isEmpty, stringForms.count == values.count, !stringForms.contains("") else {
                    throw RuleGenerator.wrongArguments(RequiredIf.name, arguments)
                }
                return (try FieldReference(entry.key, of: RequiredIf.name), Set(stringForms.map(ExactString.init)))
            }
        }
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            return validate(value: value, in: nil)
        }
        
        func validate(value: Any?, in object: [String: Any?]?) -> (Errors?, UpdatedValue?) {
            guard Utils.hasNoValue(value) else { return (nil, nil) }
            
            for condition in conditions {
                let referencedValue = condition.reference.value(in: object, isAutoTrim: isAutoTrim)
                guard !Utils.hasNoValue(referencedValue), let stringForm = Utils.stringForm(referencedValue),
                    condition.values.contains(ExactString(stringForm)) else { return (nil, nil) }
            }
            return (errorCode.rawValue, nil)
        }
    }
    
    struct ListLength: LivrRule, PreDefinedRule {
        static var name = "list_length"
        var errorCode: LIVR.ErrorCode = .format
        var arguments: Any?
        private var min = 0
        private var max = Int.max
        
        init() {}
        
        mutating func prepare() throws {
            let arguments = Utils.argumentsList(self.arguments)
            let wrongArguments = RuleGenerator.wrongArguments(ListLength.name, self.arguments)
            var min: Int?, max: Int?
            
            if let options = arguments.first as? [String: Any?] {
                guard !options.isEmpty, options.keys.allSatisfy({ $0 == "min" || $0 == "max" }) else { throw wrongArguments }
                if let option = options["min"] { min = Utils.nonNegativeInteger(option ?? nil); guard min != nil else { throw wrongArguments } }
                if let option = options["max"] { max = Utils.nonNegativeInteger(option ?? nil); guard max != nil else { throw wrongArguments } }
            } else if arguments.count >= 2 {
                min = Utils.nonNegativeInteger(arguments[0])
                max = Utils.nonNegativeInteger(arguments[1])
                guard min != nil, max != nil else { throw wrongArguments }
            } else {
                min = Utils.nonNegativeInteger(arguments.first)
                max = min
                guard min != nil else { throw wrongArguments }
            }
            self.min = min ?? 0
            self.max = max ?? Int.max
            guard self.min <= self.max else { throw wrongArguments }
        }
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            guard let list = value as? [Any] else { return (errorCode.rawValue, nil) }
            if list.count < min { return (LIVR.ErrorCode.tooFewItems.rawValue, nil) }
            if list.count > max { return (LIVR.ErrorCode.tooManyItems.rawValue, nil) }
            return (nil, nil)
        }
    }
    
    /// items are compared in their string forms; with keys, the items are objects compared by these keys
    struct Unique: LivrRule, PreDefinedRule {
        static var name = "unique"
        var errorCode: LIVR.ErrorCode = .notUniqueItems
        var arguments: Any?
        private var keys: [StringType] = []
        
        init() {}
        
        mutating func prepare() throws {
            let arguments = Utils.argumentsList(self.arguments)
            keys = arguments.compactMap { Utils.stringArgument($0) }
            guard keys.count == arguments.count else { throw RuleGenerator.wrongArguments(Unique.name, self.arguments) }
        }
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            guard let list = value as? [Any] else { return (LIVR.ErrorCode.format.rawValue, nil) }
            
            // a wrong item gives FORMAT_ERROR even after duplicates
            var seen = Set<[ExactString]>()
            var hasDuplicates = false
            for item in list where !Utils.hasNoValue(item) {
                guard let itemKey = key(of: item) else { return (LIVR.ErrorCode.format.rawValue, nil) }
                if itemKey.isEmpty { continue }
                hasDuplicates = !seen.insert(itemKey).inserted || hasDuplicates
            }
            return hasDuplicates ? (errorCode.rawValue, nil) : (nil, nil)
        }
        
        /// the string forms that identify an item, empty for an item that is ignored, nil for a wrong item
        private func key(of item: Any) -> [ExactString]? {
            if keys.isEmpty {
                return Utils.stringForm(item).map { [ExactString($0)] }
            }
            guard let object = item as? [String: Any?] else { return nil }
            var itemKey: [ExactString] = []
            var hasEmptyKeyValue = false
            // a key value that is an object or a list is wrong, also when another key value is empty
            for key in keys {
                let keyValue = object[key] ?? nil
                if Utils.hasNoValue(keyValue) {
                    hasEmptyKeyValue = true
                    continue
                }
                guard let stringForm = Utils.stringForm(keyValue) else { return nil }
                itemKey.append(ExactString(stringForm))
            }
            return hasEmptyKeyValue ? [] : itemKey
        }
    }
}
