//
//  Validator.swift
//  Pods-Livr
//
//  Created by Felipe Lefèvre Marino on 9/14/18.
//

protocol LivrRule {
    static var name: String {get}
    var errorCode: String {get}
    
    typealias ErrorCode = String
    func validate(value: Any) -> ErrorCode?
}

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

// TODO: Separate in another file 👆

struct Validator {
    
    private(set) var errors: JSON?
    private(set) var output: JSON?
    
    private(set) var rules: LivrRulesJSON?
    
    typealias Output = JSON
    typealias Errors = JSON
    
    mutating func validate(data: JSON) -> (Output?, Errors?) {
        
        for pairOfFieldNameAndValue in data {
            let field = pairOfFieldNameAndValue.key
            let value = pairOfFieldNameAndValue.value
            
            verify(value, for: field)
        }
        
        return (nil, errors)
    }
    
    mutating func verify(_ value: Any, for field: String) {
        guard let rule = rules?[field] else {
            // TODO: log console error for rule not in received rules
            return
        }
        
        if let error = rule.validate(value: value) {
            errors?[field] = error
        } else {
            output?[field] = value
            // TODO: trim if needed
        }
    }
    
    mutating func register(_ rules: LivrRulesJSON) {
        self.rules = rules
    }
    
    private func autoTrim(data: Any) -> Any {
        if var data = data as? [JSON] {
            for (index, _) in data.enumerated() {
                data[index].trim()
            }
        } else if var data = data as? JSON {
            return data.trim()
        }
        
        return data
    }
}
