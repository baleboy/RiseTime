//
//  BakingWizardView.swift
//  RiseTime
//
//  Wizard for executing baking with timer and schedule (placeholder)
//

import SwiftUI

struct BakingWizardView: View {
    let recipe: Recipe
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                Text("Baking Wizard")
                    .font(.title)
                Text("Coming soon: Step-by-step baking guidance")
                    .foregroundStyle(.secondary)
            }
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
}

#Preview {
    let recipe = Recipe(name: "Test Recipe", servings: 2, servingType: .pizza)
    return BakingWizardView(recipe: recipe)
}
