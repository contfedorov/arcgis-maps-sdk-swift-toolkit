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
            formTitle.waitForExistence(timeout: 5),
            "The form failed to open after 5 seconds."
        )
        
        // Scroll to the target form element.
        while !(fieldTitle.isHittable) {
            app.scrollViews.firstMatch.swipeUp(velocity: 500)
        }
        
        XCTAssertTrue(
            textField.isHittable,
            "The target text field wasn't visible."
        )
        
        XCTAssertFalse(
            helperText.isHittable,
            "The helper text wasn't hidden."
        )
        
        XCTAssertFalse(
            characterCount.isHittable,
            "The character count wasn't hidden."
        )
        
        // Give focus to the target text field.
        textField.tap()
        
        XCTAssertTrue(
            characterCount.isHittable,
            "The character count wasn't visible."
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
            app.scrollViews.firstMatch.swipeUp(velocity: 500)
        }
        
        XCTAssertTrue(
            textField.isHittable,
            "The text field wasn't visible."
        )
        
        textField.tap()
        
        app.typeText("Sample text")
        
        XCTAssertTrue(
            helperText.isHittable,
            "The helper text wasn't visible."
        )
        
        XCTAssertTrue(
            characterCount.isHittable,
            "The character count wasn't visible."
        )
        
        XCTAssertTrue(
            clearButton.isHittable,
            "The clear button wasn't visible."
        )
        
        #if targetEnvironment(macCatalyst)
            app.typeText("\r")
        #else
            returnButton.tap()
        #endif
        
        XCTAssertTrue(
            fieldTitle.isHittable,
            "The title wasn't visible."
        )
        
        XCTAssertFalse(
            helperText.isHittable,
            "The helper text wasn't hidden."
        )
        
        XCTAssertTrue(
            clearButton.isHittable,
            "The clear button wasn't visible."
        )
        
        XCTAssertTrue(
            textField.isHittable,
            "The text field wasn't visible."
        )
    }
    
    func testCase_1_3() throws {
        let app = XCUIApplication()
        let formViewTestsButton = app.buttons["Form View Tests"]
        let formTitle = app.staticTexts["InputValidation"]
        let fieldTitle = app.staticTexts["Single Line No Value, Placeholder or Description"]
        let textField = app.textFields["Single Line No Value, Placeholder or Description Text Field"]
        let helperText = app.staticTexts["Maximum 256 characters"]
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
            app.scrollViews.firstMatch.swipeUp(velocity: 500)
        }
        
        textField.tap()
        
        app.typeText(.loremIpsum257)
        
        XCTAssertTrue(
            fieldTitle.isHittable,
            "The title wasn't visible."
        )
        
        XCTAssertTrue(
            helperText.isHittable,
            "The helper text wasn't visible."
        )
        
        XCTAssertTrue(
            characterCount.isHittable,
            "The character count wasn't visible."
        )
    }
    
    func testCase_2_1() throws {
        let app = XCUIApplication()
        let calendarImage = app.images["Required Date Calendar Image"]
        let clearButton = app.buttons["Required Date Clear Button"]
        let datePicker = app.datePickers["Required Date Date Picker"]
        let fieldTitle = app.staticTexts["Required Date"]
        let fieldValue = app.staticTexts["Required Date Value"]
        let footer = app.staticTexts["Required Date Footer"]
        let formTitle = app.staticTexts["DateTimePoint"]
        let formViewTestsButton = app.buttons["Form View Tests"]
        let nowButton = app.buttons["Required Date Now Button"]
        
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
            app.scrollViews.firstMatch.swipeUp(velocity: 500)
        }
        
        if fieldValue.label != "No Value" {
            clearButton.tap()
        }
        
        XCTAssertEqual(
            fieldValue.label,
            "No Value"
        )
        
        XCTAssertTrue(
            footer.isHittable,
            "The required label wasn't visible."
        )
        
        XCTAssertEqual(
            footer.label,
            "Required"
        )
        
        XCTAssertTrue(
            calendarImage.isHittable,
            "The calendar image wasn't visible."
        )
        
        calendarImage.tap()
        
        XCTAssertTrue(
            datePicker.isHittable,
            "The date picker wasn't visible."
        )
        
        XCTAssertEqual(
            fieldValue.label,
            Date.now.formatted(.dateTime.day().month().year().hour().minute())
        )
        
        XCTAssertTrue(
            nowButton.isHittable,
            "The now button wasn't visible."
        )
        
        // Scroll to the target form element.
        while !(footer.isHittable) {
            app.scrollViews.firstMatch.swipeUp(velocity: 500)
        }
        
        XCTAssertEqual(
            footer.label,
            "Date Entry is Required"
        )
    }
    
    func testCase_2_2() {
        let app = XCUIApplication()
        let datePicker = app.datePickers["Launch Date and Time for Apollo 11 Date Picker"]
        let fieldTitle = app.staticTexts["Launch Date and Time for Apollo 11"]
        let fieldValue = app.staticTexts["Launch Date and Time for Apollo 11 Value"]
        let footer = app.staticTexts["Launch Date and Time for Apollo 11 Footer"]
        let formTitle = app.staticTexts["DateTimePoint"]
        let formViewTestsButton = app.buttons["Form View Tests"]
        let nowButton = app.buttons["Launch Date and Time for Apollo 11 Now Button"]
        
        app.launch()
            
        // Open the Form View component test view.
        formViewTestsButton.tap()
        
        // Wait and verify that the form is opened.
        XCTAssertTrue(
            formTitle.waitForExistence(timeout: 5),
            "The form failed to open after 5 seconds."
        )
        
        fieldValue.tap()
        
        XCTAssertTrue(
            fieldTitle.isHittable,
            "The field title wasn't visible."
        )
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let localDate = formatter.date(from: "1969-07-07T20:17:00.000Z")
        
        XCTAssertEqual(
            fieldValue.label,
            localDate?.formatted(.dateTime.day().month().year().hour().minute())
        )
        
        XCTAssertEqual(
            footer.label,
            "Enter the launch date and time (July 7, 1969 20:17 UTC)"
        )
        
        XCTAssertTrue(
            datePicker.isHittable,
            "The date picker wasn't visible."
        )
        
        XCTAssertTrue(
            nowButton.isHittable,
            "The now button wasn't visible."
        )
        
        fieldValue.tap()
        
        XCTAssertTrue(
            fieldValue.isHittable,
            "The label wasn't visible."
        )
        
        XCTAssertFalse(
            datePicker.isHittable,
            "The date picker was visible."
        )
    }
    
    func testCase_2_3() {
        let app = XCUIApplication()
        let datePicker = app.datePickers["Launch Date for Apollo 11 Date Picker"]
        let fieldTitle = app.staticTexts["Launch Date for Apollo 11"]
        let fieldValue = app.staticTexts["Launch Date for Apollo 11 Value"]
        let footer = app.staticTexts["Launch Date for Apollo 11 Footer"]
        let formTitle = app.staticTexts["DateTimePoint"]
        let formViewTestsButton = app.buttons["Form View Tests"]
        let todayButton = app.buttons["Launch Date for Apollo 11 Today Button"]
        
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
            app.scrollViews.firstMatch.swipeUp(velocity: 500)
        }
        
        XCTAssertTrue(
            footer.isHittable,
            "The footer wasn't visible."
        )
        
        fieldValue.tap()
        
        XCTAssertEqual(
            footer.label,
            "Enter the Date for the Apollo 11 launch"
        )
        
        XCTAssertTrue(
            fieldValue.isHittable,
            "The field value wasn't visible."
        )
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let localDate = formatter.date(from: "2023-07-14")
        
        XCTAssertEqual(
            fieldValue.label,
            localDate?.formatted(.dateTime.day().month().year())
        )
        
        XCTAssertTrue(
            datePicker.isHittable,
            "The date picker wasn't visible."
        )
        
        XCTAssertTrue(
            todayButton.isHittable,
            "The today button wasn't visible."
        )
    }
    
    func testCase_2_4() {
        let app = XCUIApplication()
        let clearButton = app.buttons["Launch Date Time End Clear Button"]
        let fieldTitle = app.staticTexts["Launch Date Time End"]
        let fieldValue = app.staticTexts["Launch Date Time End Value"]
        let footer = app.staticTexts["Launch Date Time End Footer"]
        let formTitle = app.staticTexts["DateTimePoint"]
        let formViewTestsButton = app.buttons["Form View Tests"]
        let nowButton = app.buttons["Launch Date Time End Now Button"]
        
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
            app.scrollViews.firstMatch.swipeUp(velocity: 500)
        }
        
        if fieldValue.label != "No Value" {
            clearButton.tap()
        }
        
        fieldValue.tap()
        
        // Scroll to the target form element.
        while !(footer.isHittable) {
            app.scrollViews.firstMatch.swipeUp(velocity: 250)
        }
        
        XCTAssertTrue(
            footer.isHittable,
            "The footer wasn't visible."
        )
        
        nowButton.tap()
        
        fieldValue.tap()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let localDate = formatter.date(from: "1969-07-27T07:00:00.000Z")
        
        XCTAssertEqual(
            fieldValue.label,
            localDate?.formatted(.dateTime.day().month().year().hour().minute())
        )
    }
    
    func testCase_2_5() {
        let app = XCUIApplication()
        let formViewTestsButton = app.buttons["Form View Tests"]
        
        app.launch()
            
        // Open the Form View component test view.
        formViewTestsButton.tap()
    }
    
    func testCase_2_6() {
        let app = XCUIApplication()
        let formViewTestsButton = app.buttons["Form View Tests"]
        
        app.launch()
            
        // Open the Form View component test view.
        formViewTestsButton.tap()
    }
}

private extension String {
    /// 257 characters of Lorem ipsum text
    static var loremIpsum257: Self {
        .init(
            """
            Lorem ipsum dolor sit amet, consecteur adipiscing elit, sed do eiusmod tempor \
            incididunt ut labore et dolore magna aliqua. Semper eget at tellus. Sed cras ornare \
            arcu dui vivamus arcu. In a metus dictum at. Cras at vivamus at adipiscing \
            tellus et ut dolore.
            """
        )
    }
}
