//
//  Validator.swift
//  Pods-Livr
//
//  Created by Felipe Lefèvre Marino on 9/14/18.
//

enum ValidatorError: Error {
    case unableToTrim
}

struct Validator {
    
    typealias RuleFunction = () -> Void
    
    private(set) var defaultRules: [String: RuleFunction]?
    private(set) var livrRules: [String: RuleFunction]
    
    var isAutoTrim: Bool = true
    var isPrepared: Bool = false
    
    var validators: [String: RuleFunction]?
    var validatorBuilders: [String: RuleFunction]?
    var errors: [Error]?
    
    init(rules: [String: RuleFunction], isAutoTrim: Bool = true) {
        self.livrRules = rules
        self.isAutoTrim = isAutoTrim
    }

    mutating func register(defaultRules: [String: RuleFunction]) {
        self.defaultRules = defaultRules
//        for rule in defaultRules {
//            self.defaultRules?[rule.key] = rule.value
//        }
    }
    
    mutating func register(rules: [String: RuleFunction]) {
        self.validatorBuilders = rules
    }
    
    // MARK: -
    private mutating func prepare() {
        guard !isPrepared else { return }
        
        for rule in livrRules {
//            if !rule.value is Array {
//
//            }
        }
        
        isPrepared = true
    }
    
    typealias Json = [String: Any]
    mutating func validate(data: Json) throws -> Bool {
        prepare()
        
        var dataToValidate = data
        if isAutoTrim {
            guard let data = autoTrim(data: data) as? Json else {
                throw ValidatorError.unableToTrim
            }
            
            dataToValidate = data
        }
        
        var errors = Json()
        var result = Json()
        var finalData = dataToValidate
        
        for validator in validators! {
            let value = finalData[validator.key]
            let valids = validator
        }
    }
    
    
    private func autoTrim(data: Any) -> Any {
        if var data = data as? [Json] {
            for (index, _) in data.enumerated() {
                data[index].trim()
            }
        } else if var data = data as? Json {
            return data.trim()
        }
        
        return data
    }
}
