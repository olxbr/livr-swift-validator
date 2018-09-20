//
//  String+Trim.swift
//  Pods-LivrDemo
//
//  Created by Felipe Lefèvre Marino on 9/16/18.
//

extension String {
    
    mutating func trim() {
        self = self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
