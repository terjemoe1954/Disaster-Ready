//
//  Disaster_ReadyUITests.swift
//  Disaster ReadyUITests
//
//  Created by Terje Moe on 28/08/2026.
//

import XCTest

final class Disaster_ReadyUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testCanReopenAndFinishOnboardingFromSettings() throws {
        let app = XCUIApplication()
        app.launchArguments = [
            "-hasSeenOnboarding", "YES",
            "-preferredLanguageCode", "nb"
        ]
        app.launch()

        let settingsButton = app.buttons["settingsButton"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))
        settingsButton.tap()

        let showOnboardingButton = app.buttons["showOnboardingAgain"]
        for _ in 0..<4 where !showOnboardingButton.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(showOnboardingButton.isHittable)
        showOnboardingButton.tap()

        let startButton = app.buttons["onboardingStartButton"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 5))
        startButton.tap()

        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))
    }

    @MainActor
    func testSupplySearchShowsEmptyState() throws {
        let app = XCUIApplication()
        app.launchArguments = [
            "-hasSeenOnboarding", "YES",
            "-preferredLanguageCode", "nb"
        ]
        app.launch()

        let suppliesTab = app.tabBars.buttons["Utstyr"]
        XCTAssertTrue(suppliesTab.waitForExistence(timeout: 5))
        suppliesTab.tap()

        let searchField = app.descendants(matching: .any)["supplySearchField"]
        for _ in 0..<10 where !searchField.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(searchField.isHittable)
        searchField.tap()
        searchField.typeText("zzzz-no-supply")

        let emptyState = app.descendants(matching: .any)["noSupplySearchResults"]
        XCTAssertTrue(emptyState.waitForExistence(timeout: 5))
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
