//
//  MetricsViewModel.swift
//  HealthMetricsApp
//
//  Created by Beatriz Enríquez on 16/02/26.
//

import Foundation
import Combine


@MainActor
final class MetricsViewModel: ObservableObject {
    private let repository: MetricsRepository
    @Published private(set) var metrics: [Metric] = []

    init(repository: MetricsRepository) {
        self.repository = repository
    }
}

