//
//  ExperimentRepository.swift
//  RiseTime
//
//  Repository for experiment log CRUD operations
//

import Foundation
import SwiftData

@MainActor
class ExperimentRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Create

    func save(_ experiment: Experiment) throws {
        modelContext.insert(experiment)
        try modelContext.save()
    }

    // MARK: - Read

    func fetchAll() throws -> [Experiment] {
        let descriptor = FetchDescriptor<Experiment>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetchByRecipe(_ recipeId: UUID) throws -> [Experiment] {
        let descriptor = FetchDescriptor<Experiment>(
            predicate: #Predicate { $0.recipeId == recipeId },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetchById(_ id: UUID) throws -> Experiment? {
        let descriptor = FetchDescriptor<Experiment>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }

    // MARK: - Update

    func update(_ experiment: Experiment) throws {
        try modelContext.save()
    }

    // MARK: - Delete

    func delete(_ experiment: Experiment) throws {
        modelContext.delete(experiment)
        try modelContext.save()
    }
}
