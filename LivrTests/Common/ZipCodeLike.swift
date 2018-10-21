//
//  ZipCodeLike.swift
//  LivrTests
//
//  Created by Felipe Lefèvre Marino on 10/20/18.
//  Copyright © 2018 Felipe Marino. All rights reserved.
//

import XCTest
@testable import Livr

class AdditionalLikeTests: XCTestCase {

    func testZipCode() {
        let validator = LIVR.validator(isAutoTrim: true)
        var errorsAndUpdatedValue = validator.validate(value: "02401300", validationRules: ["like": "(\\d{8}|\\d{5})"])
        XCTAssertNil(errorsAndUpdatedValue.0)
        
        // testing with double optional
        let doubleOptionalZipCode: String?? = "02401300"
        let any: Any? = doubleOptionalZipCode as Any
        errorsAndUpdatedValue = validator.validate(value: any, validationRules: ["like": "(\\d{8}|\\d{5})"])
        XCTAssertNil(errorsAndUpdatedValue.0)
    }
}
