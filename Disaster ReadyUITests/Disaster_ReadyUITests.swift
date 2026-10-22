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
        XCUIDevice.shared.orientation = .portrait
    }

    @MainActor
    func testFirstLaunchShowsPrimaryChoicesWithoutBlockingOnboarding() throws {
        let app = XCUIApplication()
        app.launchArguments = [
            "-hasSeenOnboarding", "NO",
            "-preferredLanguageCode", "nb",
            "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryL"
        ]
        app.resetAuthorizationStatus(for: .location)
        app.launch()

        XCTAssertTrue(app.buttons["primaryHelpNowButton"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["primaryPreparednessButton"].exists)
        XCTAssertTrue(app.buttons["primaryEmergencyPlanButton"].exists)
        XCTAssertTrue(app.buttons["settingsButton"].exists)
        XCTAssertFalse(app.buttons["onboardingStartButton"].exists)

        let helpButton = app.buttons["primaryHelpNowButton"]
        scrollToHittable(helpButton, in: app)
        helpButton.tap()
        let offlineStatus = app.descendants(matching: .any)["offlineGuidanceStatus"]
        for _ in 0..<6 where !offlineStatus.exists {
            app.swipeUp()
        }
        XCTAssertTrue(offlineStatus.waitForExistence(timeout: 5))
    }

    @MainActor
    func testPrimaryChoicesOpenExistingEmergencyPlanAndPreparedness() throws {
        let app = launchEnglishApp()

        let emergencyPlanButton = app.buttons["primaryEmergencyPlanButton"]
        XCTAssertTrue(emergencyPlanButton.waitForExistence(timeout: 5))
        scrollToHittable(emergencyPlanButton, in: app)
        emergencyPlanButton.tap()
        XCTAssertTrue(app.descendants(matching: .any)["emergencyTypePicker"].waitForExistence(timeout: 5))

        tabItem(named: "Overview", in: app).tap()
        let preparednessButton = app.buttons["primaryPreparednessButton"]
        XCTAssertTrue(preparednessButton.waitForExistence(timeout: 5))
        scrollToHittable(preparednessButton, in: app)
        preparednessButton.tap()
        XCTAssertTrue(app.descendants(matching: .any)["paymentPreparednessSection"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testCanReopenAndFinishOnboardingFromSettings() throws {
        let app = XCUIApplication()
        app.launchArguments = standardLaunchArguments(language: "nb")
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
        app.launchArguments = standardLaunchArguments(language: "nb")
        app.launch()

        let suppliesTab = tabItem(named: "Utstyr", in: app)
        XCTAssertTrue(suppliesTab.waitForExistence(timeout: 5))
        suppliesTab.tap()

        let searchField = app.descendants(matching: .any)["supplySearchField"]
        let suppliesScrollView = app.scrollViews["suppliesScrollView"]
        XCTAssertTrue(suppliesScrollView.waitForExistence(timeout: 5))
        scrollToHittable(searchField, in: suppliesScrollView)
        searchField.tap()
        searchField.typeText("zzzz-no-supply")

        let emptyState = app.descendants(matching: .any)["noSupplySearchResults"]
        XCTAssertTrue(emptyState.waitForExistence(timeout: 5))
    }

    @MainActor
    func testEventAwarePlanIsAvailable() throws {
        let app = XCUIApplication()
        app.launchArguments = standardLaunchArguments(language: "nb")
        app.launch()

        let planTab = tabItem(named: "Plan", in: app)
        XCTAssertTrue(planTab.waitForExistence(timeout: 5))
        planTab.tap()

        let emergencyPicker = app.descendants(matching: .any)["emergencyTypePicker"]
        XCTAssertTrue(emergencyPicker.waitForExistence(timeout: 5))
    }

    @MainActor
    func testPaymentPreparednessChecklistIsAvailable() throws {
        let app = XCUIApplication()
        app.launchArguments = standardLaunchArguments(language: "nb")
        app.launch()

        let suppliesTab = tabItem(named: "Utstyr", in: app)
        XCTAssertTrue(suppliesTab.waitForExistence(timeout: 5))
        suppliesTab.tap()

        let paymentSection = app.descendants(matching: .any)["paymentPreparednessSection"]
        XCTAssertTrue(paymentSection.waitForExistence(timeout: 5))
    }

    @MainActor
    func testOfficialWeatherWarningsAreAvailableFromOverview() throws {
        let app = XCUIApplication()
        app.launchArguments = standardLaunchArguments(language: "nb")
        app.launch()

        let searchField = app.descendants(matching: .any)["weatherAlertAreaSearchField"]
        for _ in 0..<4 where !searchField.exists {
            app.swipeUp()
        }
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
    }

    @MainActor
    func testHouseholdProfileCanBeOpenedFromSettings() throws {
        let app = XCUIApplication()
        app.launchArguments = standardLaunchArguments(language: "nb")
        app.launch()

        let settingsButton = app.buttons["settingsButton"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))
        settingsButton.tap()

        let profileLink = app.buttons["householdProfileLink"]
        XCTAssertTrue(profileLink.waitForExistence(timeout: 5))
        profileLink.tap()

        let countryField = app.descendants(matching: .any)["householdCountryCode"]
        XCTAssertTrue(countryField.waitForExistence(timeout: 5))
    }

    @MainActor
    func testHomeOpensMyPlanDirectly() throws {
        let app = launchEnglishApp()
        expandPreparednessShortcuts(in: app)
        let button = app.buttons["preparednessOpenPlan"]
        scrollToHittable(button, in: app)
        button.tap()

        XCTAssertTrue(
            app.descendants(matching: .any)["emergencyTypePicker"]
                .waitForExistence(timeout: 10)
        )
    }

    @MainActor
    func testHomeQuickAccessOpensSuppliesAndContacts() throws {
        let app = launchEnglishApp()
        expandPreparednessShortcuts(in: app)
        let supplies = app.buttons["preparednessOpenSupplies"]
        scrollToHittable(supplies, in: app)
        supplies.tap()
        XCTAssertTrue(app.descendants(matching: .any)["supplySearchField"].waitForExistence(timeout: 5))

        tabItem(named: "Overview", in: app).tap()
        let contacts = app.buttons["preparednessOpenContacts"]
        scrollToHittable(contacts, in: app)
        contacts.tap()
        XCTAssertTrue(app.navigationBars["Contacts"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testHomeQuickAccessOpensHouseholdAndPaymentPreparedness() throws {
        let app = launchEnglishApp()
        expandPreparednessShortcuts(in: app)
        let household = app.buttons["preparednessOpenHousehold"]
        scrollToHittable(household, in: app)
        household.tap()
        XCTAssertTrue(app.descendants(matching: .any)["householdCountryCode"].waitForExistence(timeout: 5))
        app.buttons["homeHouseholdDone"].tap()

        let payment = app.buttons["preparednessOpenPayment"]
        scrollToHittable(payment, in: app)
        payment.tap()
        XCTAssertTrue(app.descendants(matching: .any)["paymentPreparednessSection"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testHomeOfficialToolsOpenSheltersAndSources() throws {
        let app = launchEnglishApp()
        let shelters = app.descendants(matching: .any)["homeOpenShelters"]
        scrollToHittable(shelters, in: app)
        shelters.tap()
        XCTAssertTrue(app.descendants(matching: .any)["searchOfficialSheltersButton"].waitForExistence(timeout: 5))
        app.buttons["homeOfficialToolDone"].tap()

        let sources = app.descendants(matching: .any)["homeOpenSources"]
        scrollToHittable(sources, in: app)
        sources.tap()
        XCTAssertTrue(app.descendants(matching: .any)["officialSourcesSection"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testHomeLocalizationAvailableInAllSupportedLanguages() throws {
        for language in ["en", "nb", "th"] {
            let app = XCUIApplication()
            app.launchArguments = standardLaunchArguments(language: language)
            app.launch()

            XCTAssertTrue(
                app.descendants(matching: .any)["homePreparednessOverview"]
                    .waitForExistence(timeout: 5)
            )
            expandPreparednessShortcuts(in: app)
            let planButton = app.buttons["preparednessOpenPlan"]
            scrollToHittable(planButton, in: app)
            XCTAssertFalse(planButton.label.isEmpty)
            XCTAssertFalse(planButton.label.contains("home."))
            app.terminate()
        }
    }

    @MainActor
    func testPrimaryEmergencyFlowSurvivesIPadRotation() throws {
        let app = launchEnglishApp()
        let helpButton = app.buttons["primaryHelpNowButton"]

        XCTAssertTrue(helpButton.waitForExistence(timeout: 5))
        XCUIDevice.shared.orientation = .landscapeLeft
        XCTAssertTrue(helpButton.waitForExistence(timeout: 5))
        scrollToHittable(helpButton, in: app)
        helpButton.tap()
        XCTAssertTrue(app.buttons["Done"].waitForExistence(timeout: 5))

        XCUIDevice.shared.orientation = .portrait
        XCTAssertTrue(app.buttons["Done"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testOverviewAndEmergencyModePassAccessibilityAudit() throws {
        let app = launchEnglishApp()
        XCTAssertTrue(app.buttons["primaryHelpNowButton"].waitForExistence(timeout: 5))
        let auditTypes: XCUIAccessibilityAuditType = [
            .contrast,
            .elementDetection,
            .hitRegion,
            .sufficientElementDescription,
            .trait
        ]
        try app.performAccessibilityAudit(for: auditTypes)

        let helpButton = app.buttons["primaryHelpNowButton"]
        scrollToHittable(helpButton, in: app)
        helpButton.tap()
        XCTAssertTrue(app.buttons["Done"].waitForExistence(timeout: 5))
        try app.performAccessibilityAudit(for: auditTypes) { issue in
            print("Accessibility audit issue: \(issue)")
            return false
        }
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    @MainActor
    private func launchEnglishApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = standardLaunchArguments(language: "en")
        app.launch()
        return app
    }

    private func tabItem(named name: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: name).firstMatch
    }

    @MainActor
    private func standardLaunchArguments(language: String) -> [String] {
        [
            "-hasSeenOnboarding", "YES",
            "-preferredLanguageCode", language,
            "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryL"
        ]
    }

    @MainActor
    private func expandPreparednessShortcuts(in app: XCUIApplication) {
        let disclosure = app.buttons["preparednessShortcutsDisclosure"]
        XCTAssertTrue(disclosure.waitForExistence(timeout: 5))
        scrollToHittable(disclosure, in: app)
        disclosure.tap()
    }

    @MainActor
    private func scrollToHittable(_ element: XCUIElement, in scrollContainer: XCUIElement) {
        for _ in 0..<10 where !element.isHittable {
            scrollContainer.swipeUp()
        }
        for _ in 0..<10 where !element.isHittable {
            scrollContainer.swipeDown()
        }
        XCTAssertTrue(element.isHittable)
    }

    @MainActor
    private func waitUntilSelected(_ element: XCUIElement) -> Bool {
        let predicate = NSPredicate(format: "isSelected == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        return XCTWaiter.wait(for: [expectation], timeout: 10) == .completed
    }
}
