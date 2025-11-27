//
//  Ingredient.swift
//  RiseTime
//
//  Core ingredient model with support for baker's percentage calculations
//

import Foundation
import SwiftData

@Model
final class Ingredient: Identifiable {
    var id: UUID
    var name: String
    var weightInGrams: Double
    var bakerPercentage: Double?
    var type: IngredientType
    var hydration: Double?

    init(
        id: UUID = UUID(),
        name: String,
        weightInGrams: Double,
        bakerPercentage: Double? = nil,
        type: IngredientType,
        hydration: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.weightInGrams = weightInGrams
        self.bakerPercentage = bakerPercentage
        self.type = type
        self.hydration = hydration
    }

    // MARK: - Starter Calculations

    var flourInStarter: Double {
        guard type == .starter, let hydration = hydration else {
            return 0
        }
        return weightInGrams / (1 + hydration / 100)
    }

    var waterInStarter: Double {
        guard type == .starter, let hydration = hydration else {
            return 0
        }
        return (hydration / 100) * flourInStarter
    }
}

// MARK: - Ingredient Type

enum IngredientType: String, Codable, CaseIterable {
    case flour
    case water
    case salt
    case yeast
    case starter
    case oil
    case sugar
    case other

    var displayName: String {
        rawValue.capitalized
    }

    var isFlour: Bool {
        self == .flour
    }

    var isLiquid: Bool {
        self == .water || self == .oil
    }
}
