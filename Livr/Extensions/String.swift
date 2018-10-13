//
//  String+Trim.swift
//  Pods-LivrDemo
//
//  Created by Felipe Lefèvre Marino on 9/16/18.
//

extension String {
    
    func removingCharacters(in set: CharacterSet) -> String {
        let filtered = unicodeScalars.lazy.filter { !set.contains($0) }
        return String(String.UnicodeScalarView(filtered))
    }
}
