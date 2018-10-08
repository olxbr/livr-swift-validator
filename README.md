Swift LIVR Validator 📏
======================================
[![Build Status](https://travis-ci.org/marinofelipe/swift-validator-livr.svg?branch=master)](https://travis-ci.org/marinofelipe/swift-validator-livr)
[![Coverage Status](https://coveralls.io/repos/github/marinofelipe/swift-validator-livr/badge.svg?branch=master)](https://coveralls.io/github/marinofelipe/swift-validator-livr?branch=master)
<a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-4.1-orange.svg?style=flat" alt="Swift" /></a>
[![CocoaPods compatible](https://img.shields.io/cocoapods/v/Livr.svg)](https://cocoapods.org/pods/Livr)
[![License](https://img.shields.io/cocoapods/l/Livr.svg)](https://raw.githubusercontent.com/marinofelipe/swift-validator-livr/master/LICENSE)

Lightweight Swift validator supporting Language Independent Validation Rules Specification (LIVR).

- [Description](#description)
- [Synopsis](#synopsis)
- [Installation](#installation)
- [Acknowledgments](acknowledgments)
- [License](#license)

# Description
See [LIVR Specification](http://livr-spec.org) for detailed documentation and list of supported rules.

__Features:__

 * Rules are declarative and language independent
 * Any number of rules for each field
 * Return together errors for all fields
 * Excludes all fields that do not have validation rules described
 * Has possibility to validate complex hierarchical structures
 * Easy to describe and understand rules
 * Returns understandable error codes(not error messages)
 * Easy to add own rules
 * Rules are be able to change results output ("trim", "nested\_object", for example)
 * Multipurpose (user input validation, configs validation, contracts programming etc)

# Synopsis
Common usage:

```Swift
let rules = ["first_name": "required",
             "age": "adult_age",
             "last_name": ["required"],
             "middle_name": [["required": []]],
             "salary": ["required": []]
            ]

var validator = LIVR.validator(validationRules: rules, isAutoTrim: true)

var output: Validator.Output?
do {
    output = try validator.validate(data: inputJson)
} catch { print((error as? ValidatingError)?.description) }

if let output = output {
  save(userData)
} else {
    print("Errors" + validator.errors.description)
}
```

You can use modifiers separately or can combine them with validation:

```Swift
let rules = ["email": ["required", "trim", "email", "to_lc"]]
var validator = LIVR.validator(validationRules: rules, isAutoTrim: true)
```

Feel free to register your own rules:

You can use aliases(preferable, syntax covered by the specification) for a lot of cases, through a Dictionary of rules:

```Swift
let rules = ["age": ["required", "adult_age"],
             "age-2": ["adult_age_with_custom_error"]
            ]
var validator = LIVR.validator(validationRules: rules)

let aliasingRules = [
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

validator.registerRule(aliases: aliasingRules)
```

or passing alias name, rules and errorCode:

```Swift
let rules = ["password": ["required", "strong_password"]]
var validator = LIVR.validator(validationRules: rules)

validator.registerRule(alias: "strong_password", rules: ["min_length": 6], errorCode: "WEAK_PASSWORD")
```

# Installation

### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

**Tested with `pod --version`: `1.0.2`**

```ruby
# Podfile
use_frameworks!

target 'YOUR_TARGET_NAME' do
    pod 'Livr'
end
```

Replace `YOUR_TARGET_NAME` and then, in the `Podfile` directory, type:

```bash
$ pod install
```

## Contributing and future improvements
Feel free to fork, open feature requests, issues and PRs. Known issues and mapped activities are in this repo issues.
A `contribuiting.md` will be addressed soon.

## License
Livr is released under the MIT license. [See LICENSE](https://github.com/marinofelipe/swift-validator-livr/blob/master/LICENSE) for details.

## Special thanks/credits
- [@jotafeldmann](https://github.com/jotafeldmann) for helping me come up with understanding and maping the challenges of creating this framweork.
