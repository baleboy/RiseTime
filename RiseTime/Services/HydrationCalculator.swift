//
//  HydrationCalculator.swift
//  RiseTime
//
//  Service for calculating dough hydration percentage
//

import Foundation

struct HydrationCalculator {

    // MARK: - Calculate Hydration

    /// Calculates hydration percentage from ingredients
    /// - Parameter ingredients: Array of ingredients
    /// - Returns: Hydration percentage or nil if flour weight is zero
    static func calculateHydration(from ingredients: [Ingredient]) -> Double? {
        let flourWeight = totalFlourWeight(from: ingredients)
        let waterWeight = totalWaterWeight(from: ingredients)

        guard flourWeight > 0 else {
            return nil
        }

        return (waterWeight / flourWeight) * 100
    }

    /// Calculates hydration from specific flour and water weights
    /// - Parameters:
    ///   - flourWeight: Total flour weight in grams
    ///   - waterWeight: Total water weight in grams
    /// - Returns: Hydration percentage or nil if flour weight is zero
    static func calculateHydration(
        flourWeight: Double,
        waterWeight: Double
    ) -> Double? {
        guard flourWeight > 0 else {
            return nil
        }

        return (waterWeight / flourWeight) * 100
    }

    // MARK: - Calculate Water Weight

    /// Calculates required water weight for target hydration
    /// - Parameters:
    ///   - flourWeight: Total flour weight in grams
    ///   - targetHydration: Target hydration percentage
    /// - Returns: Required water weight in grams
    static func calculateWaterWeight(
        flourWeight: Double,
        targetHydration: Double
    ) -> Double {
        return (targetHydration / 100) * flourWeight
    }

    // MARK: - Helper Methods

    private static func totalFlourWeight(from ingredients: [Ingredient]) -> Double {
        let explicitFlour = ingredients
            .filter { $0.type.isFlour }
            .reduce(0) { $0 + $1.weightInGrams }

        let flourInStarters = ingredients
            .filter { $0.type.isStarter }
            .reduce(0) { $0 + $1.flourInStarter }

        return explicitFlour + flourInStarters
    }

    private static func totalWaterWeight(from ingredients: [Ingredient]) -> Double {
        let explicitWater = ingredients
            .filter { $0.type == .water }
            .reduce(0) { $0 + $1.weightInGrams }

        let waterInStarters = ingredients
            .filter { $0.type.isStarter }
            .reduce(0) { $0 + $1.waterInStarter }

        return explicitWater + waterInStarters
    }
}
