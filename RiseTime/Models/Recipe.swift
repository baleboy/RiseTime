//
//  Recipe.swift
//  RiseTime
//
//  Core recipe model with ingredients, metadata, and versioning support
//

import Foundation
import SwiftData

@Model
final class Recipe: Identifiable {
    var id: UUID
    var name: String
    var recipeDescription: String?
    var ingredients: [Ingredient]
    var bakingSteps: [BakingStep]
    var totalWeightInGrams: Double
    var hydrationPercentage: Double?
    var servings: Int
    var servingType: ServingType
    var createdDate: Date
    var modifiedDate: Date
    var parentRecipeId: UUID?

    init(
        id: UUID = UUID(),
        name: String,
        recipeDescription: String? = nil,
        ingredients: [Ingredient] = [],
        bakingSteps: [BakingStep] = [],
        totalWeightInGrams: Double = 0,
        hydrationPercentage: Double? = nil,
        servings: Int = 1,
        servingType: ServingType = .pizza,
        createdDate: Date = Date(),
        modifiedDate: Date = Date(),
        parentRecipeId: UUID? = nil
    ) {
        self.id = id
        self.name = name
        self.recipeDescription = recipeDescription
        self.ingredients = ingredients
        self.bakingSteps = bakingSteps
        self.totalWeightInGrams = totalWeightInGrams
        self.hydrationPercentage = hydrationPercentage
        self.servings = servings
        self.servingType = servingType
        self.createdDate = createdDate
        self.modifiedDate = modifiedDate
        self.parentRecipeId = parentRecipeId
    }

    var isVariation: Bool {
        parentRecipeId != nil
    }
}

// MARK: - Serving Type

enum ServingType: String, Codable, CaseIterable {
    case pizza
    case bread
    case focaccia
    case loaf

    var displayName: String {
        rawValue.capitalized
    }

    var pluralName: String {
        switch self {
        case .pizza: return "Pizzas"
        case .bread: return "Breads"
        case .focaccia: return "Focaccias"
        case .loaf: return "Loaves"
        }
    }
}
