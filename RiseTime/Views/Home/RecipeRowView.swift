//
//  RecipeRowView.swift
//  RiseTime
//
//  Individual recipe row component for list display
//

import SwiftUI

struct RecipeRowView: View {
    let recipe: Recipe

    var body: some View {
        HStack(spacing: 12) {
            recipeIcon

            VStack(alignment: .leading, spacing: 4) {
                recipeName
                recipeDetails
            }

            Spacer()

            if recipe.isVariation {
                variationBadge
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - View Components

    private var recipeIcon: some View {
        Image(systemName: servingTypeIcon)
            .font(.title2)
            .foregroundStyle(.tint)
            .frame(width: 40)
    }

    private var recipeName: some View {
        Text(recipe.name)
            .font(.headline)
    }

    private var recipeDetails: some View {
        HStack(spacing: 8) {
            Text("\(recipe.servings) \(servingsLabel)")
            if let hydration = recipe.hydrationPercentage {
                Text("•")
                Text(String(format: "%.0f%% hydration", hydration))
            }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }

    private var variationBadge: some View {
        Image(systemName: "arrow.triangle.branch")
            .font(.caption)
            .foregroundStyle(.secondary)
    }

    // MARK: - Computed Properties

    private var servingTypeIcon: String {
        switch recipe.servingType {
        case .pizza: return "circle.fill"
        case .bread: return "rectangle.fill"
        case .focaccia: return "square.fill"
        case .loaf: return "rectangle.portrait.fill"
        }
    }

    private var servingsLabel: String {
        recipe.servings == 1 ? recipe.servingType.displayName : recipe.servingType.pluralName
    }
}

#Preview {
    let recipe = Recipe(
        name: "Neapolitan Pizza",
        totalWeightInGrams: 1000,
        hydrationPercentage: 65,
        servings: 4,
        servingType: .pizza
    )

    return List {
        RecipeRowView(recipe: recipe)
    }
}
