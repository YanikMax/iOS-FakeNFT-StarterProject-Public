import XCTest

final class FakeNFTUITests: XCTestCase {
    func testEditProfile() throws {
        let app = XCUIApplication()
        app.launch()

        let editButton = app.buttons["edit"]
        XCTAssertTrue(editButton.exists)
        editButton.tap()

        let exitButton = app.buttons["exitButton"]
        XCTAssertTrue(exitButton.exists)
        exitButton.tap()

        XCTAssertTrue(app.buttons["edit"].exists)
    }

    func testProfileNFT() throws {
        let app = XCUIApplication()
        app.launch()

        sleep(3)

        let cell = app.tables["profileTableView"].cells.firstMatch
        XCTAssertTrue(cell.exists, "No cell found in the table")

        cell.tap()
        sleep(3)
        let tablesQuery = app.tables
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)

        cellToLike.buttons["like"].tap()
        cellToLike.buttons["like"].tap()

        sleep(2)

        let myNFTTable = app.tables["myNFTTable"]
        XCTAssertTrue(myNFTTable.exists, "No table found on MyNFTViewController")
        myNFTTable.swipeUp()
        myNFTTable.swipeDown()

        let navBackButtonBlackButton = app.buttons["backButton"]
        XCTAssertTrue(navBackButtonBlackButton.exists)

        navBackButtonBlackButton.tap()
    }

    func testCatalog() throws {
        let app = XCUIApplication()
        app.launch()

        let catalogTab = app.tabBars.buttons.element(boundBy: 1)
        XCTAssertTrue(catalogTab.exists, "Second tab on the tab bar not found")
        catalogTab.tap()

        sleep(3)
        XCTAssertTrue(app.tables["catalogTableView"].exists)

        app.tables["catalogTableView"].swipeUp()
        app.tables["catalogTableView"].swipeDown()
        sleep(2)

        let firstCell = app.tables["catalogTableView"].cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.exists)
        firstCell.tap()

        sleep(4)
        let firstNFTCell = app.cells.matching(identifier: "NFTCell").element(boundBy: 0)
        XCTAssertTrue(firstNFTCell.exists, "NFTCell not found")

        let likeButton = firstNFTCell.buttons["likeButton"]
        likeButton.tap()
        sleep(2)
        likeButton.tap()
        sleep(4)
    }

    func testCart() throws {
        let app = XCUIApplication()
        app.launch()

        let cartTab = app.tabBars.buttons.element(boundBy: 2)
        XCTAssertTrue(cartTab.exists)
        cartTab.tap()
        sleep(2)
        let payButton = app.buttons["payButton"]
        XCTAssertTrue(payButton.exists, "Pay button not found")
        payButton.tap()
        sleep(2)

        let collectionView = app.collectionViews["cartCollection"]
        XCTAssertTrue(collectionView.waitForExistence(timeout: 5))

        let firstCell = collectionView.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))
        firstCell.tap()

        let navBackButtonBlackButton = app.buttons["backButton"]
        XCTAssertTrue(navBackButtonBlackButton.exists)

        navBackButtonBlackButton.tap()
    }
}
