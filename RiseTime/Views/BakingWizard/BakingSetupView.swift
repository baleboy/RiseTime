//
//  BakingSetupView.swift
//  RiseTime
//
//  Setup screen for baking wizard - collect servings and target time
//

import SwiftUI

struct BakingSetupView: View {
    let recipe: Recipe
    let settings: UserSettings
    let onStartBaking: (BakingSession) -> Void

    @State private var targetServings: Int
    @State private var targetDate: Date = Date()
    @State private var useTargetTime: Bool = false

    init(recipe: Recipe, settings: UserSettings, onStartBaking: @escaping (BakingSession) -> Void) {
        self.recipe = recipe
        self.settings = settings
        self.onStartBaking = onStartBaking
        self._targetServings = State(initialValue: recipe.servings)
    }

    var body: some View {
        Form {
            servingSection
            targetTimeSection
            scaledIngredientsSection
            if useTargetTime && !recipe.bakingSteps.isEmpty {
                schedulePreviewSection
            }
            startButton
        }
    }

    // MARK: - View Components

    private var servingSection: some View {
        Section("Servings") {
            Stepper("\(targetServings) \(servingsLabel)", value: $targetServings, in: 1...100)
        }
    }

    private var targetTimeSection: some View {
        Section {
            Toggle("Plan for specific time", isOn: $useTargetTime)

            if useTargetTime {
                DatePicker(
                    "Target finish time",
                    selection: $targetDate,
                    in: Date()...,
                    displayedComponents: [.date, .hourAndMinute]
                )

                quickTimeButtons
            }
        } header: {
            Text("Timing")
        }
    }

    private var quickTimeButtons: some View {
        HStack(spacing: 12) {
            ForEach(QuickTime.allCases, id: \.self) { quickTime in
                Button(quickTime.displayName) {
                    targetDate = quickTime.date
                }
                .buttonStyle(.bordered)
                .font(.caption)
            }
        }
    }

    private var scaledIngredientsSection: some View {
        Section("Ingredients (for \(targetServings) \(servingsLabel))") {
            ForEach(scaledIngredients) { ingredient in
                HStack {
                    Text(ingredient.name)
                    Spacer()
                    Text(String(format: "%.0fg", ingredient.weightInGrams))
                        .foregroundStyle(.secondary)
                }
            }

            HStack {
                Text("Total Weight")
                    .fontWeight(.semibold)
                Spacer()
                Text(String(format: "%.0fg", totalScaledWeight))
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var schedulePreviewSection: some View {
        Section {
            ForEach(Array(generatedSchedule.prefix(5))) { scheduledStep in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: scheduledStep.step.stepType.iconName)
                            .foregroundStyle(.tint)
                        Text(scheduledStep.step.name)
                            .font(.headline)
                        Spacer()
                        Text("\(scheduledStep.step.durationInMinutes) min")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text("Start: \(scheduledStep.startTime.formatted(date: .omitted, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if generatedSchedule.count > 5 {
                Text("+ \(generatedSchedule.count - 5) more steps")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let startTime = generatedSchedule.first?.startTime {
                VStack(alignment: .leading, spacing: 4) {
                    Text("You should start:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(startTime.formatted(date: .abbreviated, time: .shortened))
                        .font(.headline)
                        .foregroundStyle(.tint)
                }
                .padding(.vertical, 4)
            }
        } header: {
            Text("Schedule Preview")
        }
    }

    private var startButton: some View {
        Section {
            Button {
                startBaking()
            } label: {
                Label(useTargetTime ? "Start Baking (with Schedule)" : "Start Baking (Now)", systemImage: "play.fill")
                    .frame(maxWidth: .infinity)
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(recipe.bakingSteps.isEmpty)
        } footer: {
            if recipe.bakingSteps.isEmpty {
                Text("This recipe has no preparation steps. Add steps in the recipe editor to use the baking wizard.")
                    .font(.caption)
            }
        }
    }

    // MARK: - Computed Properties

    private var servingsLabel: String {
        targetServings == 1 ? recipe.servingType.displayName : recipe.servingType.pluralName
    }

    private var scaledIngredients: [Ingredient] {
        RecipeScaler.scale(
            recipe: recipe,
            targetServings: targetServings,
            doughResiduePercentage: settings.doughResiduePercentage
        )
    }

    private var totalScaledWeight: Double {
        scaledIngredients.reduce(0) { $0 + $1.weightInGrams }
    }

    private var generatedSchedule: [ScheduledStep] {
        guard useTargetTime else { return [] }
        return ScheduleGenerator.generateSchedule(
            for: recipe,
            targetDateTime: targetDate
        )
    }

    // MARK: - Actions

    private func startBaking() {
        let actualTargetDate = useTargetTime ? targetDate : Date().addingTimeInterval(totalDuration)
        let session = BakingSession(
            recipe: recipe,
            targetServings: targetServings,
            targetDateTime: actualTargetDate,
            doughResiduePercentage: settings.doughResiduePercentage
        )
        onStartBaking(session)
    }

    private var totalDuration: TimeInterval {
        TimeInterval(recipe.bakingSteps.reduce(0) { $0 + $1.durationInMinutes } * 60)
    }
}

// MARK: - Quick Time Options

enum QuickTime: CaseIterable {
    case today
    case tomorrow
    case evening

    var displayName: String {
        switch self {
        case .today: return "Today 6pm"
        case .tomorrow: return "Tomorrow 6pm"
        case .evening: return "This Evening"
        }
    }

    var date: Date {
        let calendar = Calendar.current
        let now = Date()

        switch self {
        case .today:
            return calendar.date(bySettingHour: 18, minute: 0, second: 0, of: now) ?? now
        case .tomorrow:
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: now) ?? now
            return calendar.date(bySettingHour: 18, minute: 0, second: 0, of: tomorrow) ?? tomorrow
        case .evening:
            return calendar.date(bySettingHour: 19, minute: 0, second: 0, of: now) ?? now
        }
    }
}

#Preview {
    let recipe = Recipe(
        name: "Neapolitan Pizza",
        ingredients: [
            Ingredient(name: "Flour", weightInGrams: 500, type: .flour),
            Ingredient(name: "Water", weightInGrams: 325, type: .water)
        ],
        bakingSteps: [
            BakingStep(name: "Mix", instructions: "Mix ingredients", durationInMinutes: 10, stepType: .mixing, order: 0),
            BakingStep(name: "First Proof", instructions: "Let rise", durationInMinutes: 60, stepType: .firstProof, order: 1)
        ],
        servings: 4,
        servingType: .pizza
    )

    return BakingSetupView(
        recipe: recipe,
        settings: .default,
        onStartBaking: { _ in }
    )
}
