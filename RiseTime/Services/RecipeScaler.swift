//
//  RecipeScaler.swift
//  RiseTime
//
//  Service for scaling recipe ingredients based on servings
//

import Foundation

struct RecipeScaler {

    // MARK: - Scale Recipe

    /// Scales a recipe to a new number of servings
    /// - Parameters:
    ///   - recipe: The recipe to scale
    ///   - targetServings: Target number of servings
    ///   - doughResiduePercentage: Additional percentage for dough loss (0-20)
    /// - Returns: Array of scaled ingredients
    static func scale(
        recipe: Recipe,
        targetServings: Int,
        doughResiduePercentage: Double = 5.0
    ) -> [Ingredient] {
        let scaleFactor = calculateScaleFactor(
            from: recipe.servings,
            to: targetServings
        )

        let residueMultiplier = calculateResidueMultiplier(
            doughResiduePercentage: doughResiduePercentage
        )

        return scaleIngredients(
            recipe.ingredients,
            by: scaleFactor * residueMultiplier
        )
    }

    // MARK: - Helper Methods

    private static func calculateScaleFactor(
        from originalServings: Int,
        to targetServings: Int
    ) -> Double {
        guard originalServings > 0 else { return 1.0 }
        return Double(targetServings) / Double(originalServings)
    }

    private static func calculateResidueMultiplier(
        doughResiduePercentage: Double
    ) -> Double {
        let clampedPercentage = max(0, min(20, doughResiduePercentage))
        return 1.0 + (clampedPercentage / 100)
    }

    private static func scaleIngredients(
        _ ingredients: [Ingredient],
        by factor: Double
    ) -> [Ingredient] {
        return ingredients.map { ingredient in
            let scaledIngredient = ingredient
            scaledIngredient.weightInGrams = ingredient.weightInGrams * factor
            return scaledIngredient
        }
    }
}
