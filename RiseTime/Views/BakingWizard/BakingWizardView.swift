//
//  BakingWizardView.swift
//  RiseTime
//
//  Wizard for executing baking with timer and schedule
//

import SwiftUI
import SwiftData

struct BakingWizardView: View {
    let recipe: Recipe
    @Environment(\.dismiss) private var dismiss
    @StateObject private var settingsStore = SettingsStore()
    @State private var currentStep: WizardStep = .setup

    var body: some View {
        NavigationStack {
            currentStepView
                .navigationTitle("Bake: \(recipe.name)")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
        }
    }

    // MARK: - View Components

    @ViewBuilder
    private var currentStepView: some View {
        switch currentStep {
        case .setup:
            BakingSetupView(
                recipe: recipe,
                settings: settingsStore.settings,
                onStartBaking: { session in
                    currentStep = .active(session)
                }
            )
        case .active(let session):
            ActiveBakingView(
                session: session,
                onComplete: {
                    dismiss()
                }
            )
        }
    }
}

// MARK: - Wizard Step

enum WizardStep {
    case setup
    case active(BakingSession)
}

#Preview {
    let recipe = Recipe(
        name: "Test Recipe",
        servings: 2,
        servingType: .pizza
    )
    return BakingWizardView(recipe: recipe)
}
