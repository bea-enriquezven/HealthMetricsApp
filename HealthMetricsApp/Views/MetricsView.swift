//
//  MetricsView.swift
//  HealthMetricsApp
//
//  Created by Beatriz Enríquez on 16/02/26.
//

import Foundation
import SwiftUI

struct MetricsView: View {
    @StateObject var viewModel: MetricsViewModel
    @State private var energyLevel: Double = 5


    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {

                HStack {
                    Text("Energy: \(Int(energyLevel))")
                    Slider(value: $energyLevel, in: 1...10, step: 1)
                        .accessibilityIdentifier("energySlider")
                }
                .padding(.horizontal)

                List {
                    ForEach(viewModel.metrics) { metric in
                        VStack(alignment: .leading) {
                            Text("Energy: \(metric.energyLevel)")
                            Text(metric.date.formatted()).font(.caption)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityIdentifier("metricRow")
                        
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let id = viewModel.metrics[index].id
                            Task { await viewModel.delete(id: id) }
                        }
                    }
                }
                .accessibilityIdentifier("metricsList")

            }
            .navigationTitle("Health Metrics")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await viewModel.add(energyLevel: Int(energyLevel)) }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("addButton")
                    
                }
            }
            .task { await viewModel.load() }
            .padding(.top)
        }
    }
}

#Preview {
    var mock:  MetricsRepository {
       MockMetricsRepository(seed: [
           Metric(id: UUID(), date: .now, energyLevel: 7),
           Metric(id: UUID(), date: .now.addingTimeInterval(-86400), energyLevel: 5),
           Metric(id: UUID(), date: .now.addingTimeInterval(-172800), energyLevel: 8),
       ])
   }
    MetricsView(viewModel: .init(repository:  mock))
}




