//
//  ViewController.swift
//  LivrDemo
//
//  Created by Felipe Lefèvre Marino on 10/7/18.
//  Copyright © 2018 Felipe Marino. All rights reserved.
//

import UIKit
import Livr

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showHowToUseLivrValidator()
    }
    
    private func showHowToUseLivrValidator() {
        var validator = LIVR.validator(validationRules: getRules())
     
        try? validator.registerRule(aliases: getAliasingRules())
        
        guard let output = try? validator.validate(data: getInput()) else {
            fatalError("output should not be nil")
        }
        
        print(output ?? "")
    }
}

extension ViewController {
    
    func getRules() -> JSON {
        return ["first_name": "required",
                "age": "adult_age",
                "last_name": ["required"],
                "middle_name": [["required": []]],
                "salary": ["required": []]]
    }
    
    func getInput() -> JSON {
        return ["first_name": "Vasya",
                "last_name": "Pupkin",
                "middle_name": "Some",
                "age": "25",
                "salary": 0]
    }
    
    func getAliasingRules() -> [JSON] {
        return [
            [
                "name": "adult_age",
                "rules": ["positive_integer", ["min_number": 18]]
            ],
            [
                "name": "adult_age_with_custom_error",
                "rules": ["positive_integer", ["min_number": 18]],
                "error": "WRONG_AGE"
            ]
        ]
    }
}

