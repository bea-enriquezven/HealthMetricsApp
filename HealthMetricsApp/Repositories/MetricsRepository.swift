//
//  MetricsRepository.swift
//  HealthMetricsApp
//
//  Created by Beatriz Enríquez on 16/02/26.
//

import Foundation

protocol MetricsRepository {
    func fetchMetrics() async throws -> [Metric]
    func save(metric: Metric) async throws
    func delete(id: UUID) async throws
    
}



