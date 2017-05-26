//
//  BaseTestInSpanish.swift
//  Localize
//
//  Copyright © 2017 Kekkiwaa Inc. All rights reserved.
//

import XCTest
import Localize

class BaseTestInSpanish: XCTestCase {

    override func setUp() {
        super.setUp()
        Localize.update(provider: .json)
        Localize.testingMode()
        Localize.update(language: .spanish)
    }

    func testLocalizeKey() {
        let localized = "hello.world".localize()
        XCTAssertTrue(localized == "Hola mundo!")
    }

    func testLocalizeKeyWithValue() {
        let localized = "name".localize(value: "Andres")
        XCTAssertTrue(localized == "Hola Andres")
    }

    func testLocalizeKeyWithValues() {
        let localized = "values".localize(values: "Andres", "Software Developer")
        XCTAssertTrue(localized == "Hola a todos mi nombre es Andres y soy Software Developer , nos vemos pronto")
    }

    func testLocalizeKeyWithDictionary() {
        let localized = "username".localize(dictionary: ["username": "andresilvagomez"])
        XCTAssertTrue(localized == "Mi nombre de usuario es andresilvagomez")
    }

    func testLocalizeKeyWithManyLevels() {
        let localized = "level.one.two.three".localize()
        XCTAssertTrue(localized == "Esta es una llave multinivel")
    }

    func testLocalizeKeyWithSingleLevel() {
        let localized = "the.same.lavel".localize()
        XCTAssertTrue(localized == "Esto es una internazionalizacion en el mismo nivel")
    }

    func testDefaultValuesFromOtherLanguage() {
        let localized = "enlish".localize()
        XCTAssertTrue(localized == "This key only exist in english file.")
    }

    func testListOfAvailableLanguages() {
        let languages = Localize.availableLanguages()
        XCTAssertTrue(languages == ["en", "es"])
    }

    func testCurrentLanguage() {
        let language = Localize.language()
        XCTAssertTrue(language == "es")
    }

}
