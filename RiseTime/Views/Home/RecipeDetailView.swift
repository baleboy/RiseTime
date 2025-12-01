//
//  RecipeDetailView.swift
//  RiseTime
//
//  Detailed view of a recipe with options to bake or edit
//

import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @State private var showingBakingWizard = false
    @State private var showingRecipeEditor = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                recipeHeader
                ingredientsSection
                if !recipe.bakingSteps.isEmpty {
                    stepsSection
                }
                actionButtons
            }
            .padding()
        }
        .navigationTitle(recipe.name)
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingBakingWizard) {
            BakingWizardView(recipe: recipe)
        }
        .sheet(isPresented: $showingRecipeEditor) {
            RecipeWizardView(recipe: recipe)
        }
    }

    // MARK: - View Components

    private var recipeHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let description = recipe.recipeDescription {
                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                recipeMetric("Servings", value: "\(recipe.servings)")
                if let hydration = recipe.hydrationPercentage {
                    recipeMetric("Hydration", value: String(format: "%.0f%%", hydration))
                }
                recipeMetric("Total Weight", value: String(format: "%.0fg", recipe.totalWeightInGrams))
            }

            HStack(spacing: 16) {
                recipeMetric("Per \(recipe.servingType.displayName)", value: String(format: "%.0fg", recipe.weightPerServing))
            }
        }
    }

    private func recipeMetric(_ label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
        }
    }

    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Ingredients")

            ForEach(recipe.ingredients) { ingredient in
                ingredientRow(ingredient)
            }
        }
    }

    private func ingredientRow(_ ingredient: Ingredient) -> some View {
        HStack {
            Text(ingredient.name)
            Spacer()
            Text(String(format: "%.0fg", ingredient.weightInGrams))
                .foregroundStyle(.secondary)
            if let percentage = ingredient.bakerPercentage {
                Text(String(format: "(%.0f%%)", percentage))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Steps")

            ForEach(recipe.bakingSteps.sorted(by: { $0.order < $1.order })) { step in
                stepRow(step)
            }
        }
    }

    private func stepRow(_ step: BakingStep) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: step.stepType.iconName)
                .foregroundStyle(.tint)
            VStack(alignment: .leading, spacing: 4) {
                Text(step.name)
                    .font(.headline)
                Text("\(step.durationInMinutes) minutes")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title2)
            .fontWeight(.bold)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                showingBakingWizard = true
            } label: {
                Label("Start Baking", systemImage: "play.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Button {
                showingRecipeEditor = true
            } label: {
                Label("Edit Recipe", systemImage: "pencil")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
    }
}

#Preview {
    let recipe = Recipe(
        name: "Neapolitan Pizza",
        recipeDescription: "Classic Italian pizza dough",
        ingredients: [
            Ingredient(name: "Flour", weightInGrams: 500, bakerPercentage: 100, type: .flour),
            Ingredient(name: "Water", weightInGrams: 325, bakerPercentage: 65, type: .water),
            Ingredient(name: "Salt", weightInGrams: 10, bakerPercentage: 2, type: .salt)
        ],
        totalWeightInGrams: 835,
        hydrationPercentage: 65,
        servings: 4,
        servingType: .pizza
    )

    return NavigationStack {
        RecipeDetailView(recipe: recipe)
    }
}
