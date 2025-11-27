//
//  RecipeRepository.swift
//  RiseTime
//
//  Repository for recipe CRUD operations
//

import Foundation
import SwiftData

@MainActor
class RecipeRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Create

    func save(_ recipe: Recipe) throws {
        recipe.modifiedDate = Date()
        modelContext.insert(recipe)
        try modelContext.save()
    }

    // MARK: - Read

    func fetchAll() throws -> [Recipe] {
        let descriptor = FetchDescriptor<Recipe>(
            sortBy: [SortDescriptor(\.modifiedDate, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetchById(_ id: UUID) throws -> Recipe? {
        let descriptor = FetchDescriptor<Recipe>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }

    func fetchVariations(of recipe: Recipe) throws -> [Recipe] {
        let parentId = recipe.id
        let descriptor = FetchDescriptor<Recipe>(
            predicate: #Predicate { $0.parentRecipeId == parentId },
            sortBy: [SortDescriptor(\.createdDate, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    // MARK: - Update

    func update(_ recipe: Recipe) throws {
        recipe.modifiedDate = Date()
        try modelContext.save()
    }

    // MARK: - Delete

    func delete(_ recipe: Recipe) throws {
        modelContext.delete(recipe)
        try modelContext.save()
    }

    func deleteAll() throws {
        try modelContext.delete(model: Recipe.self)
        try modelContext.save()
    }
}
