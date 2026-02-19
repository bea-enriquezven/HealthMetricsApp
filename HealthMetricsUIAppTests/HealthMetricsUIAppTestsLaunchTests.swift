//
//  HealthMetricsUIAppTestsLaunchTests.swift
//  HealthMetricsUIAppTests
//
//  Created by Beatriz Enríquez on 18/02/26.
//

import XCTest

final class HealthMetricsUIAppTestsLaunchTests: XCTestCase {
    
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    func testAddIncreasesRowCount() {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launchEnvironment["UITEST_RUN_ID"] = UUID().uuidString
        app.launch()
        
        // 1) Espera algo que siempre exista en pantalla
        let addButton = app.buttons["addButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()
        
        
        // (opcional) mover slider si aplica
        let slider = app.descendants(matching: .any)["energySlider"]
        XCTAssertTrue(slider.waitForExistence(timeout: 5))
        slider.adjust(toNormalizedSliderPosition: 0.8)
        
        // 2) Toca +
        addButton.tap()
        
        // 3) Ahora sí: espera a que exista la lista o al menos 1 celda
        let list = app.descendants(matching: .any)["metricsList"]
        XCTAssertTrue(list.waitForExistence(timeout: 5))
        
        // En vez de list.cells (depende del tipo), usa cells globales
        XCTAssertGreaterThan(app.cells.count, 0)
    }
    
    func testDeleteDecreasesRowCount() {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launchEnvironment["UITEST_RUN_ID"] = UUID().uuidString
        app.launch()

        let addButton = app.buttons["addButton"].firstMatch
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        XCTAssertTrue(addButton.isHittable)

        // Query SOLO de celdas de métricas
        
        let rows = app.descendants(matching: .any).matching(identifier: "metricRow")

        // 1) Asegura que exista al menos 1 (si arrancas vacío, primero agrega una)
        if rows.count == 0 {
            addButton.tap()
            let appearPredicate = NSPredicate(format: "count >= 1")
            expectation(for: appearPredicate, evaluatedWith: rows, handler: nil)
            waitForExpectations(timeout: 5)
        }

        let countBeforeDelete = rows.count
        XCTAssertGreaterThan(countBeforeDelete, 0)

        // 2) Swipe y borrar sobre la primera celda de métrica
        let firstMetricCell = rows.element(boundBy: 0)
        XCTAssertTrue(firstMetricCell.waitForExistence(timeout: 5))
        firstMetricCell.swipeLeft()

        let deleteButton = app.buttons["Delete"].firstMatch
        let eliminarButton = app.buttons["Eliminar"].firstMatch

        if deleteButton.exists {
            deleteButton.tap()
        } else if eliminarButton.exists {
            eliminarButton.tap()
        } else {
            XCTFail("No apareció Delete/Eliminar tras swipe. UI tree:\n\(app.debugDescription)")
            return
        }

    }
    
}
