//
//  CameraKitUITests.swift
//  CameraKitUITests
//
//  Created by Abhiraj on 17/09/23.
//

import XCTest

@MainActor
final class CameraKitUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
                // UI tests must launch the application that they test.
//        let app = XCUIApplication(bundleIdentifier: "com.apple.mobileslideshow")
//        app.terminate()
//        app.launch()
//        app.screenshot()
//        takeScreenShot()
//        let navBar = app.navigationBars.firstMatch
//        XCTAssertTrue(navBar.waitForExistence(timeout: 10))
//       let selectButton = navBar/*@START_MENU_TOKEN@*/.buttons["Select"]/*[[".navigationBars.buttons[\"Select\"]",".buttons[\"Select\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
//       
//        let selectExist = selectButton.waitForExistence(timeout: 1)
//        if selectExist {
//            selectButton.tap()
//        }
//        let images = app.images
//        let firstImage = images.element(boundBy: 0)
//        let secondImage = images.element(boundBy: 1)
//        let firstCoordinate = firstImage.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
//        firstCoordinate.tap()
//        takeScreenShot()
//
//        let secondCoordinate = secondImage.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
//        secondCoordinate.tap()
//        takeScreenShot()
//        let shareButton = app/*@START_MENU_TOKEN@*/.buttons["Share"]/*[[".otherElements.buttons[\"Share\"]",".buttons[\"Share\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
//        XCTAssertTrue(shareButton.isHittable)
//        app.buttons["Share"].firstMatch.tap()
//        takeScreenShot()
        
       
        
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func takeScreenShot() {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
       // attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
