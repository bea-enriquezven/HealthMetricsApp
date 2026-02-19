//
//  FileMetricsRepository.swift
//  HealthMetricsApp
//
//  Created by Beatriz Enríquez on 17/02/26.
//
import Foundation

enum FileMetricsRepositoryError: Error {
    case invalidDocumentsDirectory
}

actor FileMetricsRepository: MetricsRepository {

    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(baseURL: URL? = nil, filename: String = "metrics.json") throws {
        guard let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw FileMetricsRepositoryError.invalidDocumentsDirectory
        }
        self.fileURL = docs.appendingPathComponent(filename)

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    func fetchMetrics() async throws -> [Metric] {
        try readAll()
    }

    func save(metric: Metric) async throws {
        var current = try readAll()
        current.insert(metric, at: 0)
        try writeAll(current)
    }

    // MARK: - Helpers
    private func readAll() throws -> [Metric] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return [] }
        let data = try Data(contentsOf: fileURL)
        return try decoder.decode([Metric].self, from: data)
    }

    private func writeAll(_ metrics: [Metric]) throws {
        let data = try encoder.encode(metrics)

        // Escritura atómica sin "replace" obligatorio
        // .atomic escribe a un temp interno y luego renombra
        try data.write(to: fileURL, options: [.atomic])
    }
    
    func delete(id: UUID) async throws {
           var current = try readAll()
           current.removeAll { $0.id == id }
           try writeAll(current)
       }
}




