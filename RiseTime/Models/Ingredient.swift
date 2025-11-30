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
        guard type.isStarter, let hydration = hydration else {
            return 0
        }
        return weightInGrams / (1 + hydration / 100)
    }

    var waterInStarter: Double {
        guard type.isStarter, let hydration = hydration else {
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
    case poolish
    case sourdough
    case biga
    case levain
    case customStarter
    case starter // Deprecated - kept for backward compatibility
    case oil
    case sugar
    case other

    var displayName: String {
        switch self {
        case .flour: return "Flour"
        case .water: return "Water"
        case .salt: return "Salt"
        case .yeast: return "Yeast"
        case .poolish: return "Poolish"
        case .sourdough: return "Sourdough"
        case .biga: return "Biga"
        case .levain: return "Levain"
        case .customStarter: return "Custom Starter"
        case .starter: return "Starter (Legacy)"
        case .oil: return "Oil"
        case .sugar: return "Sugar"
        case .other: return "Other"
        }
    }

    var isFlour: Bool {
        self == .flour
    }

    var isLiquid: Bool {
        self == .water || self == .oil
    }

    var isStarter: Bool {
        switch self {
        case .poolish, .sourdough, .biga, .levain, .customStarter, .starter:
            return true
        default:
            return false
        }
    }

    var defaultHydration: Double? {
        switch self {
        case .poolish: return 100
        case .sourdough: return 100
        case .biga: return 50
        case .levain: return 100
        case .starter: return 100 // Default for legacy starter
        case .customStarter: return nil
        default: return nil
        }
    }
}
