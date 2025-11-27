//
//  SettingsStore.swift
//  RiseTime
//
//  Store for managing user settings in UserDefaults
//

import Foundation
import Combine

@MainActor
class SettingsStore: ObservableObject {
    @Published private(set) var settings: UserSettings

    private let userDefaults: UserDefaults
    private let settingsKey = "user_settings"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.settings = Self.loadSettings(from: userDefaults)
    }

    // MARK: - Load Settings

    private static func loadSettings(from userDefaults: UserDefaults) -> UserSettings {
        guard let data = userDefaults.data(forKey: "user_settings"),
              let settings = try? JSONDecoder().decode(UserSettings.self, from: data) else {
            return .default
        }
        return settings
    }

    // MARK: - Update Settings

    func updateDoughResidue(_ percentage: Double) {
        settings.doughResiduePercentage = clampDoughResidue(percentage)
        saveSettings()
    }

    func updatePreferredUnits(_ units: MeasurementUnit) {
        settings.preferredUnits = units
        saveSettings()
    }

    // MARK: - Save Settings

    private func saveSettings() {
        guard let data = try? JSONEncoder().encode(settings) else {
            return
        }
        userDefaults.set(data, forKey: settingsKey)
    }

    // MARK: - Helper Methods

    private func clampDoughResidue(_ value: Double) -> Double {
        max(
            UserSettings.minDoughResiduePercentage,
            min(value, UserSettings.maxDoughResiduePercentage)
        )
    }

    // MARK: - Reset

    func reset() {
        settings = .default
        saveSettings()
    }
}
