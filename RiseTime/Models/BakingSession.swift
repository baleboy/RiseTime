//
//  BakingSession.swift
//  RiseTime
//
//  Model for tracking an active baking session
//

import Foundation

class BakingSession: ObservableObject {
    let recipe: Recipe
    let targetServings: Int
    let scaledIngredients: [Ingredient]
    let schedule: [ScheduledStep]
    @Published var currentStepIndex: Int = 0
    @Published var timeRemaining: TimeInterval = 0
    @Published var isPaused: Bool = false

    init(
        recipe: Recipe,
        targetServings: Int,
        targetDateTime: Date,
        doughResiduePercentage: Double
    ) {
        self.recipe = recipe
        self.targetServings = targetServings

        // Scale ingredients
        self.scaledIngredients = RecipeScaler.scale(
            recipe: recipe,
            targetServings: targetServings,
            doughResiduePercentage: doughResiduePercentage
        )

        // Generate schedule
        self.schedule = ScheduleGenerator.generateSchedule(
            for: recipe,
            targetDateTime: targetDateTime
        )

        // Set initial time remaining
        if let firstStep = schedule.first {
            self.timeRemaining = TimeInterval(firstStep.step.durationInMinutes * 60)
        }
    }

    // MARK: - Computed Properties

    var currentStep: ScheduledStep? {
        guard currentStepIndex < schedule.count else { return nil }
        return schedule[currentStepIndex]
    }

    var isComplete: Bool {
        currentStepIndex >= schedule.count
    }

    var progress: Double {
        guard !schedule.isEmpty else { return 0 }
        return Double(currentStepIndex) / Double(schedule.count)
    }

    // MARK: - Actions

    func startNextStep() {
        currentStepIndex += 1
        if let nextStep = currentStep {
            timeRemaining = TimeInterval(nextStep.step.durationInMinutes * 60)
        }
    }

    func togglePause() {
        isPaused.toggle()
    }
}
