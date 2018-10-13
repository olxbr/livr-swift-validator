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
    
    var validator: Validator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        validator = LIVR.validator(validationRules: getRules())
        
        showHowToUseLivrValidator()
        showHowToUseCustomRuleInheritance()
    }
    
    private func showHowToUseLivrValidator() {
        try? validator?.registerRule(aliases: getAliasingRules())
        validate()
    }
    
    private func showHowToUseCustomRuleInheritance() {
        validator?.register(customRule: AdultAge())
        validate()
    }
    
    private func validate() {
        guard let output = try? validator?.validate(data: getInput()) else {
            fatalError("output should not be nil")
        }
        
        print("Output: " + output.debugDescription)
        print("Errors: " + String(describing: validator?.errors.debugDescription) + "\n")
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
                "age": "18",
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

