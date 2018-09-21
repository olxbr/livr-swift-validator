//
//  Dictionary+Extension.swift
//  Pods-LivrDemo
//
//  Created by Felipe Lefèvre Marino on 9/16/18.
//

typealias JSON = [String: AnyObject]

extension Dictionary where Key: ExpressibleByStringLiteral, Value: AnyObject {
    
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
