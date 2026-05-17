import XCTest

final class VecationRentalUITests: XCTestCase {
    func testDiscoveryTabLoads() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["Discover"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.navigationBars["Discover"].waitForExistence(timeout: 5))
    }

    func testSearchFlow() throws {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Search"].tap()
        XCTAssertTrue(app.navigationBars["Search"].waitForExistence(timeout: 3))
    }
}
