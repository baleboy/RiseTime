//
//  Experiment.swift
//  RiseTime
//
//  Model for logging baking experiment results and notes
//

import Foundation
import SwiftData

@Model
final class Experiment: Identifiable {
    var id: UUID
    var recipeId: UUID
    var recipeName: String
    var date: Date
    var ambientTemperatureCelsius: Int?
    var ovenTemperatureCelsius: Int?
    var hydrationPercentage: Double?
    var rating: Int?
    var notes: String?
    var flavorProfile: String?

    init(
        id: UUID = UUID(),
        recipeId: UUID,
        recipeName: String,
        date: Date = Date(),
        ambientTemperatureCelsius: Int? = nil,
        ovenTemperatureCelsius: Int? = nil,
        hydrationPercentage: Double? = nil,
        rating: Int? = nil,
        notes: String? = nil,
        flavorProfile: String? = nil
    ) {
        self.id = id
        self.recipeId = recipeId
        self.recipeName = recipeName
        self.date = date
        self.ambientTemperatureCelsius = ambientTemperatureCelsius
        self.ovenTemperatureCelsius = ovenTemperatureCelsius
        self.hydrationPercentage = hydrationPercentage
        self.rating = rating
        self.notes = notes
        self.flavorProfile = flavorProfile
    }

    var isRated: Bool {
        rating != nil
    }

    var hasNotes: Bool {
        !(notes?.isEmpty ?? true)
    }
}

// MARK: - Rating Validation

extension Experiment {
    static let minRating = 1
    static let maxRating = 5

    var isValidRating: Bool {
        guard let rating = rating else { return false }
        return rating >= Self.minRating && rating <= Self.maxRating
    }
}
