//
//  BakerPercentageCalculator.swift
//  RiseTime
//
//  Service for calculating baker's percentages and weights
//

import Foundation

struct BakerPercentageCalculator {

    // MARK: - Calculate Percentages

    /// Calculates baker's percentages for all ingredients based on flour weight
    /// - Parameter ingredients: Array of ingredients to calculate percentages for
    /// - Returns: Updated ingredients with baker's percentages
    static func calculatePercentages(
        from ingredients: [Ingredient]
    ) -> [Ingredient] {
        let flourWeight = totalFlourWeight(from: ingredients)

        guard flourWeight > 0 else {
            return ingredients
        }

        return ingredients.map { ingredient in
            let updatedIngredient = ingredient
            updatedIngredient.bakerPercentage = (ingredient.weightInGrams / flourWeight) * 100
            return updatedIngredient
        }
    }

    // MARK: - Calculate Weights

    /// Calculates ingredient weights from baker's percentages and total flour weight
    /// - Parameters:
    ///   - ingredients: Ingredients with baker's percentages
    ///   - flourWeight: Total flour weight in grams
    /// - Returns: Ingredients with calculated weights
    static func calculateWeights(
        from ingredients: [Ingredient],
        flourWeight: Double
    ) -> [Ingredient] {
        return ingredients.map { ingredient in
            let updatedIngredient = ingredient

            if ingredient.type.isFlour {
                updatedIngredient.weightInGrams = flourWeight
            } else if let percentage = ingredient.bakerPercentage {
                updatedIngredient.weightInGrams = (percentage / 100) * flourWeight
            }

            return updatedIngredient
        }
    }

    // MARK: - Helper Methods

    /// Calculates total flour weight from ingredients (including flour in starters)
    private static func totalFlourWeight(from ingredients: [Ingredient]) -> Double {
        let explicitFlour = ingredients
            .filter { $0.type.isFlour }
            .reduce(0) { $0 + $1.weightInGrams }

        let flourInStarters = ingredients
            .filter { $0.type == .starter }
            .reduce(0) { $0 + $1.flourInStarter }

        return explicitFlour + flourInStarters
    }
}
