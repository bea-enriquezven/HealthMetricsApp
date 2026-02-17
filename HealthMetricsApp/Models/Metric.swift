//
//  Metric.swift
//  HealthMetricsApp
//
//  Created by Beatriz Enríquez on 16/02/26.
//

import Foundation
// struct to register the metric

struct Metric: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let energyLevel: Int
}
