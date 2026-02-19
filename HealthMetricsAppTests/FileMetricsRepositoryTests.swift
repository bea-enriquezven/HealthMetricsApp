//
//  FileMetricsRepositoryTests.swift
//  HealthMetricsAppTests
//
//  Created by Beatriz Enríquez on 18/02/26.
//

import XCTest
@testable import HealthMetricsApp

final class FileMetricsRepositoryTests: XCTestCase {
    private var tempDir: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()
        tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        if tempDir != nil {
            try? FileManager.default.removeItem(at: tempDir)
        }
        tempDir = nil
        try super.tearDownWithError()
    }

    func testFetchWhenFileDoesNotExistReturnsEmpty() async throws {
        let repo = try await FileMetricsRepository(baseURL: tempDir, filename: "metrics.json")
        let loaded = try await repo.fetchMetrics()
        XCTAssertEqual(loaded.count, 0)
    }

    @MainActor
    func testSaveThenFetch() async throws {
        let repo = try  FileMetricsRepository(baseURL: tempDir, filename: "metrics.json")

        let m = Metric(id: UUID(), date: Date(timeIntervalSince1970: 1), energyLevel: 7)
        try await repo.save(metric: m)

        let loaded = try await repo.fetchMetrics()
       // XCTAssertEqual(loaded.count, 1)

        // Si Metric es Equatable, esto funciona:
        // XCTAssertEqual(loaded.first, m)

        // Si NO es Equatable, usa asserts por campo:
        XCTAssertEqual(loaded.first?.id, m.id)
        XCTAssertEqual(loaded.first?.energyLevel, m.energyLevel)
        XCTAssertEqual(loaded.first?.date, m.date)
    }

    @MainActor
    func testOrderIsNewestFirst_InsertAtZero() async throws {
        let repo = try FileMetricsRepository(
            baseURL: tempDir,
            filename: "\(UUID().uuidString).json"
        )

        let m1 = Metric(id: UUID(), date: Date(timeIntervalSince1970: 1), energyLevel: 3)
        let m2 = Metric(id: UUID(), date: Date(timeIntervalSince1970: 2), energyLevel: 9)

        try await repo.save(metric: m1)
        try await repo.save(metric: m2)

        let loaded = try await repo.fetchMetrics()

        XCTAssertGreaterThanOrEqual(loaded.count, 2)
        XCTAssertEqual(loaded[0].id, m2.id)
        XCTAssertEqual(loaded[1].id, m1.id)
    }


    @MainActor
    func testDeleteRemovesItem() async throws {
        let repo = try FileMetricsRepository(baseURL: tempDir, filename: "metrics.json")

        let m1 = Metric(id: UUID(), date: Date(timeIntervalSince1970: 1), energyLevel: 3)
        let m2 = Metric(id: UUID(), date: Date(timeIntervalSince1970: 2), energyLevel: 9)

        try await repo.save(metric: m1)
        try await repo.save(metric: m2)

        try await repo.delete(id: m1.id)

        let loaded = try await repo.fetchMetrics()
        XCTAssert(loaded.isEmpty == false)
        XCTAssertEqual(loaded.first?.id, m2.id)
    }

    @MainActor
    func testDataPersistsAcrossRepositoryInstances() async throws {
        // 1) Guardas con una instancia
        let repo1 = try  FileMetricsRepository(baseURL: tempDir, filename: "metrics.json")
        let m = Metric(id: UUID(), date: Date(timeIntervalSince1970: 123), energyLevel: 6)
        try await repo1.save(metric: m)

        // 2) Creas otra instancia y debe leer lo mismo del archivo
        let repo2 = try  FileMetricsRepository(baseURL: tempDir, filename: "metrics.json")
        let loaded = try await repo2.fetchMetrics()

        XCTAssert(loaded.isEmpty == false)
        XCTAssertEqual(loaded.first?.id, m.id)
    }
}
