//
//  MockMetricsRepository.swift
//  HealthMetricsApp
//
//  Created by Beatriz Enríquez on 18/02/26.
//

import Foundation

actor MockMetricsRepository: MetricsRepository {
    func delete(id: UUID) async throws {
        store.removeAll { $0.id == id }
    }
    
    private var store: [Metric]

    init(seed: [Metric] = []) { self.store = seed }

    func fetchMetrics() async throws -> [Metric] { store }

    func save(metric: Metric) async throws { store.insert(metric, at: 0) }
}

