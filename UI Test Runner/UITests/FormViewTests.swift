// Copyright 2023 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import XCTest

final class FormViewTests: XCTestCase {
    /// Text Box with no hint, no description, value not required.
    func testCase_1_1() throws {
        let app = XCUIApplication()
        let formViewTestsButton = app.buttons["Form View Tests"]
        let formTitle = app.staticTexts["InputValidation"]
        let fieldTitle = app.staticTexts["Single Line No Value, Placeholder or Description"]
        let textField = app.textFields["Single Line No Value, Placeholder or Description Text Field"]
        let helperText = app.staticTexts["Maximum 256 characters"]
        let characterCount = app.staticTexts["0"]
        
        app.launch()
        
        // Open the Form View component test view.
        formViewTestsButton.tap()
        
        // Wait and verify that the form is opened.
        XCTAssertTrue(
            formTitle.waitForExistence(timeout: 30),
            "The form failed to open after 30 seconds."
        )
        
        // Scroll to the target form element.
        while !(fieldTitle.isHittable) {
            app.scrollViews.firstMatch.swipeUp(velocity: 750)
        }
        
        XCTAssertTrue(
            textField.isHittable,
            "The text field wasn't found within 30 seconds."
        )
        
        XCTAssertFalse(
            helperText.exists,
            "The helper text was visible before it should've been."
        )
        
        XCTAssertFalse(
            characterCount.exists,
            "The character count was visible before it should've been."
        )
        
        // Give focus to the target text field.
        textField.tap()
        
        XCTAssertTrue(
            characterCount.exists,
            "The character count wasn't visible when it should've been."
        )
    }
    
    /// Tests focused and unfocused state, with value (populated).
    func testCase_1_2() throws {
        let app = XCUIApplication()
        let formViewTestsButton = app.buttons["Form View Tests"]
        let formTitle = app.staticTexts["InputValidation"]
        let fieldTitle = app.staticTexts["Single Line No Value, Placeholder or Description"]
        let textField = app.textFields["Single Line No Value, Placeholder or Description Text Field"]
        let helperText = app.staticTexts["Maximum 256 characters"]
        let characterCount = app.staticTexts["11"]
        let clearButton = app.buttons["Single Line No Value, Placeholder or Description Clear Button"]
        let returnButton = app.buttons["Return"]
        
        app.launch()
        
        // Open the Form View component test view.
        formViewTestsButton.tap()
        
        // Wait and verify that the form is opened.
        XCTAssertTrue(
            formTitle.waitForExistence(timeout: 5),
            "The form failed to open after 5 seconds."
        )
        
        // Scroll to the target form element.
        while !(fieldTitle.isHittable) {
            app.scrollViews.firstMatch.swipeUp(velocity: 750)
        }
        
        XCTAssertTrue(
            textField.isHittable,
            "The text field wasn't found within 30 seconds."
        )
        
        textField.tap()
        
        app.typeText("Sample text")
        
        XCTAssertTrue(
            helperText.exists,
            "The helper text wasn't visible when it should've been."
        )
        
        XCTAssertTrue(
            characterCount.exists,
            "The character count wasn't visible when it should've been."
        )
        
        XCTAssertTrue(
            clearButton.isHittable,
            "The clear button wasn't present when it should've been."
        )
        
        returnButton.tap()
        
        XCTAssertTrue(
            fieldTitle.isHittable,
            "The title wasn't found within 30 seconds."
        )
        
        XCTAssertFalse(
            helperText.exists,
            "The helper text was visible when it should've been hidden."
        )
        
        XCTAssertTrue(
            clearButton.isHittable,
            "The clear button wasn't present when it should've been."
        )
        
        XCTAssertTrue(
            textField.isHittable,
            "The text field wasn't found within 30 seconds."
        )
    }
    
    func testCase_1_3() throws {
        let app = XCUIApplication()
        let formViewTestsButton = app.buttons["Form View Tests"]
        let formTitle = app.staticTexts["InputValidation"]
        let fieldTitle = app.staticTexts["Single Line No Value, Placeholder or Description"]
        let textField = app.textFields["Single Line No Value, Placeholder or Description Text Field"]
        let characterCount = app.staticTexts["257"]
        
        app.launch()
        
        // Open the Form View component test view.
        formViewTestsButton.tap()
        
        // Wait and verify that the form is opened.
        XCTAssertTrue(
            formTitle.waitForExistence(timeout: 5),
            "The form failed to open after 5 seconds."
        )
        
        // Scroll to the target form element.
        while !(fieldTitle.isHittable) {
            app.scrollViews.firstMatch.swipeUp(velocity: 750)
        }
        
        textField.tap()
        
        app.typeText(.loremIpsum257)
        
        XCTAssertTrue(
            fieldTitle.isHittable,
            "The title wasn't found within 30 seconds."
        )
        
        XCTAssertTrue(
            helperText.exists,
            "The helper text was visible when it should've been hidden."
        )
        
        XCTAssertTrue(
            characterCount.waitForExistence(timeout: 5),
            "The character count wasn't visible when it should've been."
        )
    }
}

private extension String {
    /// 257 characters of Lorem ipsum text
    static var loremIpsum257: Self {
        .init(
            """
            Lorem ipsum dolor sit amet, consecteur adipiscing elit, sed do eiusmod tempor \
            incididunt ut labore et dolore magna aliqua. Semper eget at tellus. Sed cras ornare \
            arcu dui vivamus arcu. In a metus dictum at. Semper eget duis at adipiscing tellus.
            """
        )
    }
}
