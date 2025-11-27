//
//  BakingStep.swift
//  RiseTime
//
//  Model for individual baking process steps with timing and instructions
//

import Foundation
import SwiftData

@Model
final class BakingStep: Identifiable {
    var id: UUID
    var name: String
    var instructions: String
    var durationInMinutes: Int
    var temperatureCelsius: Int?
    var stepType: StepType
    var order: Int

    init(
        id: UUID = UUID(),
        name: String,
        instructions: String,
        durationInMinutes: Int,
        temperatureCelsius: Int? = nil,
        stepType: StepType,
        order: Int
    ) {
        self.id = id
        self.name = name
        self.instructions = instructions
        self.durationInMinutes = durationInMinutes
        self.temperatureCelsius = temperatureCelsius
        self.stepType = stepType
        self.order = order
    }
}

// MARK: - Step Type

enum StepType: String, Codable, CaseIterable {
    case mixing
    case kneading
    case firstProof
    case shaping
    case secondProof
    case baking
    case cooling
    case other

    var displayName: String {
        switch self {
        case .mixing: return "Mixing"
        case .kneading: return "Kneading"
        case .firstProof: return "First Proof"
        case .shaping: return "Shaping"
        case .secondProof: return "Second Proof"
        case .baking: return "Baking"
        case .cooling: return "Cooling"
        case .other: return "Other"
        }
    }

    var iconName: String {
        switch self {
        case .mixing: return "arrow.triangle.2.circlepath"
        case .kneading: return "hand.raised.fill"
        case .firstProof, .secondProof: return "clock.fill"
        case .shaping: return "hand.pinch.fill"
        case .baking: return "flame.fill"
        case .cooling: return "snowflake"
        case .other: return "circle.fill"
        }
    }
}
