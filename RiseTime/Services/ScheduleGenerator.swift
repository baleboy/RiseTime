//
//  ScheduleGenerator.swift
//  RiseTime
//
//  Service for generating time-based baking schedules
//

import Foundation

struct ScheduleGenerator {

    // MARK: - Generate Schedule

    /// Generates a time-based schedule working backwards from target date
    /// - Parameters:
    ///   - recipe: The recipe with baking steps
    ///   - targetDateTime: When the baking should be complete
    ///   - ambientTemp: Room temperature in Celsius (affects proofing time)
    /// - Returns: Array of scheduled steps with start times
    static func generateSchedule(
        for recipe: Recipe,
        targetDateTime: Date,
        ambientTemp: Int = 22
    ) -> [ScheduledStep] {
        let adjustedSteps = adjustStepDurations(
            recipe.bakingSteps,
            for: ambientTemp
        )

        return calculateStartTimes(
            for: adjustedSteps,
            targetDateTime: targetDateTime
        )
    }

    // MARK: - Helper Methods

    private static func adjustStepDurations(
        _ steps: [BakingStep],
        for temperature: Int
    ) -> [BakingStep] {
        return steps.map { step in
            let adjustedStep = step

            if step.stepType == .firstProof || step.stepType == .secondProof {
                let factor = proofingTimeFactor(for: temperature)
                adjustedStep.durationInMinutes = Int(
                    Double(step.durationInMinutes) * factor
                )
            }

            return adjustedStep
        }
    }

    private static func proofingTimeFactor(for temperature: Int) -> Double {
        // Base temperature: 22°C (room temp)
        // For every degree above/below, adjust by 5%
        let baseTempCelsius = 22
        let adjustmentPerDegree = 0.05
        let tempDifference = baseTempCelsius - temperature

        return 1.0 + (Double(tempDifference) * adjustmentPerDegree)
    }

    private static func calculateStartTimes(
        for steps: [BakingStep],
        targetDateTime: Date
    ) -> [ScheduledStep] {
        var scheduledSteps: [ScheduledStep] = []
        var currentTime = targetDateTime

        // Work backwards from target time
        for step in steps.reversed() {
            let stepStartTime = currentTime.addingTimeInterval(
                -Double(step.durationInMinutes * 60)
            )

            scheduledSteps.insert(
                ScheduledStep(step: step, startTime: stepStartTime),
                at: 0
            )

            currentTime = stepStartTime
        }

        return scheduledSteps
    }
}

// MARK: - Scheduled Step Model

struct ScheduledStep: Identifiable {
    let id: UUID
    let step: BakingStep
    let startTime: Date

    init(step: BakingStep, startTime: Date) {
        self.id = step.id
        self.step = step
        self.startTime = startTime
    }

    var endTime: Date {
        startTime.addingTimeInterval(Double(step.durationInMinutes * 60))
    }
}
