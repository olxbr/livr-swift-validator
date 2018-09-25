//
//  Dictionary+Extension.swift
//  Pods-LivrDemo
//
//  Created by Felipe Lefèvre Marino on 9/16/18.
//

typealias JSON = [String: Any?]

extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any {
    
    mutating func trim() {
        for element in self {
            if var value = element.value as? String {
                value.trim()
                
                if let value = value as? Value {
                    self.updateValue(value, forKey: element.key)
                }
            }
        }
    }
}
