//
//  HealthMetricsAppApp.swift
//  HealthMetricsApp
//
//  Created by Beatriz Enríquez on 16/02/26.
//

import SwiftUI

@main
struct HealthMetricsApp: App {

    var body: some Scene {
        WindowGroup {
            let repo = makeRepository()
            MetricsView(viewModel: MetricsViewModel(repository: repo))
        }
    }

    private func makeRepository() -> any MetricsRepository {
        let args = ProcessInfo.processInfo.arguments
        let env = ProcessInfo.processInfo.environment

        if args.contains("UI_TESTING") {
            let runID = env["UITEST_RUN_ID"] ?? UUID().uuidString
            let baseURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("HealthMetrics_UITests", isDirectory: true)
                .appendingPathComponent(runID, isDirectory: true)

            do {
                try FileManager.default.createDirectory(
                    at: baseURL,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            } catch {
                // En UITests es válido crashear para ver el error inmediatamente
                fatalError("Cannot create UITest dir: \(error)")
            }

            return (try? FileMetricsRepository(baseURL: baseURL, filename: "metrics.json"))
                ?? (try! FileMetricsRepository(filename: "metrics.json"))
        } else {
            return (try? FileMetricsRepository(filename: "metrics.json"))
                ?? (try! FileMetricsRepository(filename: "metrics.json"))
        }
    }
}
