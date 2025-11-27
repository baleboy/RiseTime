//
//  UserSettings.swift
//  RiseTime
//
//  Model for user preferences and app configuration
//

import Foundation

struct UserSettings: Codable {
    var doughResiduePercentage: Double
    var preferredUnits: MeasurementUnit

    init(
        doughResiduePercentage: Double = 5.0,
        preferredUnits: MeasurementUnit = .metric
    ) {
        self.doughResiduePercentage = doughResiduePercentage
        self.preferredUnits = preferredUnits
    }
}

// MARK: - Measurement Unit

enum MeasurementUnit: String, Codable, CaseIterable {
    case metric
    case imperial

    var displayName: String {
        switch self {
        case .metric: return "Metric (grams, °C)"
        case .imperial: return "Imperial (oz, °F)"
        }
    }

    var weightUnit: String {
        switch self {
        case .metric: return "g"
        case .imperial: return "oz"
        }
    }

    var temperatureUnit: String {
        switch self {
        case .metric: return "°C"
        case .imperial: return "°F"
        }
    }
}

// MARK: - Default Settings

extension UserSettings {
    static let `default` = UserSettings()

    static let minDoughResiduePercentage = 0.0
    static let maxDoughResiduePercentage = 20.0
}
