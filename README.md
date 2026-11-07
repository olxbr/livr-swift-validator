Swift LIVR Validator 📏
======================================
[![Tests](https://github.com/olxbr/livr-swift-validator/actions/workflows/tests.yml/badge.svg)](https://github.com/olxbr/livr-swift-validator/actions/workflows/tests.yml)
<a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-4.1-orange.svg?style=flat" alt="Swift" /></a>
[![CocoaPods compatible](https://img.shields.io/cocoapods/v/Livr.svg)](https://cocoapods.org/pods/Livr)
[![License](https://img.shields.io/cocoapods/l/Livr.svg)](https://raw.githubusercontent.com/marinofelipe/swift-validator-livr/master/LICENSE)

Lightweight Swift validator supporting Language Independent Validation Rules Specification (LIVR).

- [Description](#description)
- [Synopsis](#synopsis)
- [LIVR 2.5 rules](#livr-25-rules)
- [Installation](#installation)
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

# LIVR 2.5 rules

The validator supports [LIVR 2.5](https://github.com/koorchik/LIVR/blob/master/drafts/v2.5.md) and passes its test suite ([what changed](https://livr-spec.org/changes.html#v2-5), [rules](https://livr-spec.org/validation-rules.html)). LIVR 2.5 only adds rules: every LIVR 2.0 schema keeps working, except the fixes below. These rules are added in LIVR 2.5:

 * Types and numbers: `boolean`, `not_one_of`, `max_decimals`
 * Strings: `digits`, `starts_with`, `ends_with`, `contains`
 * Dates and times: `iso_date` with `min` and `max` (`{"iso_date": {"max": "today"}}`), `iso_datetime`, `iso_time`
 * Presence and metarules: `required_if`, `when`, `values`, `keys`, `any`
 * Lists and modifiers: `list_length`, `unique`, `split`
 * Formats: `uuid`, `ip`, `cidr`, `hostname`, `base64`, `hex`, `digest`, `mongo_id`, `hex_color`, `mac`, `e164`, `semver`, `jwt`
 * Checksums: `luhn`, `credit_card`, `iban`

```Swift
let rules: [String: Any?] = ["type": ["required", ["one_of": ["person", "company"]]],
                             "vat": ["required_if": ["type": "company"]],
                             "tags": [["split": ","], ["list_length": [1, 10]], "unique"],
                             "starts_at": ["iso_datetime": ["min": "today"]]]
let validator = LIVR.validator(validationRules: rules)
```

A wrong argument of a rule and a rule that is not registered are schema errors: they throw `Validator.ErrorType` from `prepare()` and `validate(data:)` (LIVR 2.0 ignored a rule that is not registered). Call `prepare()` to check the schema before the first validation:

```Swift
do {
    try validator.prepare()
} catch { print((error as? Validator.ErrorType)?.description ?? error) }
```

`today`, `yesterday` and `tomorrow` are dates in UTC of the system time. Swift cannot replace the system clock in tests, so the current time can be set:

```Swift
LIVR.now = { Date(timeIntervalSince1970: 1_760_788_800) } // 2025-10-18T12:00:00Z
defer { LIVR.now = { Date() } }
```

Fixes that change LIVR 2.0 schemas that did not work as written:

 * A rule that is not registered is a schema error (see above); LIVR 2.0 ignored it.
 * `equal_to_field` (and the new `required_if` and `when`) inside an alias or an `or` branch compares with the fields next to the validated field.
 * `iso_date` with an argument that is not an options object (`{"iso_date": "today"}`) is a schema error, and dates use the proleptic Gregorian calendar (`1500-02-29` is not a date). `"iso_date"`, `{"iso_date": []}` and `{"iso_date": null}` work as before.
 * `eq` and `one_of` with a boolean also accept `"true"` and `"false"`.

# Installation

### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

**Tested with `pod --version`: `1.0.3`**

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

### [Swift Package Manager](https://www.swift.org/documentation/package-manager/)

Add `https://github.com/olxbr/livr-swift-validator.git` to the dependencies of your package or Xcode project, and the `Livr` product to your target. The package also builds on Linux.

## Contributing and future improvements
Feel free to fork, open feature requests, issues and PRs. Known issues and mapped activities are in this repo issues.
A `contribuiting.md` will be addressed soon.

## License
Livr is released under the MIT license. [See LICENSE](https://github.com/marinofelipe/swift-validator-livr/blob/master/LICENSE) for details.

## Special thanks/credits
- [@jotafeldmann](https://github.com/jotafeldmann) for helping me come up with understanding and maping the challenges of creating this framweork.
