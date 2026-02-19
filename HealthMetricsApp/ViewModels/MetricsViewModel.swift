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
    @Published var errorMessage: String?
   

    init(repository: MetricsRepository) {
        self.repository = repository
    }
    
    func load() async {
           do {
               metrics = try await repository.fetchMetrics()
           } catch {
               errorMessage = "Error loading: \(error)"
               metrics = []
           }
       }
    
    func add(energyLevel: Int) async {
        do {
            let metric = Metric(id: UUID(), date: .now, energyLevel: energyLevel)
            try await repository.save(metric: metric)
            metrics = try await repository.fetchMetrics()
        } catch {
            errorMessage = "Error saving: \(error)"
        }
    }

    
    func delete(id: UUID) async {
            do {
                try await repository.delete(id: id)
                metrics = try await repository.fetchMetrics()
            } catch {
                errorMessage = "Error deleting: \(error)"
            }
        }
}

